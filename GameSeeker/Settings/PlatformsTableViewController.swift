//
//  SettingsTableViewController.swift
//  GameTracker
//
//  Created by Corey McCourt on 5/18/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class PlatformsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    var toggleOn = false
    var platforms = [Platform]()
    var platformsBySection = [String : [Platform]]()
    var networkHelper = NetworkHelper()
    var sections = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter Platforms"
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
        tableView.rowHeight = 104
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: String(describing: PlatformTableViewCell.self), bundle: nil), forCellReuseIdentifier: PlatformTableViewCell.reuseId)
        tableView.backgroundColor = .darkGray
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "All Off", style: .plain, target: self, action: #selector(toggleAll))
        
        networkHelper
            .set(loading: false)
            .set(endpoint: .platforms)
            .set(params: [
                "sort": "release_date:desc",
                "field_list":"abbreviation,company,deck,guid,id,image,name,release_date,install_base"
            ])
        
        MainTabBarController.shared.showLoading()
        
        getAll()
    }
    
    func getAll() {
        networkHelper.loadMore()
            .done { (platforms : [Platform]) in
                self.platforms += platforms
                if (self.networkHelper.hasMore) {
                    self.getAll()
                } else {
                    
                    self.platforms.forEach {
                        let decade = $0.decade
                        if !self.sections.contains(decade) {
                            self.sections.append(decade)
                            self.platformsBySection[decade] = [Platform]()
                        }
                        self.platformsBySection[decade]?.append($0)
                    }
                    
                    self.tableView.reloadData()
                    MainTabBarController.shared.hideLoading()
                }
            }.catch { e in
                print(e)
                MainTabBarController.shared.hideLoading()
            }
    }

    @objc func toggleAll() {
        platforms.forEach {
            if toggleOn {
                $0.removeFromHidden()
            } else {
                $0.hide()
            }
        }

        SaveManager.shared.hiddenPlatforms.forEach { print($0) }
        toggleOn = !toggleOn
        navigationItem.rightBarButtonItem?.title = toggleOn ? "All On" : "All Off"
        tableView.reloadData()
        
        NotificationManager.post(.platformsUpdated)
    }
    
    // MARK: - Table view data source

    func platformsFor(section: String) -> [Platform] {
        return platformsBySection[section] ?? []
    }
    
    func platformsFor(sectionIndex: Int) -> [Platform] {
        return platformsFor(section: sections[sectionIndex])
    }
    
    func platformFor(_ indexPath: IndexPath) -> Platform {
        return platformsFor(sectionIndex: indexPath.section)[indexPath.row]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return platformsFor(sectionIndex: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlatformTableViewCell.reuseId, for: indexPath) as! PlatformTableViewCell
        
            let platform = platformFor(indexPath)
            
            cell.populate(withPlatform: platform)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? PlatformTableViewCell else { return }
        
        let platform = platformFor(indexPath)

        platform.toggleHidden()
        cell.populate(withPlatform: platform)
        NotificationManager.post(.platformsUpdated)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vc = GameSectionHeaderViewController(withTitle: sections[section])

        return vc.view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
