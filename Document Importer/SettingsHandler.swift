//
//  SettingsHandler.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa

class SettingsHandler {
    static let shared = SettingsHandler()
    
    private static let importKey = "importKey"
    private static let convertKey = "convertKey"
    private static let autoOpenKey = "autoOpenKey"
    private static let importURLKey = "importURLKey"
    
    private let userDefaults = UserDefaults.standard
    
    /// Enable and disable scanning
    var scanningEnabled: Bool {
        get {
            return DocumentImporter.shared.scanningEnabled
        } set {
            DocumentImporter.shared.scanningEnabled = newValue
        }
    }
    
    /// enable and disable importing
    var importingEnabled: Bool {
        didSet {
            userDefaults.set(importingEnabled, forKey: SettingsHandler.importKey)
        }
    }
    
    /// enable and disable converting
    var convertingEnabled: Bool {
        didSet {
            userDefaults.set(convertingEnabled, forKey: SettingsHandler.convertKey)
        }
    }
    
    /// enable and disable auto Open
    var autoOpenEnabled: Bool {
        didSet {
            userDefaults.set(autoOpenEnabled, forKey: SettingsHandler.autoOpenKey)
        }
    }
    
    var importURL: URL {
        didSet {
            userDefaults.set(importURL, forKey: SettingsHandler.importURLKey)
        }
    }
    
    private static var defaultPath: URL {
        let string = NSString(string: "~/Documents").expandingTildeInPath
        
        return URL.init(fileURLWithPath: string)
        
    }
    
    private init() {
        importingEnabled = userDefaults.bool(forKey: SettingsHandler.importKey)
        convertingEnabled = userDefaults.bool(forKey: SettingsHandler.convertKey)
        autoOpenEnabled = userDefaults.bool(forKey: SettingsHandler.autoOpenKey)
        importURL = userDefaults.url(forKey: SettingsHandler.importURLKey) ?? SettingsHandler.defaultPath
        
        print(importURL.absoluteString)
    }
    
    func askUserForNewPath() {
        let openPanel = NSOpenPanel()
        
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
//        openPanel
        
//        openPanel.
        
    }
}
