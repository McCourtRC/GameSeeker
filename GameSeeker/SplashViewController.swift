//
//  SplashViewController.swift
//  GameSeeker
//
//  Created by Jeremy Weeks on 5/26/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet var views: [UIView]!
    @IBOutlet var viewTopConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var logoView: UIImageView!
    
    var maskView : UIView!
    var maskFrame = CGRect.zero
    var maskFrameZero = CGRect.zero
    var height = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()

        height = UIScreen.main.bounds.height * 1.5
        
        maskFrame = CGRect(x: UIScreen.main.bounds.midX - height/2.0, y: UIScreen.main.bounds.midY - height/2.0, width: height, height: height)
        maskFrameZero = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
        redView.frame = CGRect(x: maskFrameZero.origin.x + 33, y: maskFrameZero.origin.y + 20, width: 0, height: 0)

        maskView = UIView(frame: maskFrame)
        maskView.backgroundColor = .white
        
        maskView!.layer.cornerRadius = height/2
        
        delay(0.5) {
            self.runAnimation()
        }
    }
    
    override func viewWillLayoutSubviews() {
        if let window = UIApplication.shared.keyWindow,
                window.safeAreaInsets.bottom != 0
        {
            viewTopConstraints.forEach { $0.constant = -50 + window.safeAreaInsets.bottom }
        }
        
        let offset = viewTopConstraints.first?.constant ?? -50
        maskFrame.origin.y = UIScreen.main.bounds.midY - height/2.0 - offset
        maskFrameZero.origin.y = UIScreen.main.bounds.midY  - offset
    }

    func runAnimation() {
        guard views.count > 1,
            let v = views.first else {
            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut, animations: {
                self.redView.layer.cornerRadius = self.height/2
                self.redView.frame = self.maskFrame
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                    self.view.alpha = 0
                }) { _ in
                    self.view.removeFromSuperview()
                }
            }
                
            return
        }

        maskView.frame = maskFrame
        maskView.layer.cornerRadius = height/2
        v.mask = maskView

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.maskView?.layer.cornerRadius = 0
            self.maskView.frame = self.maskFrameZero
        }) { _ in
            v.mask = nil
            v.removeFromSuperview()
            self.views.remove(at: 0)
            self.runAnimation()
        }
    }
}
