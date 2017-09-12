//
//  DocumentDigitizeProcess.swift
//  Document Digitizer
//
//  Created by Noah Peeters on 12.09.17.
//  Copyright © 2017 Noah Peeters. All rights reserved.
//

import Foundation

class DocumentDigitizeProcess {
    private(set) var uuid: NSUUID = NSUUID()
    
    private func newNotification() -> NSUserNotification {
        let notification = NSUserNotification()
        notification.identifier = uuid.uuidString
        return notification
    }
    
    func showNotification(title: String, text: String, userInfo: [String: Any]? = nil, actionButtonTitle: String? = nil) {
        guard !disabledNotifications.contains(uuid.uuidString) || actionButtonTitle != nil else {
            return
        }
        
        let notification = self.newNotification()
        notification.title = title
        notification.informativeText = text
        notification.userInfo = userInfo
        notification.actionButtonTitle = actionButtonTitle ?? ""
        notification.hasActionButton = actionButtonTitle != nil
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
    
    func showNotification(localizedTitle: String, text: String, userInfo: [String: Any]? = nil, localizedActionButtonTitle: String? = nil) {
        
        let actionButtonTitle: String? = localizedActionButtonTitle != nil ? NSLocalizedString(localizedActionButtonTitle!, comment: "") : nil
        
        showNotification(title: NSLocalizedString(localizedTitle, comment: ""), text: text, userInfo: userInfo, actionButtonTitle: actionButtonTitle)
    }
    
    func removeDeliverdNotifications() {
        print("hide")
        NSUserNotificationCenter.default.removeDeliveredNotification(withIdentifier: self.uuid.uuidString)
    }
}
