//
//  TooltipViewController.swift
//  GameSeeker
//
//  Created by Corey McCourt on 5/27/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class TooltipViewController: UIViewController {

    @IBOutlet weak var tipLabel: UILabel!
    
    init() {
        super.init(nibName: "TooltipViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func set(text: String) {
        view.layer.removeAllAnimations()
        view.alpha = 0
        view.isHidden = false

        tipLabel.text = text
        tipLabel.sizeToFit()

        print("start")
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 3.0, options: [], animations: {
                self.view.alpha = 0
            }) { finished in
                guard finished else { return }

                self.view.isHidden = true
                print("end")
            }
        }
    }
}
