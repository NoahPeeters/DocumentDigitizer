//
//  PersistentDeviceHandler.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation
import ImageCaptureCore

class PersistentDeviceHandler {
    static let shared = PersistentDeviceHandler()
    
    private static let devicesIDStringsKey = "DevicesIDStrings"
    
    private let userDefaults = UserDefaults.standard
    
    private var devicesIDStrings: Set<String> {
        didSet {
            userDefaults.set(Array(devicesIDStrings), forKey: PersistentDeviceHandler.devicesIDStringsKey)
        }
    }
    
    private init() {
        devicesIDStrings = Set( userDefaults.stringArray(forKey: PersistentDeviceHandler.devicesIDStringsKey) ?? [])
    }
    
    func isDeviceEnabled(_ device: ICDevice) -> Bool {
        guard let idString = device.persistentIDString else {
            return false
        }
        
        return devicesIDStrings.contains(idString)
    }
    
    @discardableResult func enableDevice(_ device: ICDevice) -> Bool {
        guard let idString = device.persistentIDString, !devicesIDStrings.contains(idString) else {
            return false
        }
        
        devicesIDStrings.insert(idString)
        return true
    }
    
    @discardableResult func disableDevice(_ device: ICDevice) -> Bool {
        guard let idString = device.persistentIDString else {
            return false
        }
        
        return devicesIDStrings.remove(idString) != nil
    }
    
    @discardableResult func updateDevice(_ device: ICDevice, enabled: Bool) -> Bool {
        if enabled {
            return enableDevice(device)
        } else {
            return disableDevice(device)
        }
    }
}
