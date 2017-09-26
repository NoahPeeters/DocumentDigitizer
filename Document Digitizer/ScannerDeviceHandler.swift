//
//  ScannerDeviceHandler.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import ImageCaptureCore

class ScannerDeviceHandler: NSObject {
    
    let scanner: ICScannerDevice
    let documentDigitizeProcess = DocumentDigitizeProcess()
    
    var progressUpdateTimer: Timer?
    
    fileprivate let scannerDeviceMenuItem: ScannerDeviceMenuItem
    
    init(scanner: ICScannerDevice, menuItem: ScannerDeviceMenuItem) {
        self.scanner = scanner
        self.scannerDeviceMenuItem = menuItem
        super.init()
        
        scanner.delegate = self
    }
}

extension ScannerDeviceHandler: ICScannerDeviceDelegate {
    func deviceDidBecomeReady(_ device: ICDevice) {
        scannerDeviceMenuItem.functionalUnitTypesChanged()
    }
    
    func device(_ device: ICDevice, didOpenSessionWithError error: Error?) {
        scannerDeviceMenuItem.connectionStateChanged(true)
    }
    
    func device(_ device: ICDevice, didCloseSessionWithError error: Error?) {
        scannerDeviceMenuItem.connectionStateChanged(false)
    }
    
    func deviceDidChangeName(_ device: ICDevice) {
        scannerDeviceMenuItem.nameChanged()
    }
    
    func didRemove(_ device: ICDevice) {
        device.delegate = nil
    }
    
    func scannerDevice(_ scanner: ICScannerDevice, didScanTo url: URL) {
        DocumentDigitizer.shared.handleImageFile(at: url, documentDigitizeProcess: documentDigitizeProcess)
    }
    
    func scannerDevice(_ scanner: ICScannerDevice, didSelect functionalUnit: ICScannerFunctionalUnit, error: Error?) {
        scannerDeviceMenuItem.functionalUnitTypesChanged()
    }
    
    func scannerDevice(_ scanner: ICScannerDevice, didCompleteScanWithError error: Error?) {
        progressUpdateTimer?.invalidate()
        progressUpdateTimer = nil
    }
}

extension ScannerDeviceHandler: ScannerDeviceMenuItemDelegate {

    var name: String {
        return scanner.name ?? "Untitled Scanner"
    }
    
    var availableFunctionalUnitTypes: [ICScannerFunctionalUnitType] {
        return scanner.availableFunctionalUnitTypes.map {
            ICScannerFunctionalUnitType(rawValue: UInt(truncating: $0))!
        }
    }
    
    var selectedFunctionalUnitType: ICScannerFunctionalUnitType {
        return scanner.selectedFunctionalUnit.type
    }
    
    func toggleConnection() {
        if scanner.hasOpenSession {
            scanner.requestCloseSession()
        } else {
            scanner.requestOpenSession()
        }
    }
    
    
    func requestSelect(_ type: ICScannerFunctionalUnitType) {
        scanner.requestSelect(type)
    }
    
    func startScan() {
        let fu = scanner.selectedFunctionalUnit
        guard !fu.scanInProgress && !fu.overviewScanInProgress else {
            scanner.cancelScan()
            return
        }
        
        fu.measurementUnit = .inches
        
        fu.scanArea = NSRect(origin: CGPoint(x: 0, y: 0), size: fu.physicalSize)
        fu.resolution = SettingsHandler.shared.pdfDPI
        fu.bitDepth = .depth8Bits
        fu.pixelDataType = .RGB
        
        documentDigitizeProcess.showNotification(title: scanner.name ?? "Untitled Scanner", text: "Start Scanning")
        
        
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.documentDigitizeProcess.showNotification(
                title: self?.scanner.name ?? "Untitled Scanner",
                text: "Scanning Progress: \(round(fu.scanProgressPercentDone))%"
            )
        }
        
        scanner.downloadsDirectory = SettingsHandler.shared.importURL
        scanner.transferMode = .fileBased
        scanner.documentName = NSUUID().uuidString
        scanner.documentUTI = kUTTypeTIFF as String
        
        scanner.requestScan()
    }
}
