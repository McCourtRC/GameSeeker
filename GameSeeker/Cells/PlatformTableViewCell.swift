//
//  PlatformTableViewCell.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/22/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit
import Kingfisher

class PlatformTableViewCell: UITableViewCell {
    
    public static let reuseId = "platformCell"
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var platformTitleLabel: UILabel!
    
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var showHideImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }

    override func prepareForReuse() {
        frontImageView.image = nil
        bgImageView.image = nil
        companyLabel.text = ""
        platformTitleLabel.text = ""
        releaseDateLabel.text = ""
    }
    
    let processor = BlurImageProcessor(blurRadius: 4)
    func populate(withPlatform platform: Platform) {
        let imageUrl = platform.image?.urlFor(size: .scaleAvatar)
        frontImageView.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))])
        bgImageView.kf.setImage(with: imageUrl, options: [.processor(processor), .transition(.fade(0.2))])
        
        companyLabel.text = platform.company
        platformTitleLabel.text = platform.name
        releaseDateLabel.text = platform.releaseDate?.format("MMM dd, yyyy") ?? ""
        showHideImageView.image = platform.isHidden ? #imageLiteral(resourceName: "eye-hide") : #imageLiteral(resourceName: "eye-show")
        contentView.alpha = platform.isHidden ? 0.2 : 1
        
    }
    
}
