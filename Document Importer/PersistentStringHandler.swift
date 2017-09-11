//
//  PersistentStringHandler.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

class PersistentStringHandler {
    
    open let stringsKey: String

    private let userDefaults = UserDefaults.standard
    private let notificationName: NSNotification.Name?
    
    var strings: Set<String> {
        didSet {
            userDefaults.set(Array(strings), forKey: stringsKey)
            if let notificationName = notificationName {
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        }
    }
    
    init(stringsKey: String, notificationName: NSNotification.Name?) {
        self.stringsKey = stringsKey
        self.notificationName = notificationName
        strings = Set(userDefaults.stringArray(forKey: stringsKey) ?? [])
    }
    
    func isEnabled(_ string: String) -> Bool {
        return strings.contains(string)
    }
    
    func enable(_ string: String) {
        strings.insert(string)
    }
    
    func disable(_ string: String) {
        strings.remove(string)
    }
    
    func update(_ string: String, enabled: Bool) {
        if enabled {
            enable(string)
        } else {
            disable(string)
        }
    }
}

class PersistentObjectHandler<T: StringIdentifiable>: PersistentStringHandler {
    
    override init(stringsKey: String, notificationName: NSNotification.Name?) {
        super.init(stringsKey: stringsKey, notificationName: notificationName)
    }
    
    func isEnabled(_ object: T) -> Bool {
        return super.isEnabled(object.stringIdentifier)
    }
    
    func enable(_ object: T) {
        super.enable(object.stringIdentifier)
    }
    
    func disable(_ object: T) {
        super.disable(object.stringIdentifier)
    }
    
    func update(_ object: T, enabled: Bool) {
        super.update(object.stringIdentifier, enabled: enabled)
    }
}


protocol StringIdentifiable {
    var stringIdentifier: String { get }
}

protocol CustomUserInterfaceString {
    var uiString: String { get }
}
