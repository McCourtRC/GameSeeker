//
//  DetailsViewController.swift
//  GameTracker
//
//  Created by Corey McCourt on 5/18/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit
import ObjectMapper
import WebKit
import PromiseKit
import Kingfisher
import ImageSlideshow

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private static let ratio = CGFloat(14.0/25.0)
    public static var ratioHeight : CGFloat {
        get {
            return 222
//            return ((UIApplication.shared.keyWindow?.bounds.width ?? 375) * ratio).rounded()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var extraDetailsStack: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var pageIndicator = CustomLabelPageIndicator()
    
    var game: Game
    let cell = Bundle.main.loadNibNamed(String(describing: GameTableViewCell.self),owner: self, options: nil)?.first as! GameTableViewCell
    
    init(withGame game: Game) {
        self.game = game
        super.init(nibName: String(describing: DetailsViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func followButton(_ sender: Any) {
        if game.isSaved {
            game.removeFromSaved()
            followButton.setTitle("Follow", for: .normal)
        }
        else {
            game.save()
            followButton.setTitle("Unfollow", for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = game.name
        
        tableView.delegate = self
        tableView.dataSource = self

        game.isSaved ? followButton.setTitle("Unfollow", for: .normal) : followButton.setTitle("Follow", for: .normal)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(goBack))
        
        cell.populate(withGame: game)
        
        ImageCache.default.retrieveImage(forKey: game.guid, options: nil) {
            image, cacheType in
            if let image = image {
                self.slideshow.setImageInputs([ImageSource(image: image)])
            }
        }
        
        
        
        slideshow.backgroundColor = .black
        slideshow.slideshowInterval = 3.0
        slideshow.pageIndicator = pageIndicator
        slideshow.pageIndicatorPosition = .init(horizontal: .right(padding: 20), vertical: .customBottom(padding: 20))
        slideshow.contentScaleMode = .scaleAspectFill
//        slideshow.preload = .fixed(offset: 1)
        slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: .red)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
        
        extraDetailsStack.alpha = 0
        descriptionLabel.alpha = 0
        
        fetch()
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }) { _ in
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func fetch() {
        NetworkHelper().set(endpoint: .game, andPath: game.guid).get().done { (games : [Game]) in
            guard let game = games.first else { return }
            self.game = game
            self.setup()
            
        }.catch { e in
            print(e)
        }
    }
    
    let hiddenImageView = UIImageView()
    func setup() {
        let tags : [Image.ImageTag] = [.promo, .screenshot, .concept, .boxart]
        
        let imageStrings = game.images.sorted { a, b in
            return a.scoreBy(tags: tags) <= b.scoreBy(tags: tags)
        }.compactMap {
            $0.orignalUrlString
        }
        
        let images : [InputSource] = imageStrings.compactMap {
            KingfisherSource(urlString: $0, options: [.transition(.fade(0.2))])
        }
        
        if let firstImage = imageStrings.first {
            delay(1) {
                self.hiddenImageView.kf.setImage(with: URL(string: firstImage)) { (image, error, cacheType, url) in
                    if let image = image {
                        ImageCache.default.store(image, forKey: self.game.guid)
                    }
                }
            }
        }
        
        setupExtraDetails()

        slideshow.setImageInputs(images)
        
    }
    
    func setupExtraDetails() {
        
        if game.platforms.count > 0 {
            let platforms = game.platforms.map{$0.name}.sorted().joined(separator: "\n")
            let platformDetails = ExtraDetailViewController(category: "Platforms", info: platforms)
            extraDetailsStack.addArrangedSubview(platformDetails.view)
        }
        
        if game.developers.count > 0 {
            let developers = game.developers.map{$0.name}.sorted().joined(separator: "\n")
            let developerDetails = ExtraDetailViewController(category: "Developers", info: developers)
            extraDetailsStack.addArrangedSubview(developerDetails.view)
        }
        
        if game.publishers.count > 0 {
            let publishers = game.publishers.map{$0.name}.sorted().joined(separator: "\n")
            let publisherDetails = ExtraDetailViewController(category: "Publishers", info: publishers)
            extraDetailsStack.addArrangedSubview(publisherDetails.view)
        }
        
        if game.genres.count > 0 {
            let genres = game.genres.map{$0.name}.sorted().joined(separator: "\n")
            let genreDetails = ExtraDetailViewController(category: "Genres", info: genres)
            extraDetailsStack.addArrangedSubview(genreDetails.view)
        }
        
        if game.franchises.count > 0 {
            let franchises = game.franchises.map{$0.name}.sorted().joined(separator: "\n")
            let franchiseDetails = ExtraDetailViewController(category: "Franchises", info: franchises)
            extraDetailsStack.addArrangedSubview(franchiseDetails.view)
        }

        self.view.setNeedsLayout()
        
        if self.game.webDescription != "" {
            DispatchQueue.global(qos: .background).async {
                let attrStr = self.game.webDescription.htmlToAttributedString
                
                DispatchQueue.main.async {
                    self.descriptionLabel.attributedText = attrStr
                    self.descriptionLabel.setNeedsLayout()
                    UIView.animate(withDuration: 0.2, animations: {
                        self.descriptionLabel.alpha = 1
                    }, completion: { _ in
                        self.view.setNeedsLayout()
                    })
                }
            }
        } else {
            descriptionLabel.text = game.description
        }

        UIView.animate(withDuration: 0.4, delay: 0.2, options: [], animations: {
            self.extraDetailsStack.alpha = 1
            if self.game.webDescription == "" {
                self.descriptionLabel.alpha = 1
            }
        }) { _ in
            self.view.setNeedsLayout()
        }
    }
    
    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        print("DID TAP")
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let save = UIContextualAction(style: .normal, title: game.isSaved ? "Un-Save" : "Save") { (action, view, handler) in
            if self.game.isSaved {
                self.game.removeFromSaved()
                action.title = "Save"
            } else {
                self.game.save()
                action.title = "Un-Save"
            }

            handler(true)
        }
        
        save.backgroundColor = UIColor.darkGray
        let configuration = UISwipeActionsConfiguration(actions:  [save])
        
        return configuration
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var size = scrollView.bounds.size
        size.height = descriptionLabel.frame.maxY + 50
        scrollView.contentSize = size
    }
}

/// Page indicator that shows page in numeric style, eg. "5/21"
public class CustomLabelPageIndicator: UILabel, PageIndicatorView {
    public var view: UIView {
        return self
    }
    
    public var numberOfPages: Int = 0 {
        didSet {
            updateLabel()
        }
    }
    
    public var page: Int = 0 {
        didSet {
            updateLabel()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        self.textColor = .white
        self.textAlignment = .right
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.masksToBounds = false
    }
    
    private func updateLabel() {
        let attributedString = NSMutableAttributedString(string: "\(page+1)/\(numberOfPages)",
                                                         attributes: [NSAttributedStringKey.font: UIFont(name: "Oswald-Bold", size: 16)!])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont(name: "Oswald", size: 18)!]
        let range : NSRange = NSString(string: attributedString.string).range(of: "/\(numberOfPages)")
        attributedString.addAttributes(boldFontAttribute, range: range)
        
        attributedText = attributedString
    }
    
    public override func sizeToFit() {
        let maximumString = String(repeating: "W", count: "\(page+1)/\(numberOfPages)".count) as NSString
        self.frame.size = maximumString.size(withAttributes: [.font: self.font])
    }
}
