//
//  FunctionalUnitTypeMenuItem.swift
//  Document Importer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class FunctionalUnitTypeMenuItem: NSMenuItem {
    
    let functionalUnitType: ICScannerFunctionalUnitType
    let scannerDeviceMenuItemDelegate: ScannerDeviceMenuItemDelegate
    
    init(functionalUnitType: ICScannerFunctionalUnitType, scannerDeviceMenuItemDelegate: ScannerDeviceMenuItemDelegate) {
        self.functionalUnitType = functionalUnitType
        self.scannerDeviceMenuItemDelegate = scannerDeviceMenuItemDelegate
    
        
        super.init(title: functionalUnitType.name, action: #selector(clicked), keyEquivalent: "")
        self.target = self
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clicked() {
        scannerDeviceMenuItemDelegate.requestSelect(functionalUnitType)
    }
    
}

extension ICScannerFunctionalUnitType {
    var name: String {
        switch self {
        case .documentFeeder:
            return "Document Feeder"
        case .flatbed:
            return "Flatbed"
        case .negativeTransparency:
            return "Negative Transparency"
        case .positiveTransparency:
            return "Positive Transparency"
        }
    }
}
