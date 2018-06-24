//
//  SettingsDetailsTableViewCell.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/22/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit

class SettingsDetailsTableViewCell: UITableViewCell {
    public static let reuseId = "settingsDetailCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    var toggleAction : ((UISwitch) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        toggleSwitch.isHidden = true
        selectionStyle = .default
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        descriptionLabel.text = ""
        toggleSwitch.isHidden = true
        accessoryType = .disclosureIndicator
        selectionStyle = .default
    }
    
    func populate(withTitle title: String, description: String? = nil, toggleState: Bool, andToggleAction toggleAction: ((UISwitch) -> Void)? = nil) {
        titleLabel.text = title
        descriptionLabel.text = description != "" ? description : nil
        self.toggleAction = toggleAction
        
        if toggleAction != nil {
            toggleSwitch.isHidden = false
            toggleSwitch.isOn = toggleState
            accessoryType = .none
            selectionStyle = .none
        }
    }

    @IBAction func toggleChanged(_ sender: Any) {
        if let toggleAction = self.toggleAction {
            toggleAction(toggleSwitch)
        }
    }
}
