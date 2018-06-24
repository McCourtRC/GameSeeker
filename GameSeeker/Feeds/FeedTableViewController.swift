//
//  FeedTableViewController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/12/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit
import SwiftMoment

class FeedTableViewController: GamesTableViewController {
    override func setup() {
        allowsInfiniteScroll = true
        
        networkHelper?
            .set(params: [
                "sort": "original_release_date:asc",
                "filter": "original_release_date:\(moment().startOf(.Weeks).format())|\(moment().add(100, .Years).format())",
            ])

        usesSearch = true
        
        title = "Upcoming"
    }
}
