//
//  LoadingViewController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/22/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    public static var images = [UIImage]()
    
    @IBOutlet weak var loadingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if LoadingViewController.images.count == 0 {
            for i in 1...49 {
                LoadingViewController.images.append(UIImage(named: "loading100\(i < 10 ? "0" : "")\(i)")!)
            }
        }
        
        loadingImageView.image = UIImage.animatedImage(with: LoadingViewController.images, duration: 1.5)
    }
}
