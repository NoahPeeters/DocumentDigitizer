//
//  DeviceMenuItem.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class DeviveMenuItem: NSMenuItem {
    
    private weak var device: ICDevice?
    
    init(_ device: ICDevice) {
        self.device = device
        super.init(title: device.name ?? NSLocalizedString("DefaultDeviceName", comment: ""), action: #selector(clicked), keyEquivalent: "")
        target = self
        state = PersistentDeviceHandler.shared.isDeviceEnabled(device) ? 1 : 0
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clicked() {
        guard let device = device else {
            return
        }
        
        PersistentDeviceHandler.shared.updateDevice(device, enabled: toggleState())
    }
}
