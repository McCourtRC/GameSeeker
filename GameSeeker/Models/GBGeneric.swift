//
//  GBGeneric.swift
//  GameSeeker
//
//  Created by Corey McCourt on 5/27/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import SwiftMoment

class GBGeneric: Mappable {
    var id: Int = -1
    var name: String = ""
    var api_detail_url: String = ""
    var site_detail_url: String = ""
    
    required init?(map: Map) {
        guard let _ : Int = map["id"].value(),
            let _ : String = map["name"].value(),
            let _ : String = map["api_detail_url"].value(),
            let _ : String = map["site_detail_url"].value()
            else
        {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        api_detail_url <- map["api_detail_url"]
        site_detail_url <- map["site_detail_url"]
    }
}
