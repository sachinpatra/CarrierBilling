//
//  SettingGeneralTableController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 1/25/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class SettingGeneralTableViewController: UITableViewController {

    var errorMessage: String = ""
    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

//MARK: - TableView Datasource
extension SettingGeneralTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2//3(Blocked In-app purchase for this release)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 2
            default:
                return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingGeneralTableCell.identifier, for: indexPath) as! SettingGeneralTableCell

                switch indexPath.row {
                    case 0:
                        cell.titleLabel.text = "Password"
                        cell.hintLabel.text = "Change"
                        //If password not yet set
                        guard let pass = Constants.appDelegate.confgReader.getPassword(), !pass.isEmpty else {
                            cell.subTitleLabel.text = "Set Password"
                            cell.hintLabel.text = "Set"
                            break
                        }
                        //If password already set
                        var timeSienceLastChanged = "Not changed"
                        if let lastChangedPasswordTime = Constants.appDelegate.confgReader.getPasswordChangeTime() {
                            timeSienceLastChanged = (Date().offset(from: lastChangedPasswordTime))
                        }
                        cell.subTitleLabel.text = "Last changed: \(timeSienceLastChanged)"
                    
                    case 1:
                        cell.titleLabel.text = "ReachMe Ringtone"
                        cell.hintLabel.text = "Select"
                        
                        if Constants.appDelegate.confgReader.isRingtoneSet() {
                            cell.subTitleLabel.text = "iPhone"
                        } else {
                            cell.subTitleLabel.text = "ReachMe"
                        }
                    
                    case 2:
                        cell.titleLabel.text = "Notification Tone"
                        cell.hintLabel.text = "Select"
                        if let savedNotificationTone = Constants.appDelegate.confgReader.getNotificationSoundInfo(),
                            let notificationTone = savedNotificationTone.keys.first {
                            cell.subTitleLabel.text = notificationTone
                        } else {
                            cell.subTitleLabel.text = "ReachMe"
                        }
                    default:
                        break
                }
            return cell
            
        case 1://Logout
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoutCellIdentifier", for: indexPath)
            return cell
            
        case 2://ReachMe Credits
            let cell = tableView.dequeueReusableCell(withIdentifier: ReachMeCreditsTableCell.identifier, for: indexPath) as! ReachMeCreditsTableCell
            return cell
        
        default:
            return UITableViewCell()
        }
    }
}

//MARK: - TableView Delegate
extension SettingGeneralTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            case 0:
                switch indexPath.row {
                    case 0: //Password
                        let oldPassTextField = UITextField(frame: .zero)
                        let newPassTextField = UITextField(frame: .zero)
                        let confirmPassTextField = UITextField(frame: .zero)
                        let cell = tableView.cellForRow(at: indexPath) as! SettingGeneralTableCell
                        
                        let alert = UIAlertController(style: .alert, title: "\(cell.hintLabel.text!) Password")
                        alert.set(message: self.errorMessage, font: .systemFont(ofSize: 14), color: .red)
                        alert.addAction(title: "Cancel", style: .default)
                        alert.addAction(title: "Confirm", style: .default, isEnabled: false) { (alertAction) in
                            print("old = \(oldPassTextField.text!)")
                            print("new = \(newPassTextField.text!)")
                            print("confirm = \(confirmPassTextField.text!)")
                            
                            guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
                                ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
                                return
                            }
                            
                            ANLoader.showLoading("", disableUI: true)
                            let updateUserProfileAPI = UpdateUserProfileAPI(request: [USER_PWD: newPassTextField.text!])
                            updateUserProfileAPI?.updatePassword(newPassTextField.text!, withSuccess: {[weak self] (requestAPI, responseObject) in
                                ANLoader.hide()
                                Constants.appDelegate.confgReader.setPassword(newPassTextField.text!, withTime: Date())
                                ScreenUtility.showAlertMessage("PWD_CHANGED".localized)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                                })
                            }, failure: {[weak self] (requestAPI, error) in
                                    ANLoader.hide()
                                    self?.errorMessage = Common.convertErrorCode(toErrorString: Int32((error! as NSError).code))
                                    DispatchQueue.main.async {
                                        self?.tableView((self?.tableView)!, didSelectRowAt: IndexPath(row: 0, section: 0))
                                    }
                            })
                        }
                        
                        alert.addChangePasswordController(oldPassTextField: oldPassTextField, newPassTextField: newPassTextField, confirmPassTextField: confirmPassTextField, alert: alert)
                        alert.show {
                            if let pass = Constants.appDelegate.confgReader.getPassword(), !pass.isEmpty {
                                oldPassTextField.becomeFirstResponder()
                            }else {
                                newPassTextField.becomeFirstResponder()
                            }
                        }
                    
                    case 1: //Ringtone
                        let ringToneVC = SingleSelectionTableViewController(with: .ringTone)
                        ringToneVC.delegate = self
                        navigationController?.pushViewController(ringToneVC, animated: true)
                    
                    case 2: //Notificationtone
                        let notificationToneVC = SingleSelectionTableViewController(with: .notificationTone)
                        notificationToneVC.delegate = self
                        navigationController?.pushViewController(notificationToneVC, animated: true)
                    
                    default:
                        break
            }
            
            case 1://Logout
                Constants.appDelegate.canSignout()
            
            default:
                break;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 58.0
        default:
            return 44.0
        }
    }
    
}

//MARK: - SingleSelectionDelegate
extension SettingGeneralTableViewController: SingleSelectionDelegate {
    func onSelection(_ selectionType: SelectionType) {
        switch selectionType {
        case .ringTone:
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
        case .notificationTone:
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
            }
        }
    }
}

//MARK: - Section-0 Table Cell
final class SettingGeneralTableCell: UITableViewCell {
    
    static let identifier = String(describing: SettingGeneralTableCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabel?.text = ""
        detailTextLabel?.text = ""
        accessoryView = nil
    }
}

//Mark: - ReachMe Credits Table Cell
final class ReachMeCreditsTableCell: UITableViewCell {
    static let identifier = String(describing: ReachMeCreditsTableCell.self)

    @IBOutlet weak var creditsValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

