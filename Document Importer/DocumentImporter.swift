//
//  DocumentImporter.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class DocumentImporter: NSObject {
    static let shared = DocumentImporter()
    
    /// IC Device Browser device
    private let browser = ICDeviceBrowser()
    
    /// List of connected devices
    var devices: [ICDevice] {
        return browser.devices ?? []
    }
    
    /// Enable and disable scanning
    var scanningEnabled: Bool {
        get {
            return browser.isBrowsing
        } set {
            if newValue {
                startScanning()
            } else {
                stopScanning()
            }
        }
    }
    
    private override init() {
        super.init()
        
        browser.delegate = self
        
        browser.browsedDeviceTypeMask = ICDeviceTypeMask(rawValue:
            ICDeviceTypeMask.camera.rawValue |
            ICDeviceTypeMask.scanner.rawValue |
            ICDeviceLocationTypeMask.local.rawValue |
            ICDeviceLocationTypeMask.bluetooth.rawValue |
            ICDeviceLocationTypeMask.remote.rawValue |
            ICDeviceLocationTypeMask.bonjour.rawValue |
            ICDeviceLocationTypeMask.remote.rawValue |
            ICDeviceLocationTypeMask.shared.rawValue
        )!
    }
    
    fileprivate func handleItem(_ item: ICCameraItem) {
        guard SettingsHandler.shared.importingEnabled,
            item.uti == kUTTypeImage as String,
            SettingsHandler.persistentDeviceHandler.isEnabled(item.device),
            let file = item as? ICCameraFile,
            item.description.contains("Scannable Document") else {
            return
        }
        
        let options = [
            ICDownloadsDirectoryURL: SettingsHandler.shared.importURL,
            ICDeleteAfterSuccessfulDownload: !SettingsHandler.shared.importKeepOriginalEnabled,
            ICOverwrite: true
        ] as [String : Any]
        
        file.device.requestDownloadFile(file, options: options, downloadDelegate: self, didDownloadSelector: #selector(didDownloadFile), contextInfo: nil)
    }
    
    func handleImageFile(at url: URL, process: ImportProcess = ImportProcess(), completionHandler: ((URL) -> Void)? = nil) {
        if SettingsHandler.shared.convertingEnabled {
            convertFile(withURL: url, process: process, completionHandler: completionHandler)
        } else {
            importCompleted(withURL: url, process: process, completionHandler: completionHandler)
        }
    }
    
    func handlePDFFile(at url: URL, process importProcess: ImportProcess = ImportProcess(), completionHandler: ((URL) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let urlWithoutPathExtension = url.deletingPathExtension()
            
            let tifURL = URL.makeTemporaryDirectory().appendingPathComponent(NSUUID().uuidString).appendingPathExtension("tif")
            let originalFileURL: URL
            
            if SettingsHandler.shared.convertKeepOriginalEnabled {
                originalFileURL = urlWithoutPathExtension.deletingLastPathComponent().appendingPathComponent(urlWithoutPathExtension.lastPathComponent + "_Original").appendingPathExtension("pdf")
                
                guard (try? FileManager.default.moveItem(at: url, to: originalFileURL)) != nil else {
                    return
                }
            } else {
                var newNSURL: NSURL? = nil
                
                guard (try? FileManager.default.trashItem(at: url, resultingItemURL: &newNSURL)) != nil,
                    let newURL = newNSURL?.absoluteURL else {
                        return
                }
                originalFileURL = newURL
            }
            
            importProcess.showNotification(localizedTitle: "NotificationImageExtractionStartedStartedTitle", text: url.lastPathComponent)
            
            let process = Process.withEnvoirement()
            process.launchPath = "/usr/local/bin/convert"
            
            process.arguments = [
                "-density",
                String(describing: SettingsHandler.shared.pdfDPI),
                originalFileURL.path,
                tifURL.path
            ]
            
            process.launch()
            process.waitUntilExit()
            
            self?.convertFile(withURL: tifURL, outputURL: url, process: importProcess, completionHandler: completionHandler)
        }
    }
    
    func convertFile(withURL inputURL: URL, outputURL: URL? = nil, keepOriginal: Bool = SettingsHandler.shared.convertKeepOriginalEnabled, process: ImportProcess = ImportProcess(), completionHandler: ((URL) -> Void)? = nil) {
        
        let outputURL = outputURL ?? inputURL.deletingPathExtension().appendingPathExtension("pdf")
        
        let languages = SettingsHandler.shared.selectedLanguages
        
        process.showNotification(localizedTitle: "NotificationConvertStartedTitle", text: outputURL.lastPathComponent)
        
        Tesseract.shared.run(inputURL: inputURL, outputURL: outputURL, languages: languages) { [weak self] in
            if !keepOriginal,
                FileManager.default.fileExists(atPath: outputURL.path) {
                try? FileManager.default.trashItem(at: inputURL, resultingItemURL: nil)
            }
            self?.importCompleted(withURL: outputURL, process: process, completionHandler: completionHandler)
        }
        
    }
    
    fileprivate func importCompleted(withURL url: URL, process: ImportProcess, completionHandler: ((URL) -> Void)? = nil) {
        if SettingsHandler.shared.autoOpenEnabled {
            NSWorkspace.shared().open(url)
        }

        DispatchQueue.main.async {
            process.showNotification(
                localizedTitle: "NotificationImportCompletedTitle",
                text: url.lastPathComponent,
                userInfo: [
                    "url": url.absoluteString
                ]
            )
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                process.removeDeliverdNotifications()
            }
            completionHandler?(url)
        }
    }
    
    func startScanning() {
        browser.start()
        NotificationCenter.default.post(name: NSNotification.Name.DocumentImporterScannerStateChanged, object: nil)
    }
    
    func stopScanning() {
        browser.stop()
        NotificationCenter.default.post(name: NSNotification.Name.DocumentImporterScannerStateChanged, object: nil)
    }
}

extension DocumentImporter: ICDeviceBrowserDelegate {
    func deviceBrowser(_ browser: ICDeviceBrowser, didAdd device: ICDevice, moreComing: Bool) {
        device.delegate = self
        
        if !(device is ICScannerDevice) {
            device.requestOpenSession()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.DocumentImporterDeviceListChanged, object: nil)
    }
    
    func deviceBrowser(_ browser: ICDeviceBrowser, didRemove device: ICDevice, moreGoing moreComing: Bool) {
        device.requestCloseSession()
        NotificationCenter.default.post(name: NSNotification.Name.DocumentImporterDeviceListChanged, object: nil)
    }
}

extension DocumentImporter: ICCameraDeviceDelegate {
    func didRemove(_ device: ICDevice) {
        device.delegate = nil
    }

    func cameraDevice(_ camera: ICCameraDevice, didAdd item: ICCameraItem) {
        handleItem(item)
    }
    
    func cameraDevice(_ camera: ICCameraDevice, didAdd items: [ICCameraItem]) {
        for item in items {
            handleItem(item)
        }
    }
}

extension DocumentImporter: ICCameraDeviceDownloadDelegate {
    func didDownloadFile(_ file: ICCameraFile, error: Error?, options: [String : Any]? = nil, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            let notification = NSUserNotification()
            notification.identifier = NSUUID().uuidString
            notification.title = NSLocalizedString("NotificationDownloadCompletedErrorTitle", comment: "")
            notification.informativeText = error.localizedDescription
            NSUserNotificationCenter.default.scheduleNotification(notification)
        } else {
            let url = SettingsHandler.shared.importURL.appendingPathComponent(file.name, isDirectory: false)
            handleImageFile(at: url)
        }
    }
}

