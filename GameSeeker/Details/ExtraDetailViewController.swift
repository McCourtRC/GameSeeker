//
//  ExtraDetailViewController.swift
//  GameSeeker
//
//  Created by Corey McCourt on 5/27/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class ExtraDetailViewController: UIViewController {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    let category: String
    let info: String
    
    init(category: String, info: String) {
        self.category = category
        self.info = info
        
        super.init(nibName: "ExtraDetailViewController", bundle: nil)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryLabel.text = category
        infoLabel.text = info
    }
    
    
    
}
