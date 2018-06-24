//
//  GamesTableViewController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/16/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

class GamesTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)
    var usesSearch = false
    var sections = [String]()
    var games = [Game]()
    var gamesBySection = [String : [Game]]()
    var allowsInfiniteScroll = false {
        didSet {
            infiniteScrollActive = allowsInfiniteScroll
        }
    }
    
    var infiniteScrollActive = false
    
    var networkHelper : NetworkHelper? = nil
    var showHidden = false
    var navHeight = CGFloat(0)
    var showButton = UIBarButtonItem(title: "Show", style: .plain, target: self, action: #selector(toggleHidden))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 104
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: String(describing: GameTableViewCell.self), bundle: nil), forCellReuseIdentifier: GameTableViewCell.reuseId)
        tableView.register(UINib(nibName: String(describing: LoadingTableViewCell.self), bundle: nil), forCellReuseIdentifier: LoadingTableViewCell.reuseId)
        tableView.backgroundColor = .darkGray

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .white
        tableView.refreshControl?.addTarget(self, action:
            #selector(refresh), for: .valueChanged)
        
//        showButton = UIBarButtonItem(title: "Show", style: .plain, target: self, action: #selector(toggleHidden))
        
        
        showButton = UIBarButtonItem(image: #imageLiteral(resourceName: "eye-hide-white"), style: .plain, target: self, action: #selector(toggleHidden))
        
        
        
        
        navigationItem.rightBarButtonItem = showButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(filterPlatforms))
        navigationController?.delegate = self
        
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barStyle = .black
        
        NotificationManager.add(self, selector: #selector(reprocessGames), notification: .platformsUpdated)
        
        navHeight = navigationController?.navigationBar.frame.maxY ?? navHeight

        networkHelper = NetworkHelper().set(endpoint: .games)
        setup()
        
        if usesSearch {
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search Games"
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.delegate = self
            searchController.searchBar.returnKeyType = .done
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController?.isActive = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tableView.contentOffset.y < -navHeight - (navigationItem.searchController?.searchBar.frame.height ?? 0),
            tableView(tableView, numberOfRowsInSection: 0) > 0
        {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func setup() {}
    func gamesUpdated() {}
    
    var lastSearch = ""
    var timer: Timer?
    func setTimerForSearch() {
        MainTabBarController.shared.showLoading()
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = Timer(timeInterval: 0.7, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    @objc func performSearch() {
        print(searchText)
        lastSearch = searchText
        
        NetworkHelper()
            .set(endpoint: .search)
            .set(params: [
                "query": searchText,
                "resources": "game"
                ] as [String: Any]
            )
            .get()
            .done { (games : [Game]) in
                self.infiniteScrollActive = false
                self.sections = ["Search Results"]
                self.gamesBySection = [
                    "Search Results" : games
                ]
                self.tableView.reloadData()
                if games.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }.catch { e in
                print(e)
        }
    }
    
    var searchText : String {
        get {
            return searchController.searchBar.text ?? ""
        }
    }
    
    @objc func refresh() {
        networkHelper?.set(offset: 0)
        networkHelper?.hasMore = true
        infiniteScrollActive = allowsInfiniteScroll
        loadMore(append: false)
    }
    
    @objc func filterPlatforms() {
        navigationItem.searchController?.isActive = false
        navigationItem.rightBarButtonItem = showButton
        reprocessGames()
        MainTabBarController.shared.presentPlatformFilters()
    }

    @objc func toggleHidden() {
        reprocessGames(preventReload: true)

        showHidden = !showHidden
        navigationItem.rightBarButtonItem?.image = showHidden ? #imageLiteral(resourceName: "eye-show-white") : #imageLiteral(resourceName: "eye-hide-white")
        
        if showHidden {
            reprocessGames(preventReload: true)
        }
        
        var indexPaths = [IndexPath]()
        var sectionChanges = IndexSet()
        for (section, sectionName) in sections.enumerated() {
            var sectionChange = true
            for (row, game) in gamesFor(section: sectionName).enumerated() {
                if game.isHidden {
                    indexPaths.append(IndexPath(row: row, section: section))
                } else {
                    sectionChange = false
                }
            }
            if sectionChange {
                sectionChanges.insert(section)
            }
        }
        
        if !showHidden {
            reprocessGames(preventReload: true)
        }
        
        tableView.beginUpdates()
        if showHidden {
            tableView.insertSections(sectionChanges, with: .fade)
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            tableView.deleteSections(sectionChanges, with: .fade)
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        tableView.endUpdates()
        
        MainTabBarController.shared.showTooltip(withText: showHidden ? "All games shown" : "Filtered platforms hidden")
    }

    @objc func reprocessGames(preventReload: Bool = false) {
        self.processGames(self.games, preventReload: preventReload)
    }

    func loadMore(append: Bool = true) {
        guard networkHelper?.isLoading == false else { return }
        networkHelper?.loadMore().done { (games : [Game]) in
            if self.networkHelper?.hasMore == false {
                self.infiniteScrollActive = false
            }

            if append {
                self.games.append(contentsOf: games)
            } else {
                self.games = games
            }

            self.gamesUpdated()
            self.reprocessGames()
//            self.processGames(games, append: append)
        }.catch { e in
            print(e)
        }.finally {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func gamesFor(section: String) -> [Game] {
        return gamesBySection[section] ?? []
    }
    
    func gamesFor(sectionIndex: Int) -> [Game] {
        return gamesFor(section: sections[sectionIndex])
    }
    
    func gameFor(_ indexPath: IndexPath) -> Game {
        return gamesFor(sectionIndex: indexPath.section)[indexPath.row]
    }
    
    func processGames(_ games: [Game], append: Bool = false, sort: Bool = true, preventReload: Bool = false) {
        if !append {
            sections = [String]()
            gamesBySection = [String : [Game]]()
            self.games = games
        } else {
            self.games += games
        }

        let _ = games.sorted {
            return sort ? $0.releaseDate.compare($1.releaseDate) == .orderedAscending : true
        }.filter {
            return !$0.isHidden || showHidden
        }.map {
            let time = $0.humanTime
            if !self.sections.contains(time) {
                self.sections.append(time)
                self.gamesBySection[time] = [Game]()
            }
            self.gamesBySection[time]?.append($0)
        }
        
        if !preventReload {
//            if let indexPaths = tableView.indexPathsForVisibleRows {
//                self.tableView.reloadRows(at: indexPaths, with: .automatic)
//            } else {
                self.tableView.reloadData()
//            }
            //            self.tableView.beginUpdates()
//            self.tableView.reloadData()
//            self.tableView.endUpdates()
            
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return infiniteScrollActive ? sections.count + 1 : sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section >= sections.count ? 1 : gamesFor(sectionIndex: section).count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < sections.count else { return nil }

        let vc = GameSectionHeaderViewController(withTitle: sections[section])
        return vc.view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section < sections.count ? 44 : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section >= sections.count {
            loadMore()
            let loadingCell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.reuseId, for: indexPath) as! LoadingTableViewCell
            loadingCell.shouldShow(sections.count > 0)
            return loadingCell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: GameTableViewCell.reuseId, for: indexPath) as! GameTableViewCell
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor(named: "rowEven") : UIColor(named: "rowOdd")

        let game = gameFor(indexPath)
        cell.populate(withGame: game)

        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let game = gameFor(indexPath)
        if game.isSearchResult || true {
            return nil
        }

        let hide = UIContextualAction(style: .normal, title: game.isHidden ? "Show" : "Hide") { (action, view, handler) in
            if game.isHidden {
                game.removeFromHidden()
                action.title = "Hide"
                
                delay(0.5) {
                    self.reprocessGames()
                }
            } else {
                game.hide()
                action.title = "Show"
                
                delay(0.5) {
                    if !self.showHidden {
                        let sectionName = self.sections[indexPath.section]
                        self.reprocessGames(preventReload: true)
                        self.tableView.beginUpdates()
                        if !self.sections.contains(sectionName) {
                            self.tableView.deleteSections(IndexSet.init(integer: indexPath.section), with: .fade)
                        }
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.endUpdates()
                    } else {
                        self.reprocessGames()
                    }
                }
            }

            
            
            handler(true)
        }

        hide.backgroundColor = .darkGray
        let configuration = UISwipeActionsConfiguration(actions: [hide])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.section < sections.count else { return nil }
        
        let game = gameFor(indexPath)
        let save = UIContextualAction(style: .normal, title: game.isSaved ? "Unfollow" : "Follow") { (action, view, handler) in
            if game.isSaved {
                game.removeFromSaved()
                action.title = "Follow"
            } else {
                game.save()
                action.title = "Unfollow"
            }

            handler(true)
        }
        
        save.backgroundColor = UIColor.darkGray
        let configuration = UISwipeActionsConfiguration(actions:  [save])
        
        return configuration
    }

    var selectedIndexPath : IndexPath?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rect = tableView.cellForRow(at: indexPath)?.frame else { return }

        selectedIndexPath = indexPath
        UIView.animate(withDuration: 0.2, animations: {
            tableView.setContentOffset(CGPoint(x: 0, y: rect.origin.y - DetailsViewController.ratioHeight - self.navHeight), animated: false)
        }) { _ in
            let game = self.gameFor(indexPath)
            let detailsVC = DetailsViewController(withGame: game)
            self.navigationController?.pushViewController(detailsVC, animated: true)
            delay(1) {
                tableView.setContentOffset(CGPoint(x: 0, y: rect.origin.y - DetailsViewController.ratioHeight - self.navHeight), animated: false)
            }
        }
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

extension GamesTableViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return GamePushAnimator(duration: TimeInterval(UINavigationControllerHideShowBarDuration),
                                isPresenting: operation == .push,
                                navHeight: self.navHeight)
    }
}

extension GamesTableViewController: UISearchResultsUpdating {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = nil
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard searchText != lastSearch, searchText != "" else { return }
        setTimerForSearch()
    }
}

extension GamesTableViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = showButton
        infiniteScrollActive = allowsInfiniteScroll && (networkHelper?.hasMore == true)
        reprocessGames()
    }
}
