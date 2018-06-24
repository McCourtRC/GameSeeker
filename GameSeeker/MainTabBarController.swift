//
//  MainTabBarController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/12/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    public static let shared = MainTabBarController()
    
    let platformsTableViewController = PlatformsTableViewController()
    let loadingViewController = LoadingViewController()
    
    let splash = SplashViewController()
    let tooltip = TooltipViewController()
    
    func setup() {
        add(viewController: FeedTableViewController(), withTitle: "Upcoming", andImage: #imageLiteral(resourceName: "upcoming"))
        add(viewController: ReleasedTableViewController(), withTitle: "Released", andImage: #imageLiteral(resourceName: "released"))
        add(viewController: SavedTableViewController(), withTitle: "Following", andImage: #imageLiteral(resourceName: "follow"))
        add(viewController: SettingsTableViewController(), withTitle: "Settings", andImage: #imageLiteral(resourceName: "settings"))
    }
    
    func add(viewController: UIViewController, withTitle title: String, andImage image: UIImage) {
        let navController = UniversalNavigationViewController(rootViewController: viewController)
        navController.tabBarItem = UITabBarItem(title: title, image: image, tag: tabBar.items?.count ?? 0)
        navController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
        addChildViewController(navController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.barTintColor = UIColor.init(red: 0.7, green: 0.0, blue: 0.0, alpha: 1)
        tabBar.tintColor = .white
        
        delegate = self
        
        view.addSubview(splash.view)
        splash.view.frame = UIScreen.main.bounds

        view.addSubview(tooltip.view)

        tooltip.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -40).isActive = true
        tooltip.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tooltip.view.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
    }
    
    func showTooltip(withText text: String) {
        tooltip.set(text: text)
    }
    
    func presentPlatformFilters() {
        present(viewController: platformsTableViewController)
    }
    
    func present(viewController: UIViewController) {
        presentedViewController?.dismiss(animated: true, completion: nil)

        let navController = UniversalNavigationViewController(rootViewController: viewController)
        navController.addCloseButton()
        selectedViewController?.present(navController, animated: true)
    }
    
    func showLoading() {
        guard self.loadingViewController.view.superview == nil,
            var navController = selectedViewController as? UINavigationController,
            var vc = navController.viewControllers.first else
        {
            return
        }
        
        if let pNav = presentedViewController as? UINavigationController,
            let pVc = pNav.viewControllers.first
        {
            navController = pNav
            vc = pVc
        }
        
        var frame = view.bounds
        frame.origin.y = navController.navigationBar.frame.maxY + (vc.navigationItem.searchController?.searchBar.frame.height ?? 0)
        frame.size.height -= frame.minY + tabBar.frame.height

        loadingViewController.view.alpha = 0
        vc.view.addSubview(loadingViewController.view)
        loadingViewController.view.frame = vc.view.bounds
        UIView.animate(withDuration: 0.4) {
            self.loadingViewController.view.alpha = 1
        }
    }
    
    func hideLoading() {
        guard let _ = self.loadingViewController.view.superview else { return }
        UIView.animate(withDuration: 0.4, animations: {
            self.loadingViewController.view.alpha = 0
        }) { _ in
            self.loadingViewController.view.removeFromSuperview()
        }
    }
}

extension MainTabBarController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let selectedViewController = selectedViewController,
            let fromView = selectedViewController.view,
            let toView = viewController.view,
            selectedViewController != viewController else
        {
            return false
        }

        UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve]) { _ in
        }

        return true
    }
}
