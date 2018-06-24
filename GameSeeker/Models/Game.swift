//
//  Game.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/12/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftMoment

class Game: Mappable {
    private var image : Image?
    
    var name : String = ""
    var attrName : NSAttributedString?
    var id: Int = 0
    var guid: String = ""
    var description : String = ""
    var webDescription: String = ""
    var releaseDate = Date()
    var displayReleaseDate : String = ""
    
    var platforms = [Platform]()
    var displayPlatforms = [Platform]()
    var developers = [GBGeneric]()
    var publishers = [GBGeneric]()
    var franchises = [GBGeneric]()
    var genres = [GBGeneric]()
    
    var humanTime : String = ""
    var pastHumanTime : String = ""
    var isSearchResult = false
    var originalIndex = 0
    var validForNotifications = false
    
    var images : [Image] = [Image]()

    var isSaved : Bool {
        get {
            return SaveManager.shared.savedGames.contains(id)
        }
    }
    
    var isHidden : Bool {
        get {
            if isSearchResult {
                return false
            }

            if SaveManager.shared.hiddenGames.contains(id) {
                return true
            }

            for platform in platforms {
                if !platform.isHidden {
                    return false
                }
            }

            return platforms.count > 0
        }
    }
    
    required init?(map: Map) {
        guard let _ : Int = map["id"].value(),
            let _ : String = map["guid"].value(),
            let _ : String = map["name"].value() else
        {
            return nil
        }
        
        let rd : String? = map["original_release_date"].value()
        if rd == nil {
            let month : Int = map["expected_release_month"].value() ?? 12
            let day : Int = map["expected_release_day"].value() ?? 31
            guard let year : Int = map["expected_release_year"].value(),
                let _ = moment([year, month, day]) else {
                    return nil
                }
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        guid <- map["guid"]
        name <- map["name"]
        description <- map["deck"]
        webDescription <- map["description"]
        platforms <- map["platforms"]
        
        developers <- map["developers"]
        publishers <- map["publishers"]
        franchises <- map["franchises"]
        genres <- map["genres"]
        
        image <- map["image"]
        images <- map["images"]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.8
        
        let attrString = NSMutableAttributedString(string: name)
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(.font, value:UIFont(name: "Oswald-Bold", size: 19)!, range:NSMakeRange(0, attrString.length))
        self.attrName = attrString
        
        if let image = self.image {
            images.insert(image, at: 0)
        }
        
        if let releaseDateString : String = map["original_release_date"].value(),
            let cleanedReleaseDateString = releaseDateString.split(separator: " ").first,
            let date = moment("\(cleanedReleaseDateString)")?.date
        {
            releaseDate = date
        } else if let year : Int = map["expected_release_year"].value() {
            var month : Int = map["expected_release_month"].value() ?? 0
            let day : Int = map["expected_release_day"].value() ?? 0

            validForNotifications = month != 0 && day != 0

            if month == 0 {
                month = 12
                displayReleaseDate = "\(year)"
                if let quarter : Int = map["expected_release_quarter"].value() {
                    switch quarter {
                    case 1:
                        displayReleaseDate = "Q1 \(year)"
                        month = 3
                    case 2:
                        displayReleaseDate = "Q2 \(year)"
                        month = 6
                    case 3:
                        displayReleaseDate = "Q3 \(year)"
                        month = 9
                    case 4:
                        displayReleaseDate = "Q4 \(year)"
                        month = 12
                    default: break
                    }
                }
            }
            
            if day == 0 {
                month += 1
            }
            
            if let date = moment([year, month, day])?.date {
                releaseDate = date
                if displayReleaseDate == "",
                    day == 0
                {
                    displayReleaseDate = moment(releaseDate).format("MMM yyyy")
                }
            }
        }
        
        if displayReleaseDate == "" {
            displayReleaseDate = moment(releaseDate).format("MMM dd, yyyy")
        }

        humanTime = moment(releaseDate).until()
        pastHumanTime = moment(releaseDate).from()
        var platAbbreviations = [String]()
        for platform in platforms {
            if !platAbbreviations.contains(platform.displayAbbreviation) {
                displayPlatforms.append(platform)
            }

            platAbbreviations.append(platform.displayAbbreviation)
        }
    }
    
    func getImage(withTag tag: Image.ImageTag) -> Image? {
        return getImage(withTags: [tag])
    }
    
    func getImage(withTags tags: [Image.ImageTag]) -> Image? {
        for tag in tags {
            for image in images {
                if image.tags.contains(tag) {
                    return image
                }
            }
        }

        return images.first
    }
    
    func save() {
        guard !isSaved else { return }
        
        SaveManager.shared.savedGames.append(id)
        NotificationManager.post(.gameUpdated, object: self)
    }
    
    func removeFromSaved() {
        guard isSaved else { return }
        
        if let index = SaveManager.shared.savedGames.index(of: id) {
            SaveManager.shared.savedGames.remove(at: index)
            NotificationManager.post(.gameUpdated, object: self)
        }
    }
    
    func hide() {
        guard !isHidden else { return }
        
        SaveManager.shared.hiddenGames.append(id)
        NotificationManager.post(.gameUpdated, object: self)
    }
    
    func removeFromHidden() {
        guard isHidden else { return }
        
        if let index = SaveManager.shared.hiddenGames.index(of: id) {
            SaveManager.shared.hiddenGames.remove(at: index)
            NotificationManager.post(.gameUpdated, object: self)
        }
    }
}
