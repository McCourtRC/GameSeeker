//
//  Platform.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/16/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import SwiftMoment

class Platform: Mappable {

    private static let currentDecade = "\(Int(floor(Double(moment().year / 10)) * 10))'s"
    
    var id: Int = 0
    var guid: String = ""
    var name : String = ""
    var abbreviation : String = ""
    var displayAbbreviation : String {
        get {
            return Platform.abbreviations[abbreviation] ?? abbreviation
        }
    }
    var company : String = ""
    var deck : String = ""
    var image : Image?
    var releaseDate : Moment?
    var decade : String = ""
    
    var color : UIColor {
        get {
            switch displayAbbreviation {
            case "XBOX", "X360", "XONE":
                return Platform.colors["xbox"]!
            case "PS4", "PS3", "PS2", "PS1", "PSP", "VITA":
                return Platform.colors["playstation"]!
            case "SWITCH", "Wii", "WiiU", "3DS":
                return Platform.colors["nintendo"]!
            case "PC", "MAC":
                return UIColor.darkGray
            default:
                return .gray
            }
        }
    }
    
    required init?(map: Map) {
        guard let _ : Int = map["id"].value(),
            let _ : String = map["name"].value(),
            let abbr : String = map["abbreviation"].value() else
        {
            return nil
        }
        
        if let _ : String = map["release_date"].value() {
            var installBase : String? = map["install_base"].value()
            if ["LIN", "ARC", "BROW"].contains(abbr) {
                installBase = "9999999"
            }

            guard installBase != nil else {
                return nil
            }
            
            if let abbreviation : String = map["abbreviation"].value(),
                Platform.notReal.contains(abbreviation)
            {
                return nil
            }
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        abbreviation <- map["abbreviation"]
        
        guid <- map["guid"]
        company <- map["company.name"]
        deck <- map["deck"]
        image <- map["image"]
        if let releaseDateString : String = map["release_date"].value(),
            let cleanedReleaseDateString = releaseDateString.split(separator: " ").first,
            let date = moment("\(cleanedReleaseDateString)")
        {
            releaseDate = date
            decade = "\(Int(floor(Double(date.year / 10)) * 10))'s"
            
            if decade == Platform.currentDecade ||
                ["Mac", "PC"].contains(name)
            {
                decade = "Current"
            }
        }
    }
    
    private static let colors = [
        "xbox": UIColor.init(red: 46.0/255.0, green: 171.0/255.0, blue: 16.0/255.0, alpha: 1),
        "playstation": UIColor.init(red: 0, green: 0, blue: 114.0/255.0, alpha: 1),
        "nintendo": UIColor.red,
    ]
    
    private static let abbreviations = [
        "NSW": "SWITCH",
        "PSNV": "VITA",
        "3DSE": "3DS",
        "PS3N": "PS3",
        "PSPN": "PSP",
        "XBGS": "X360",
        "DSI": "DS",
        "N3DS": "3DS",
    ]
    
    private static let notReal = [
        "PSNV",
        "3DSE",
        "PS3N",
        "PSPN",
        "XBGS",
        "DSI",
        "N3DS",
    ]
    
    var isHidden : Bool {
        get {
            return SaveManager.shared.hiddenPlatforms.contains(displayAbbreviation)
        }
    }
    
    func toggleHidden() {
        if isHidden {
            removeFromHidden()
        } else {
            hide()
        }
    }
    
    func hide() {
        guard !isHidden else { return }
        
        SaveManager.shared.hiddenPlatforms.append(displayAbbreviation)
    }
    
    func removeFromHidden() {
        guard isHidden else { return }
        
        if let index = SaveManager.shared.hiddenPlatforms.index(of: displayAbbreviation) {
            SaveManager.shared.hiddenPlatforms.remove(at: index)
        }
    }
}
