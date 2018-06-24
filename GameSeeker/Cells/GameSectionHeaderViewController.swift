//
//  GameSectionHeaderViewController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/16/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class GameSectionHeaderViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    let sectionTitle : String
    
    init(withTitle title: String) {
        self.sectionTitle = title
        super.init(nibName: String(describing: GameSectionHeaderViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = sectionTitle
    }
}
