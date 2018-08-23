//
//  CountryNumbersViewController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 3/30/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class CountryNumbersViewController: UIViewController {

    @IBOutlet weak var selectedNumberView: UIView!
    @IBOutlet weak var selectedNumberLabel: UILabel!
    @IBOutlet weak var refreshSpinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCountry: [String: Any]!
    var numberList = [[String:Any]]()

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedNumberView.isHidden = true

        if let countryname = selectedCountry["country_name"] as? String {
            var image = UIImage(named: countryname.replacingOccurrences(of: " ", with: "-"))
            image = image?.withRenderingMode(.alwaysOriginal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style:.plain, target: nil, action: nil)
        }
        title = "Choose a Number (\((selectedCountry["country_iso"] as! String).uppercased()) +\(selectedCountry["country_ISD_code"] as! String))"
        
        fetchPlanNumbers()
    }

    //Button Actions
    @IBAction func onNextBtnClicked(_ sender: UIButton) {
        
        guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
            ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
            return
        }
        
        ANLoader.showLoading("", disableUI: true)
        let reqDisc: NSMutableDictionary = [:]
        let selectedNumber = numberList[(tableView.indexPathForSelectedRow?.row)!]
        reqDisc.setValue(selectedNumber["phone_num"], forKey: "virtual_num")
        reqDisc.setValue(selectedNumber["pool_id"], forKey: "vn_pool_id")
        if let subPlanList = selectedCountry["sub_plan_list"] as? [[String:Any]], let subPlan = subPlanList.first {
            reqDisc.setValue(subPlan["vn_sub_plan_id"], forKey: "vn_sub_plan_id")
        }
        let purchaseAPI = InAppPurchaseApi(request: reqDisc)
        NetworkCommon.addData(reqDisc, eventType: LOCK_VERTUAL_NUMBER)
        purchaseAPI?.callNetworkRequest(reqDisc, withSuccess: {[weak self] (requestAPI, responseDisc) in
            ANLoader.hide()
            guard responseDisc?.value(forKey: STATUS) as! String == STATUS_OK else {
                print("Error in Lock number. api request: \(String(describing: requestAPI?.request))")
                return
            }
            let paymentVC = self?.storyboard?.instantiateViewController(withIdentifier: String(describing: PaymentSummaryViewController.self)) as! PaymentSummaryViewController
            paymentVC.selectedCountry = self?.selectedCountry
            paymentVC.selectedNumber = selectedNumber
            paymentVC.lockResponseDisc = responseDisc as! [String : Any]
            self?.navigationController?.pushViewController(paymentVC, animated: true)

            }, failure: { (requestAPI, error) in
                ANLoader.hide()
                if let nsError = error as NSError? {
                    if nsError.code == 9005 {//Locked by another User
                        ReachMeUtility.showAlert(withMessage: "This number has already been selected by another user. Please select different number")
                    }
                }
                print("*** Error in Lock Number: \(error.debugDescription)")
        })
    }
    
    func fetchPlanNumbers() {
        
        guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
            ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
            refreshSpinner.stopAnimating()
            return
        }
        
        let reqDisc: NSMutableDictionary = [:]
        if let subPlanList = selectedCountry["sub_plan_list"] as? [[String:Any]], let subPlan = subPlanList.first {
            reqDisc.setValue(subPlan["vn_sub_plan_id"], forKey: "vn_sub_plan_id")
            reqDisc.setValue(subPlan["bucket_size"], forKey: "bucket_size")
        }
        let purchaseAPI = InAppPurchaseApi(request: reqDisc)
        NetworkCommon.addData(reqDisc, eventType: SUBSCRIPTION_NUMBER_LIST)
        purchaseAPI?.callNetworkRequest(reqDisc, withSuccess: {[weak self] (requestAPI, responseDisc) in
            self?.refreshSpinner.stopAnimating()
            guard responseDisc?.value(forKey: STATUS) as! String == STATUS_OK else {
                print("Error in fetching subscription list. api request: \(String(describing: requestAPI?.request))")
                return
            }
            
            guard let poolList = responseDisc?.value(forKey: "vn_list") as? [[String:Any]], poolList.count > 0 else {
                let alert = UIAlertController(style: .alert, message: "Unfortunately, ReachMe numbers are not available for the selected country at this moment. Please try again later")
                alert.addAction(title: "Cancel", style: .default) { (alertAction) in
                    self?.navigationController?.popViewController(animated: true)
                }
                alert.addAction(title: "Retry", style: .default) { (alertAction) in
                    self?.refreshSpinner.startAnimating()
                    self?.fetchPlanNumbers()
                }
                alert.show()
                return
            }
            
            var reloadIndexList = [IndexPath]()
            for (index, subscription) in poolList.enumerated() {
                var sub = subscription
                let formattedNumber = Common.getInternationalFormatNumber(subscription["phone_num"] as? String)
                sub["formattend_number"] = formattedNumber
                self?.numberList.append(sub)
                reloadIndexList.append(IndexPath(row: index, section: 0))
            }
            
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: reloadIndexList, with: .automatic)
            self?.tableView.endUpdates()
            
            }, failure: { (requestAPI, error) in
                self.refreshSpinner.stopAnimating()
                print("*** Error in fetching subscription list: \(error.debugDescription)")
        })

    }
}

//MARK: - TableView Delegate & Datasource
extension CountryNumbersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryNumberSelctionCell.identifier, for: indexPath)
        
        let number = numberList[indexPath.row]
        cell.textLabel?.text = number["formattend_number"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == tableView.indexPathForSelectedRow?.row {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if let model = GetDeviceModel().platformString(), (model.contains("iPhone 5") || model.contains("iPhone 6")) {
                self.selectedNumberView.isHidden = true
            } else {
                UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity:3.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.selectedNumberView.isHidden = true
                }, completion: { animationFinished in })
            }
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.selectedNumberLabel.text = cell?.textLabel?.text

        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity:3.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.selectedNumberView.isHidden = false
        }, completion: { animationFinished in })
    }
}


//MARK: - Table Cell
final class CountryNumberSelctionCell: UITableViewCell {
    
    static let identifier = String(describing: CountryNumberSelctionCell.self)
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
        textLabel?.textColor = selected ? IVColors.redColor() : .black
    }
}
