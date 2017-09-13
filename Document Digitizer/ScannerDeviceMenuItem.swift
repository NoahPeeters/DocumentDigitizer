//
//  ScannerDeviceMenuItem.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class ScannerDeviceMenuItem: NSMenuItem {
    
    var delegate: ScannerDeviceMenuItemDelegate? {
        didSet {
            guard let delegate = delegate else {
                return
            }
            
            self.title = delegate.name
        }
    }
    
    var connectMenuItem: NSMenuItem!
    var functionalUnitTypeMenuItem: NSMenuItem!
    var functionalUnitTypeMenu: NSMenu!
    var scanMenuItem: NSMenuItem!
    
    init() {
        super.init(title: "", action: nil, keyEquivalent: "")
        
        connectMenuItem = NSMenuItem(title: "Connect", action: #selector(toggleConnection), keyEquivalent: "")
        connectMenuItem.target = self
        
        scanMenuItem = NSMenuItem(title: "Scan", action: #selector(startScan), keyEquivalent: "")
        scanMenuItem.target = self
        scanMenuItem.isEnabled = false
        
        
        functionalUnitTypeMenu = NSMenu()
        
        functionalUnitTypeMenuItem = NSMenuItem(title: "Type", action: nil, keyEquivalent: "")
        functionalUnitTypeMenuItem.isEnabled = false
        
        functionalUnitTypeMenuItem.submenu = functionalUnitTypeMenu
        
        
        let submenu = NSMenu()
        submenu.autoenablesItems = false
        submenu.addItem(connectMenuItem)
        submenu.addItem(functionalUnitTypeMenuItem)
        submenu.addItem(scanMenuItem)
        
        self.submenu = submenu
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleConnection() {
        delegate?.toggleConnection()
        connectMenuItem.isEnabled = false
        connectMenuItem.title = "Connecting..."
    }
    
    func startScan() {
        delegate?.startScan()
    }
    
    func connectionStateChanged(_ connected: Bool) {
        connectMenuItem.isEnabled = true
        if connected {
            connectMenuItem.title = "Disconnect"
        } else {
            connectMenuItem.title = "Connect"
        }
        functionalUnitTypeMenuItem.isEnabled = connected
        scanMenuItem.isEnabled = connected
    }
    
    func nameChanged() {
        guard let delegate = delegate else {
            return
        }
        self.title = delegate.name
    }
    
    func functionalUnitTypesChanged() {
        guard let delegate = delegate else {
            return
        }
    
        functionalUnitTypeMenu.removeAllItems()
        
        let availableFunctionalUnitTypes = delegate.availableFunctionalUnitTypes
        
        for functionalUnitType in availableFunctionalUnitTypes {
            let item = FunctionalUnitTypeMenuItem(functionalUnitType: functionalUnitType, scannerDeviceMenuItemDelegate: delegate)
            item.state = functionalUnitType == delegate.selectedFunctionalUnitType ? 1 : 0
            functionalUnitTypeMenu.addItem(item)
        }
    }
}



protocol ScannerDeviceMenuItemDelegate {
    var name: String { get }
    var availableFunctionalUnitTypes: [ICScannerFunctionalUnitType] { get }
    var selectedFunctionalUnitType: ICScannerFunctionalUnitType { get }
    
    func toggleConnection()
    func requestSelect(_: ICScannerFunctionalUnitType)
    func startScan()
}
