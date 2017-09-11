//
//  SettingsHandler.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class SettingsHandler: NSObject {
    static let shared = SettingsHandler()
    static let persistentDeviceHandler = PersistentObjectHandler<ICDevice>(stringsKey: "DevicesIDStrings", notificationName: nil)
    static let persistentLanguageHandler = PersistentObjectHandler<TesseractLanguage>(stringsKey: "LanguageStrings", notificationName: NSNotification.Name.TesseractLanguageSelectionChanged)
    
    private static let importKey = "importEnabled"
    private static let importKeepOriginalKey = "importKeepOriginal"
    private static let convertKey = "converEnabled"
    private static let convertKeepOriginalKey = "convertKeepOriginal"
    private static let autoOpenKey = "autoOpenEnabled"
    private static let importURLKey = "importURL"
    
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
    
    /// enable and disable import keep original
    var importKeepOriginalEnabled: Bool {
        didSet {
            userDefaults.set(importKeepOriginalEnabled, forKey: SettingsHandler.importKeepOriginalKey)
        }
    }
    
    /// enable and disable converting
    var convertingEnabled: Bool {
        didSet {
            userDefaults.set(convertingEnabled, forKey: SettingsHandler.convertKey)
        }
    }
    
    /// enable and disable convert keep original
    var convertKeepOriginalEnabled: Bool {
        didSet {
            userDefaults.set(convertKeepOriginalEnabled, forKey: SettingsHandler.convertKeepOriginalKey)
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
            NotificationCenter.default.post(name: NSNotification.Name.SettingsHandlerImportPathChanged, object: nil)
        }
    }
    
    var selectedLanguages: [TesseractLanguage] {
        return TesseractLanguage.listFromArray(Array(SettingsHandler.persistentLanguageHandler.strings))
    }
    
    private static var defaultPath: URL {
        let string = NSString(string: "~/Documents").expandingTildeInPath
        
        return URL.init(fileURLWithPath: string)
    }
    
    override private init() {
        importingEnabled = userDefaults.bool(forKey: SettingsHandler.importKey)
        importKeepOriginalEnabled = userDefaults.bool(forKey: SettingsHandler.importKeepOriginalKey)
        convertingEnabled = userDefaults.bool(forKey: SettingsHandler.convertKey)
        convertKeepOriginalEnabled = userDefaults.bool(forKey: SettingsHandler.convertKeepOriginalKey)
        autoOpenEnabled = userDefaults.bool(forKey: SettingsHandler.autoOpenKey)
        importURL = userDefaults.url(forKey: SettingsHandler.importURLKey) ?? SettingsHandler.defaultPath
    }
    
    func askUserForNewPath() {
        let openPanel = NSOpenPanel()
        
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = importURL
        openPanel.title = NSLocalizedString("OpenPanelTitle", comment: "")
        openPanel.prompt = NSLocalizedString("OpenPanelPrompt", comment: "")
        openPanel.begin { [weak self] result in
            guard result == NSFileHandlingPanelOKButton, openPanel.urls.count == 1 else {
                return
            }
            
            self?.importURL = openPanel.urls[0]
        }
    }
}
