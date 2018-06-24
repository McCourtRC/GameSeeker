//
//  SaveManager.swift
//  GameTracker
//
//  Created by Corey McCourt on 5/15/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation

class SaveManager {
    public static let shared = SaveManager()

    //CHANGE API KEY
    private let defaultApiKey = "API_KEY"
    var apiKey = ""
    var isDeafultApiKey : Bool {
        get {
            return apiKey == defaultApiKey
        }
    }

    var savedGames = [Int]() {
        didSet{
            self.save(savedGames as AnyObject, forKey: .savedGames)
        }
    }
    
    var hiddenGames = [Int]() {
        didSet{
            self.save(hiddenGames as AnyObject, forKey: .hiddenGames)
        }
    }
    
    var hiddenPlatforms = [String]() {
        didSet{
            self.save(hiddenPlatforms as AnyObject, forKey: .hiddenPlatforms)
        }
    }
    
    init() {
        self.savedGames = getArray(.savedGames)
        self.hiddenGames = getArray(.hiddenGames)
        self.hiddenPlatforms = getArray(.hiddenPlatforms)

        if getString(.apiKey) == "" {
            save(defaultApiKey as AnyObject, forKey: .apiKey)
        }
        
        self.apiKey = getString(.apiKey)
    }
    
    enum SaveKey: String {
        case savedGames = "savedGames"
        case hiddenGames = "hiddenGames"
        case hiddenPlatforms = "hiddenPlatforms"
        case apiKey = "apiKey"
        case userNotificationsAllowed = "userNotificationsAllowed"
        case systemNotificationsAllowed = "systemNotificationsAllowed"
    }
    
    func setSystemNotification(allowed: Bool) {
        save(allowed as AnyObject, forKey: .systemNotificationsAllowed)
        
        if UserDefaults.standard.object(forKey: SaveKey.userNotificationsAllowed.rawValue) == nil {
            save(allowed as AnyObject, forKey: .userNotificationsAllowed)
        }
    }
    
    func getNotificationsAllowed() -> Bool {
        return getBool(.userNotificationsAllowed) && getBool(.systemNotificationsAllowed)
    }
    
    func getArray<T>(_ key: SaveKey) -> [T] {
        if let value = UserDefaults.standard.object(forKey: key.rawValue) as? [T] {
            return value
        }
        return []
    }
    
    func getString(_ key: SaveKey) -> String {
        return UserDefaults.standard.object(forKey: key.rawValue) as? String ?? ""
    }
    
    func getBool(_ key: SaveKey) -> Bool {
        return UserDefaults.standard.object(forKey: key.rawValue) as? Bool ?? false
    }
    
    func save(_ object: AnyObject, forKey key: SaveKey) {
        UserDefaults.standard.set(object, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func update(apiKey: String) {
        save(apiKey as AnyObject, forKey: .apiKey)
        self.apiKey = apiKey
    }
    
    func clearApiKey() {
        save(defaultApiKey as AnyObject, forKey: .apiKey)
        self.apiKey = defaultApiKey
    }
    
    func reset() {
        savedGames = [Int]()
        hiddenGames = [Int]()
        hiddenPlatforms = [String]()
    }
}
