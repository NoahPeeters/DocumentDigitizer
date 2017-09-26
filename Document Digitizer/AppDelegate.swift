//
//  AppDelegate.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 11.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Cocoa


var disabledNotifications: Set<String> = []

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSDocumentController.shared.clearRecentDocuments(nil)
        NSUserNotificationCenter.default.delegate = self
        DocumentDigitizer.shared.startScanning()
        
        Tesseract.shared.reloadLanguageList()
    }
    
    // Show all notifications
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        NSUserNotificationCenter.default.removeDeliveredNotification(notification)
        guard let urlString = notification.userInfo?["url"] as? String, let url = URL(string: urlString) else {
            if let identifier = notification.identifier {
                disabledNotifications.insert(identifier)
            }
            return
        }
        
        NSWorkspace.shared.open(url)
    }
}


extension NSUserNotificationCenter {
    func removeDeliveredNotification(withIdentifier identifier: String) {
        let notification = NSUserNotification()
        notification.identifier = identifier
        removeDeliveredNotification(notification)
    }
}
