//
//  GamePushAnimator.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/18/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import UIKit

class GamePushAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    var duration : TimeInterval
    var isPresenting : Bool
    var navHeight : CGFloat
    
    init(duration : TimeInterval, isPresenting : Bool, navHeight: CGFloat) {
        self.duration = duration
        self.isPresenting = isPresenting
        self.navHeight = navHeight
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else
        {
            return
        }

        let container = transitionContext.containerView
        self.isPresenting ? container.addSubview(toView) : container.insertSubview(toView, belowSubview: fromView)
        
        let detailView = isPresenting ? toView : fromView
        let smallFrame = CGRect(x: 0, y: DetailsViewController.ratioHeight + navHeight, width: toView.bounds.width, height: 104)
        let largeFrame = toView.frame
        
        let maskView = UIView(frame: isPresenting ? smallFrame : largeFrame)
        maskView.backgroundColor = .white
        detailView.mask = maskView

        UIView.animate(withDuration: duration, animations: {
            maskView.frame = self.isPresenting ? largeFrame : smallFrame
        }, completion: { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            detailView.mask = nil
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}
