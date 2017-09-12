//
//  NSNotificationNameExtension.swift
//  Document Importer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let DocumentImporterDeviceListChanged = NSNotification.Name("DocumentImporterDeviceListChanged")
    static let DocumentImporterScannerStateChanged = NSNotification.Name("DocumentImporterScannerStateChanged")
    static let SettingsHandlerImportPathChanged = NSNotification.Name("SettingsHandlerImportPathChanged")
    static let SettingsHandlerPDFDPIChanged = NSNotification.Name("SettingsHandlerPDFDPIChanged")
    static let TesseractLanguageListChanged = NSNotification.Name("TesseractLanguageListChanged")
    static let TesseractLanguageSelectionChanged = NSNotification.Name("TesseractLanguageSelectionChanged")
}
