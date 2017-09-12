//
//  NSNotificationNameExtension.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let DocumentDigitizerDeviceListChanged = NSNotification.Name("DocumentDigitizerDeviceListChanged")
    static let DocumentDigitizerScannerStateChanged = NSNotification.Name("DocumentDigitizerScannerStateChanged")
    static let SettingsHandlerImportPathChanged = NSNotification.Name("SettingsHandlerImportPathChanged")
    static let SettingsHandlerPDFDPIChanged = NSNotification.Name("SettingsHandlerPDFDPIChanged")
    static let TesseractLanguageListChanged = NSNotification.Name("TesseractLanguageListChanged")
    static let TesseractLanguageSelectionChanged = NSNotification.Name("TesseractLanguageSelectionChanged")
}
