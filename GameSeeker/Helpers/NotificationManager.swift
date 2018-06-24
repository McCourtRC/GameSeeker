//
//  NotificationManager.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/16/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation

open class NotificationManager {
    
    fileprivate static let notificationCenter = NotificationCenter.init();
    
    public enum Notifications : String {
        case gameUpdated
        case platformsUpdated
    }
    
    public static func add(_ observer: Any, selector: Selector, notification: Notifications, object: Any? = nil) {
        notificationCenter.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: notification.rawValue), object: object)
    }
    
    public static func remove(_ observer: Any) {
        notificationCenter.removeObserver(observer)
    }
    
    public static func post(_ notification: Notifications, object: Any? = nil) {
        notificationCenter.post(name: NSNotification.Name(rawValue: notification.rawValue), object: object)
    }
}
