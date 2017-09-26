//
//  NSMenuItemExtension.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa

extension NSMenuItem {
    func toggleState() -> Bool {
        state = NSControl.StateValue(rawValue: state.rawValue == 0 ? 1 : 0)
        return state.rawValue == 1
    }
}
