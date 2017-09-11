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
            ICDeviceLocationTypeMask.local.rawValue |
            ICDeviceLocationTypeMask.bluetooth.rawValue
        )!
    }
    
    fileprivate func handleItem(_ item: ICCameraItem) {
        guard SettingsHandler.shared.importingEnabled,
            item.uti == kUTTypeImage as String,
            PersistentDeviceHandler.shared.isDeviceEnabled(item.device),
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
    
    fileprivate func convertFile(_ file: ICCameraFile, withURL url: URL) {
        
        let outputURL = url.deletingPathExtension()
        let outputURLWithExtension = outputURL.appendingPathExtension("pdf")
        
        let process = Process()
        process.currentDirectoryPath = SettingsHandler.shared.importURL.path
        process.launchPath = "/usr/local/bin/tesseract"
        process.arguments = [url.path, outputURL.path, "pdf"]
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            //launch and wait
            process.launch()
            process.waitUntilExit()
            
            self?.importCompleted(ofFile: file, withURL: outputURLWithExtension)
            
            if !SettingsHandler.shared.convertKeepOriginalEnabled,
                FileManager.default.fileExists(atPath: outputURLWithExtension.path) {
                try? FileManager.default.removeItem(at: url)
            }
        }
        
    }
    
    fileprivate func importCompleted(ofFile file: ICCameraFile, withURL url: URL) {
        if SettingsHandler.shared.autoOpenEnabled {
            NSWorkspace.shared().open(url)
        }

        let notification = NSUserNotification()
        notification.title = NSLocalizedString("NotificationDownloadCompletedTitle", comment: "")
        notification.informativeText = file.name
        notification.identifier = url.absoluteString
        notification.hasActionButton = true
        notification.actionButtonTitle = NSLocalizedString("NotificationDownloadCompletedOpenButton", comment: "")
        NSUserNotificationCenter.default.scheduleNotification(notification)
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
        device.requestOpenSession()
        
        NotificationCenter.default.post(name: NSNotification.Name.DocumentImporterDeviceListChanged, object: nil)
    }
    
    func deviceBrowser(_ browser: ICDeviceBrowser, didRemove device: ICDevice, moreGoing moreComing: Bool) {
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
            notification.identifier = file.name
            notification.title = NSLocalizedString("NotificationDownloadCompletedErrorTitle", comment: "")
            notification.informativeText = error.localizedDescription
            NSUserNotificationCenter.default.scheduleNotification(notification)
        } else {
            let url = SettingsHandler.shared.importURL.appendingPathComponent(file.name, isDirectory: false)
            if SettingsHandler.shared.convertingEnabled {
                convertFile(file, withURL: url)
            } else {
                importCompleted(ofFile: file, withURL: url)
            }
        }
    }
}

extension NSNotification.Name {
    static let DocumentImporterDeviceListChanged = NSNotification.Name("DocumentImporterDeviceListChanged")
    static let DocumentImporterScannerStateChanged = NSNotification.Name("DocumentImporterScannerStateChanged")
    static let SettingsHandlerImportPathChanged = NSNotification.Name("SettingsHandlerImportPathChanged")
}
