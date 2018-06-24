//
//  SavedTableViewController.swift
//  GameTracker
//
//  Created by Corey McCourt on 5/15/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class SavedTableViewController: GamesTableViewController {
    var ids = [String]()
    
    var emptyImageView = UIImageView(image: #imageLiteral(resourceName: "saved-empty"))
    
    override func setup() {
        NotificationManager.add(self, selector: #selector(gameUpdated(notification:)), notification: .gameUpdated)
        
        view.backgroundColor = .darkGray
        tableView.backgroundColor = .clear
        view.insertSubview(emptyImageView, at: 0)
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        title = "Following"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let gameIds = SaveManager.shared.savedGames.map {"\($0)"}
        emptyImageView.isHidden = gameIds.count > 0
        if !gameIds.elementsEqual(ids) {
            ids = gameIds
            networkHelper?
                .set(forceVisible: true)
                .set(params: [
                    "filter": "id:\(SaveManager.shared.savedGames.map {"\($0)"}.joined(separator: "|"))"
                    ])
            
            refresh()
        }
        
        navigationItem.rightBarButtonItem = nil
    }

    @objc func gameUpdated(notification: Notification) {
        if let game = notification.object as? Game,
            ids.contains("\(game.id)")
        {
            delay(0.5) {
                self.removeUnFollowed()
            }
        }
    }
    
    func removeUnFollowed() {
        var indexPaths = [IndexPath]()
        var sectionChanges = IndexSet()
        for (section, sectionName) in sections.enumerated() {
            var sectionChange = true
            for (row, game) in gamesFor(section: sectionName).enumerated() {
                if !game.isSaved {
                    indexPaths.append(IndexPath(row: row, section: section))
                } else {
                    sectionChange = false
                }
            }
            if sectionChange {
                sectionChanges.insert(section)
            }
        }
        
        for section in gamesBySection {
            gamesBySection[section.key] = section.value.filter { $0.isSaved }
            if gamesBySection[section.key]?.count == 0 {
                gamesBySection.removeValue(forKey: section.key)
                if let index = sections.index(of: section.key) {
                    sections.remove(at: index)
                }
            }
        }
        
        tableView.beginUpdates()
        tableView.deleteSections(sectionChanges, with: .fade)
        tableView.deleteRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
        
        emptyImageView.isHidden = sections.count > 0
    }
    
    override func gamesUpdated() {
        UserNotificationManager.scheduleNotitications(withGames: games)
    }
}
