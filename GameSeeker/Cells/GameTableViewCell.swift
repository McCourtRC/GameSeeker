//
//  GameTableViewCell.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/15/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit
import SwiftMoment
import Kingfisher

class GameTableViewCell: UITableViewCell {

    public static let reuseId = "gameCell"
    
    @IBOutlet weak var boxartImageView: UIImageView!
    @IBOutlet weak var boxartBGImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var platformStackView: UIStackView!
    @IBOutlet weak var isMoreLabel: UILabel!
    @IBOutlet weak var savedConstraint: NSLayoutConstraint!
    @IBOutlet weak var followButton: UIButton!

    var game : Game?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none

        NotificationManager.add(self, selector: #selector(gameUpdated(notification:)), notification: .gameUpdated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        releaseDateLabel.text = ""
        boxartImageView.image = nil
        boxartBGImageView.image = nil
    }
    
    @objc func gameUpdated(notification: Notification) {
        if let game = notification.object as? Game,
            let id = self.game?.id,
            game.id == id
        {
            update(withGame: game, andDelay: self.isEditing ? 0.4 : 0)
        }
    }
    
    func update(withGame game: Game, andDelay delay: Double = 0.4) {
        savedConstraint.constant = game.isSaved ? -5 : -51

        UIView.animate(withDuration: 0.2,
                       delay: delay,
                       options: .curveEaseOut,
                       animations:{
                            self.layoutIfNeeded()
                       })
    }

    let processor = BlurImageProcessor(blurRadius: 4)
    func populate(withGame game: Game) {
        

        let imageUrl = game.images.first?.urlFor(size: .scaleAvatar)
        boxartImageView.kf.setImage(with: imageUrl, options: [.transition(.fade(0.2))])
        boxartBGImageView.kf.setImage(with: imageUrl, options: [.processor(processor), .transition(.fade(0.2))])
//        { (image, _, _, _) in
//            if let image = image {
//                let pImage = self.processor.process(item: .image(image), options: [])
//                self.boxartBGImageView.image = pImage
//            }
//
//        }
        
        
//        processor.pro
//        boxartImageView.kf.setImage(with: game.images.first?.urlFor(size: .scaleAvatar), placeholder: nil, options: [.transition(.fade(0.2))]) { image in
//
//        }
//        boxartBGImageView.kf.setImage(with: game.images.first?.urlFor(size: .scaleAvatar), placeholder: nil, options: [.processor(processor), .transition(.fade(0.2))])
        
//        boxartImageView.kf.setImage(with: game.images.first?.urlFor(size: .scaleAvatar), options: [.transition(.fade(0.2))])
        titleLabel.attributedText = game.attrName
        releaseDateLabel.text = game.displayReleaseDate
        
        for i in 0...2 {
            guard let platLabel = platformStackView.arrangedSubviews[i] as? UILabel else { return }
            if game.displayPlatforms.count > i {
                let platform = game.displayPlatforms[i]
                platLabel.text = "  \(platform.displayAbbreviation)  "
                platLabel.backgroundColor = platform.color
                platformStackView.arrangedSubviews[i].isHidden = false
            } else {
                platformStackView.arrangedSubviews[i].isHidden = true
            }
        }
        
        isMoreLabel.isHidden = game.displayPlatforms.count <= 3
        isMoreLabel.text = "  +\(game.displayPlatforms.count - 3) MORE  "
        savedConstraint.constant = game.isSaved ? -5 : -51
        
        self.game = game
        followButton.layer.removeAllAnimations()
        
        contentView.backgroundColor = game.isHidden ? .lightGray : contentView.backgroundColor
    }

    @IBAction func followTapped(_ sender: Any) {
        if let game = self.game {
            game.removeFromSaved()
        }
    }
}
