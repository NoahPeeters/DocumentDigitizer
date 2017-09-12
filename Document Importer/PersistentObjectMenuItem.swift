//
//  PersistentObjectMenuItem.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class PersistentObjectMenuItem<T: StringIdentifiable & CustomUserInterfaceString>: NSMenuItem {
    
    private var object: T
    private var persistentObjectHandler: PersistentObjectHandler<T>
    
    init(_ object: T, persistentObjectHandler: PersistentObjectHandler<T>) {
        self.object = object
        self.persistentObjectHandler = persistentObjectHandler
        super.init(title: object.uiString, action: #selector(clicked), keyEquivalent: "")
        target = self
        state = persistentObjectHandler.isEnabled(object) ? 1 : 0
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clicked() {
        persistentObjectHandler.update(object, enabled: toggleState())
    }
}
