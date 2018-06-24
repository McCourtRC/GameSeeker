//
//  ApiResult.swift
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

class ApiResult<T : Mappable>: Mappable {
    var error : String = ""
    var limit : Int = 0
    var offset : Int = 0
    var pageResults : Int = 0
    var totalResults : Int = 0
    var statusCode : Int = 0
    var results : [T]?
    var result : T?

    var isMore : Bool {
        get {
            return offset + pageResults < totalResults
        }
    }
    
    required init?(map: Map) {
        guard let _ : Int = map["offset"].value(),
            let _ : Int = map["limit"].value(),
            let _ : Int = map["number_of_page_results"].value(),
            let _ : Int = map["number_of_total_results"].value() else
        {
            return nil
        }
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        limit <- map["limit"]
        offset <- map["offset"]
        pageResults <- map["number_of_page_results"]
        totalResults <- map["number_of_total_results"]
        statusCode <- map["status_code"]
        results <- map["results"]
        result <- map["results"]
    }
}
