//
//  NSMenuItemExtension.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa

extension NSMenuItem {
    func toggleState() -> Bool {
        state = state == 0 ? 1 : 0
        return state == 1
    }
}
