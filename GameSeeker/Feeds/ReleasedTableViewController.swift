//
//  ReleasedTableViewController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/22/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit
import SwiftMoment

class ReleasedTableViewController: GamesTableViewController {
    override func setup() {
        allowsInfiniteScroll = true
        
        networkHelper?
            .set(params: [
                "sort": "original_release_date:desc",
                "filter": "original_release_date:\(moment().subtract(100, .Years).format())|\(moment().format())",
                ])
        
        usesSearch = true
        
        title = "Released"
    }
    
    override func processGames(_ games: [Game], append: Bool = false, sort: Bool = true, preventReload: Bool = false) {
        if !append {
            sections = [String]()
            gamesBySection = [String : [Game]]()
            self.games = games
        } else {
            self.games += games
        }
        
        let _ = games.sorted {
            return sort ? $0.releaseDate.compare($1.releaseDate) == .orderedDescending : true
            }.filter {
                return !$0.isHidden || showHidden
            }.map {
                let time = $0.pastHumanTime
                if !self.sections.contains(time) {
                    self.sections.append(time)
                    self.gamesBySection[time] = [Game]()
                }
                self.gamesBySection[time]?.append($0)
        }
        
        if !preventReload {
            self.tableView.reloadData()
        }
    }
}
