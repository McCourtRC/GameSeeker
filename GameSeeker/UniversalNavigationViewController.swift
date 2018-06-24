//
//  UniversalNavigationViewController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/22/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class UniversalNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor.init(red: 0.7, green: 0.0, blue: 0.0, alpha: 1)
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.tintColor = .white
    }

    func addCloseButton() {
        viewControllers.first?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
    }
    
    @objc func close() {
        dismiss(animated: true)
    }
}
