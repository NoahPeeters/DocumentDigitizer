//
//  MenuBarController.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class MenuBarController: NSObject {

    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var importingMenuItem: NSMenuItem! {
        didSet {
            importingMenuItem.state = SettingsHandler.shared.importingEnabled ? 1 : 0
        }
    }
    
    @IBOutlet weak var importKeepOriginalMenuItem: NSMenuItem! {
        didSet {
            importKeepOriginalMenuItem.state = SettingsHandler.shared.importKeepOriginalEnabled ? 1 : 0
        }
    }
    
    @IBOutlet weak var convertMenuItem: NSMenuItem! {
        didSet {
            convertMenuItem.state = SettingsHandler.shared.convertingEnabled ? 1 : 0
        }
    }
    
    @IBOutlet weak var convertKeepOriginalMenuItem: NSMenuItem! {
        didSet {
            convertKeepOriginalMenuItem.state = SettingsHandler.shared.convertKeepOriginalEnabled ? 1 : 0
        }
    }
    
    @IBOutlet weak var autoOpenMenuItem: NSMenuItem! {
        didSet {
            autoOpenMenuItem.state = SettingsHandler.shared.autoOpenEnabled ? 1 : 0
        }
    }
    
    @IBOutlet weak var importPathMenuItem: NSMenuItem! {
        didSet {
            updateImportPathMenuItem()
        }
    }
    
    @IBOutlet weak var languagesMenu: NSMenu!
    @IBOutlet weak var devicesMenu: NSMenu!
    @IBOutlet weak var pdfDPIMenu: NSMenu! {
        didSet {
            updatePDFDPIMenu()
        }
    }
    
    private let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "StatusBarButtonImage")
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        refreshDeviceList()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DocumentImporterDeviceListChanged, object: nil, queue: nil) { [weak self] _ in
            self?.refreshDeviceList()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.DocumentImporterScannerStateChanged, object: nil, queue: nil) { [weak self] _ in
            self?.refreshDeviceList()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.SettingsHandlerImportPathChanged, object: nil, queue: nil) { [weak self] _ in
            self?.updateImportPathMenuItem()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TesseractLanguageListChanged, object: nil, queue: nil) { [weak self] _ in
            self?.refreshLanguagesList()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.TesseractLanguageSelectionChanged, object: nil, queue: nil) { [weak self] _ in
            self?.refreshLanguagesList()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.SettingsHandlerPDFDPIChanged, object: nil, queue: nil) { [weak self] _ in
            self?.updatePDFDPIMenu()
        }
    }
    
    private func refreshDeviceList() {
        devicesMenu.removeAllItems()
        
        let devices = DocumentImporter.shared.devices
        
        if devices.count == 0 {
            let userMessage = DocumentImporter.shared.scanningEnabled ? NSLocalizedString("ScanningNoDevicesFound", comment: "") : NSLocalizedString("ScanningScanningDisabled", comment: "")
            devicesMenu.addItem(NSMenuItem(title: userMessage, action: nil, keyEquivalent: ""))
        } else {
            for device in devices {
                if let scanner = device as? ICScannerDevice {
                    let item = ScannerDeviceMenuItem()
                    item.delegate = ScannerDeviceHandler(scanner: scanner, menuItem: item)
                    devicesMenu.addItem(item)
                } else {
                    let item = PersistentObjectMenuItem(device, persistentObjectHandler: SettingsHandler.persistentDeviceHandler)
                    devicesMenu.addItem(item)
                }
            }
        }
    }
    
    private func refreshLanguagesList() {
        languagesMenu.removeAllItems()
        
        let languageHandler = SettingsHandler.persistentLanguageHandler
        
        let languages = Tesseract.shared.languageList.sorted { (l1, l2) in
            let l1Enabled = languageHandler.isEnabled(l1)
            let l2Enabled = languageHandler.isEnabled(l2)
            
            if l1Enabled != l2Enabled {
                return l1Enabled
            }
            
            return l1.uiString.lowercased() < l2.uiString.lowercased()
            
        }
        
        for language in languages {
            let item = PersistentObjectMenuItem(language, persistentObjectHandler: languageHandler)
            languagesMenu.addItem(item)
        }
    }
    
    private func updatePDFDPIMenu() {
        for item in pdfDPIMenu.items {
            item.state = Int(item.title) == SettingsHandler.shared.pdfDPI ? 1 : 0
        }
    }
    
    private func updateImportPathMenuItem() {
        importPathMenuItem.title = SettingsHandler.shared.importURL.path
    }
    
    @IBAction func quitMenuItemClicked(_ sender: Any) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func toggleScanning(_ sender: NSMenuItem) {
        DocumentImporter.shared.scanningEnabled = sender.toggleState()
        refreshDeviceList()
    }
    
    @IBAction func toggleImporting(_ sender: NSMenuItem) {
        SettingsHandler.shared.importingEnabled = sender.toggleState()
    }
    
    @IBAction func toggleImportKeepOriginal(_ sender: NSMenuItem) {
        SettingsHandler.shared.importKeepOriginalEnabled = sender.toggleState()
    }
    
    @IBAction func toggleConverting(_ sender: NSMenuItem) {
        SettingsHandler.shared.convertingEnabled = sender.toggleState()
    }
    
    @IBAction func toggleConvertKeepOriginal(_ sender: NSMenuItem) {
        SettingsHandler.shared.convertKeepOriginalEnabled = sender.toggleState()
    }
    
    @IBAction func toggleAutoOpen(_ sender: NSMenuItem) {
        SettingsHandler.shared.autoOpenEnabled = sender.toggleState()
    }
    
    @IBAction func pathChangeMenuItemClicked(_ sender: Any) {
        SettingsHandler.shared.askUserForNewPath()
    }
    
    @IBAction func openImportPath(_ sender: Any) {
        NSWorkspace.shared().open(SettingsHandler.shared.importURL)
    }
    
    @IBAction func pdfDPIMenuItemClicked(_ sender: NSMenuItem) {
        SettingsHandler.shared.pdfDPI = Int(sender.title)!
    }
    
}
