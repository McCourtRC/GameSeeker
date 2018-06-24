//
//  Image.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/18/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import ObjectMapper

class Image : Mappable {
    enum ImageSize: String {
        case original = "/original/"
        case scaleAvatar = "/scale_avatar/"
        case scaleLarge = "/scale_large/"
        case scaleMedium = "/scale_medium/"
        case scaleSmall = "/scale_small/"
        case screenKubrick = "/screen_kubrick/"
        case screenMedium = "/screen_medium/"
        case squareAvatar = "/square_avatar/"
        case squareMini = "/square_mini/"
    }
    
    enum ImageTag {
        case all
        case promo
        case screenshot
        case boxart
        case concept
        case other
    }
    
    var orignalUrlString : String = ""
    var tags = [ImageTag]()

    required init?(map: Map) {
        guard let _ : String = map["original"].value() ?? map["original_url"].value() else {
            return nil
        }
    }
    
    func scoreBy(tags: [ImageTag]) -> Int {
        for (index, tag) in tags.enumerated() {
            if self.tags.contains(tag) {
                return index
            }
        }
        
        return tags.count
    }
    
    func mapping(map: Map) {
        orignalUrlString <- map["original"]
        orignalUrlString <- map["original_url"]
        
        if let tagString : String = map["tags"].value() ?? map["image_tags"].value() {
            let tagComponents = tagString.split(separator: ",")
            for comp in tagComponents {
                if comp.lowercased().contains("promo") { tags.append(.promo) }
                else if comp.lowercased().contains("screenshot") { tags.append(.screenshot) }
                else if comp.lowercased().contains("box art") ||
                    comp.lowercased().contains("boxart") ||
                    comp.lowercased().contains("cover art") { tags.append(.boxart) }
                else if comp.lowercased().contains("all images") { tags.append(.all) }
                else if comp.lowercased().contains("concept") { tags.append(.concept) }
                else {
                    tags.append(.other)
                }
            }
        }
    }
    
    func urlFor(size: ImageSize) -> URL? {
        return URL(string: orignalUrlString.replacingOccurrences(of: "/original/", with: size.rawValue))
    }
}
