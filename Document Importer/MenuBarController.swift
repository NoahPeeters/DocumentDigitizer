//
//  MenuBarController.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa

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
    
    @IBOutlet weak var devicesMenu: NSMenu!
    private let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    
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
    }
    
    private func refreshDeviceList() {
        devicesMenu.removeAllItems()
        
        let devices = DocumentImporter.shared.devices
        
        if devices.count == 0 {
            let userMessage = DocumentImporter.shared.scanningEnabled ? NSLocalizedString("ScanningNoDevicesFound", comment: "") : NSLocalizedString("ScanningScanningDisabled", comment: "")
            devicesMenu.addItem(NSMenuItem(title: userMessage, action: nil, keyEquivalent: ""))
        } else {
            for device in devices {
                devicesMenu.addItem(DeviveMenuItem(device))
            }
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
}
