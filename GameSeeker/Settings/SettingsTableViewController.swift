//
//  SettingsTableViewController.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/22/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UIViewController {
    let tableView = UITableView()
    
    let emailAdress = "crono9997@gmail.com"
    var apiKeyAction : SettingsAction?
    let apiDescription = "Giant Bomb's API has rate limiting shared throughout all of our users."
    
    var sections = [String]()
    var sectionData = [String : [SettingsAction]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        view.backgroundColor = .darkGray
        
        let smallResolution = view.bounds.width < 350
        let emptyImageView = UIImageView(image: #imageLiteral(resourceName: "powered-by"))
        view.addSubview(emptyImageView)
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: String(describing: SettingsDetailsTableViewCell.self), bundle: nil), forCellReuseIdentifier: SettingsDetailsTableViewCell.reuseId)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = smallResolution ? 30 : 44
        tableView.backgroundColor = .clear
        
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let tabBarHeight = tabBarController?.tabBar.height ?? 0
        emptyImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight - (smallResolution ? 6 : 20)).isActive = true

        apiKeyAction = SettingsAction(withTitle: "Add an API Key", description: apiDescription) {
            self.openAPIKeyAlert()
        }
        
        sectionData["Utils"] = [
            SettingsAction(withTitle: "Filter Platforms", description: "") {
                MainTabBarController.shared.presentPlatformFilters()
            },
            SettingsAction(withTitle: "Have Feedback?", description: "Send it to us.") {
                guard MFMailComposeViewController.canSendMail() else {
                    self.openEmailAlert()
                    return
                }
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                composeVC.setToRecipients([self.emailAdress])
                composeVC.setSubject("Game Seeker Feedback")
                composeVC.setMessageBody("", isHTML: false)

                self.present(composeVC, animated: true, completion: nil)
            },
            apiKeyAction!,
            SettingsAction(withTitle: "Clear all data.", description: "Reset to default. No saved/hidden games and no hidden platforms") {
                let alertController = UIAlertController(title: "Are you sure you want to clear all data?", message: "It will remove all of your saved games and filters.", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Clear Data", style: .destructive) { _ in
                    SaveManager.shared.reset()
                    UserNotificationManager.cancelAllNotifications()
                    NotificationManager.post(.platformsUpdated)
                    self.showAlert(withTitle: "Data cleared.")
                }

                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            },
            SettingsAction(toggleWithTitle: "Allow Notifications", description: "Turn on/off notifications for game releases.", toggleState: SaveManager.shared.getNotificationsAllowed()) { toggleSwitch in
                
                SaveManager.shared.save(toggleSwitch.isOn as AnyObject, forKey: .userNotificationsAllowed)

                if !toggleSwitch.isOn {
                    UserNotificationManager.cancelAllNotifications()
                } else {
                    if UserDefaults.standard.object(forKey: SaveManager.SaveKey.systemNotificationsAllowed.rawValue) == nil {
                        UserNotificationManager.getAuthorizationStatus().done { (granted, error) in
                            SaveManager.shared.setSystemNotification(allowed: granted)
                            
                            if !granted {
                                toggleSwitch.isOn = false
                                self.showAlert(withTitle: "Notifications not enabled.", andMessage: "Notifications need to be enabled on your device's settings")
                            }
                        }.catch { _ in }
                    } else if !SaveManager.shared.getNotificationsAllowed() {
                        toggleSwitch.isOn = false
                        self.showAlert(withTitle: "Notifications not enabled.", andMessage: "Notifications need to be enabled on your device's settings")
                    } else {
                        
                    }
                }
            },
        ]
        
        updateApiCell()
        
        sectionData["Game Seeker was created by:"] = [
            SettingsAction(withTitle: "Corey McCourt", description: "") {
                self.open(urlString: "https://www.linkedin.com/in/coreymccourt/")
            },
            SettingsAction(withTitle: "Jeremy Weeks", description: "") {
                self.open(urlString: "http://jeremysresume.com")
            }
        ]
        
        sections = Array(sectionData.keys)
    }
    
    func updateApiCell() {
        if let apiKeyAction = apiKeyAction {
            apiKeyAction.description = apiDescription + (SaveManager.shared.isDeafultApiKey ? "" : "\n\nYour key: \(SaveManager.shared.apiKey)")
        }
        tableView.reloadData()
    }
    
    func open(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func openEmailAlert() {
        let alertController = UIAlertController(title: "Send Feedback", message: "Looks like you dont have an email address setup on your device.\n\nPlease send your feedback here:\n\n\n", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField) in
            textField.text = self.emailAdress
            textField.delegate = self
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    func openAPIKeyAlert() {
        let alertController = UIAlertController(title: "Add your own API key", message: "Giant Bomb's API has rate limiting shared throughout all of our users.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Add key here."
        }
        
        let getKeyAction = UIAlertAction(title: "Get Key", style: .default) { _ in
            if let link = URL(string: "https://www.giantbomb.com/api/") {
                UIApplication.shared.open(link)
            }
        }
        
        let okAction = UIAlertAction(title: "Use Key", style: .default) { _ in
            if let tf = alertController.textFields?.first,
                let key = tf.text
            {
                NetworkHelper().set(limit: 1).set(endpoint: .games).set(params: [
                    "api_key": key
                ]).get().done { (games: [Game]) in
                    self.showAlert(withTitle: "API key saved successfully.")
                    SaveManager.shared.update(apiKey: key)
                }.catch { e in
                    self.showAlert(withTitle: "API key invalid.")
                }.finally {
                    self.updateApiCell()
                }
            }
        }
        
        let clearAction = UIAlertAction(title: "Clear Key", style: .default) { _ in
            SaveManager.shared.clearApiKey()
            self.updateApiCell()
        }

        alertController.addAction(getKeyAction)
        alertController.addAction(okAction)
        alertController.addAction(clearAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(withTitle title: String, andMessage message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension SettingsTableViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[sections[section]]!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsDetailsTableViewCell.reuseId, for: indexPath) as! SettingsDetailsTableViewCell
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor(named: "rowEven") : UIColor(named: "rowOdd")
        
        if let settingsAction = sectionData[sections[indexPath.section]]?[indexPath.row] {
            cell.populate(withTitle: settingsAction.title, description: settingsAction.description, toggleState: settingsAction.toggleState, andToggleAction: settingsAction.toggleAction)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vc = GameSectionHeaderViewController(withTitle: sections[section])
        return vc.view
    }
}

extension SettingsTableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let settingsAction = sectionData[sections[indexPath.section]]?[indexPath.row] {
            settingsAction.action?()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsTableViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsTableViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(self)
    }
}

class SettingsAction {
    let title : String
    let isToggle : Bool
    var description : String
    let action : (() -> Void)?
    let toggleAction : ((UISwitch) -> Void)?
    var toggleState = false
    
    init(withTitle title: String, description: String = "", andAction action: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.action = action
        self.toggleAction = nil
        self.isToggle = false
    }
    
    init(toggleWithTitle title: String, description: String = "", toggleState: Bool, andToggleAction action: @escaping (UISwitch) -> Void) {
        self.title = title
        self.description = description
        self.toggleAction = action
        self.action = nil
        self.isToggle = true
        self.toggleState = toggleState
    }
}
