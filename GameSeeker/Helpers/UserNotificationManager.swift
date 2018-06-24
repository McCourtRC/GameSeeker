//
//  NotificationManager.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/23/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import UserNotifications
import PromiseKit
import SwiftMoment

class UserNotificationManager {
    
    private static let notificationCenter = UNUserNotificationCenter.current()
    private static let options: UNAuthorizationOptions = [.alert]
    
    public static func setup() {
        NotificationManager.add(self, selector: #selector(handleGameChange(notification:)), notification: .gameUpdated)
    }
    
    public static func getAuthorizationStatus() -> Promise<(Bool, Error?)> {
        return Promise { seal in
            notificationCenter.requestAuthorization(options: options) { (granted, error) in
                SaveManager.shared.setSystemNotification(allowed: granted)
                seal.fulfill((granted, error))
            }
        }
    }
    
    @objc private static func handleGameChange(notification: Notification) {
        guard let game = notification.object as? Game else { return }

        if UserDefaults.standard.object(forKey: SaveManager.SaveKey.systemNotificationsAllowed.rawValue) == nil {
            getAuthorizationStatus().done { (granted, error) in
                SaveManager.shared.setSystemNotification(allowed: granted)
    
                if granted {
                    self.handle(game: game)
                }
            }.catch { _ in }
        } else {
            self.handle(game: game)
        }
    }
    
    private static func handle(game: Game) {
        if game.isSaved {
            scheduleNotitication(withGame: game)
        } else {
            cancelNotification(forGame: game)
        }
    }
    
    public static func scheduleNotitication(withGame game: Game) {
        scheduleNotitications(withGames: [game])
    }
    
    public static func scheduleNotitications(withGames games: [Game]) {
        let games = games.filter { $0.validForNotifications }
        guard games.count > 0,
            SaveManager.shared.getNotificationsAllowed() else { return }
        
        firstly {
            Guarantee(resolver: notificationCenter.getNotificationSettings)
        }.done { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            for game in games {
                let date = moment(game.releaseDate)
                
                scheduleNotification(withTitle: "\(game.name) releases today!",
                    body: "",
                    date: date,
                    andIdentifier: game.guid)
                
                scheduleNotification(withTitle: "\(game.name) releases in 1 week!",
                    body: "",
                    date: date.subtract(1, .Weeks),
                    andIdentifier: "\(game.guid)-1")
            }
        }
    }
    
    public static func cancelAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        print("All Notifications removed")
    }
    
    public static func cancelNotification(forGame game: Game) {
        let ids = [game.guid, "\(game.guid)-1"]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: ids)
        print("Notifications removed: \(ids)")
    }
    
    private static func scheduleNotification(withTitle title: String, body: String, date: Moment, andIdentifier identifier: String) {
        guard !date.isInThePast() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        let components = date.getComponents()
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            } else {
                print("Notification add: \(title) - \(body)")
            }
        })
    }
}
