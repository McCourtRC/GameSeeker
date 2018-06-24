//
//  LoadingTableViewCell.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/17/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    public static let reuseId = "loadingCell"
    var images = [UIImage]()

    @IBOutlet weak var loadingImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        if images.count == 0 {
            for i in 1...49 {
                images.append(UIImage(named: "loading100\(i < 10 ? "0" : "")\(i)")!)
            }
        }
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        loadingImageView.image = UIImage.animatedImage(with: images, duration: 1.5)
    }

    func shouldShow(_ should: Bool) {
        loadingImageView.isHidden = !should
    }
}
