//
//  UIView+Extensions.swift
//  GameSeeker
//
//  Created by Jeremy Weeks on 5/26/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

public extension UIView {
    public func set(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
        var frame = self.frame
        frame.origin.x = x ?? frame.origin.x
        frame.origin.y = y ?? frame.origin.y
        frame.size.width = width ?? frame.size.width
        frame.size.height = height ?? frame.size.height
        self.frame = frame
    }
    
    public var x : CGFloat {
        return frame.origin.x
    }
    
    public var y : CGFloat {
        return frame.origin.y
    }
    
    public var width : CGFloat {
        return frame.size.width
    }
    
    public var height : CGFloat {
        return frame.size.height
    }
}
