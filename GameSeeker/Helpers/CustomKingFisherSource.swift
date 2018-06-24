//
//  CustomKingFisherSource.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/21/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import Kingfisher
import ImageSlideshow

/// Input Source to image using Kingfisher
public class CustomKingfisherSource: NSObject, InputSource {
    public var resource: ImageResource
    
    /// placeholder used before image is loaded
    public var placeholder: UIImage?
    
    /// options for displaying, ie. [.transition(.fade(0.2))]
    public var options: KingfisherOptionsInfo?
    
    /// Initializes a new source with a URL
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    /// - parameter options: options for displaying
    public init(resource: ImageResource, placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = nil) {
        self.resource = resource
        self.placeholder = placeholder
        self.options = options
        super.init()
    }
    
    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.kf.setImage(with: self.resource, placeholder: self.placeholder, options: self.options, progressBlock: nil) { (image, _, _, _) in
            callback(image)
        }
    }
    
    public func cancelLoad(on imageView: UIImageView) {
        imageView.kf.cancelDownloadTask()
    }
}
