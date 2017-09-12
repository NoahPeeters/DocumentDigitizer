//
//  ImportProcess.swift
//  Document Importer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

class ImportProcess {
    private(set) var uuid: NSUUID = NSUUID()
    
    private func newNotification() -> NSUserNotification {
        let notification = NSUserNotification()
        notification.identifier = uuid.uuidString
        return notification
    }
    
    func showNotification(title: String, text: String, userInfo: [String: Any]? = nil) {
        let notification = newNotification()
        notification.title = title
        notification.informativeText = text
        notification.userInfo = userInfo
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
    
    func showNotification(localizedTitle: String, text: String, userInfo: [String: Any]? = nil) {
        showNotification(title: NSLocalizedString(localizedTitle, comment: ""), text: text)
    }
    
    func removeDeliverdNotifications() {
        NSUserNotificationCenter.default.removeDeliveredNotification(withIdentifier: uuid.uuidString)
    }
}
