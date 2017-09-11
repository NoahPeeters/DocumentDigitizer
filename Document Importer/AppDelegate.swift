//
//  AppDelegate.swift
//  Document Importer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        NSUserNotificationCenter.default.delegate = self
        DocumentImporter.shared.startScanning()
        
        Tesseract.shared.reloadLanguageList()
    }

    // Show all notifications
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard let urlString = notification.identifier, let url = URL(string: urlString) else {
            return
        }
        
        NSWorkspace.shared().open(url)
    }
}

