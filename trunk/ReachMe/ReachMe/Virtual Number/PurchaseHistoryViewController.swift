//
//  PurchaseHistoryViewController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 3/29/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class PurchaseHistoryViewController: UITableViewController {

    var purchaseHistory = [[String:Any]]()
    var vnPurchHistory = [[String:Any]]()
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.beginRefreshing()
    }

    // MARK: Custom Methods
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchPurchasedHistory()
    }
    
    func fetchPurchasedHistory() {
        guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
            ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
            refreshControl?.endRefreshing()
            return
        }
        
        let reqDisc: NSMutableDictionary = ["vn_history": true,
                                            "after_purchase_id": 0,
                                            "fetch_max_rows": 100]
        let purchaseAPI = InAppPurchaseApi(request: reqDisc)
        NetworkCommon.addData(reqDisc, eventType: FETCH_PURCHASE_HISTORY)
        purchaseAPI?.callNetworkRequest(reqDisc, withSuccess: {[weak self] (requestAPI, responseDisc) in
            guard responseDisc?.value(forKey: STATUS) as! String == STATUS_OK else {
                print("Error in fetching product history. api request: \(String(describing: requestAPI?.request))")
                return
            }

            guard let creditPurchaseHistoryList = responseDisc?.value(forKey: "purchase_list") as? [[String:Any]] else { return }
            
            guard let vnPurchaseHistoryList = responseDisc?.value(forKey: "vn_purchase_list") as? [[String:Any]] else { return }


            //Delete existing rows
            var deleteIndexList = [IndexPath]()
            for (index, _) in (self?.purchaseHistory.enumerated())! {
                deleteIndexList.append(IndexPath(row: index, section: 0))
            }
            self?.purchaseHistory.removeAll()
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: deleteIndexList, with: .automatic)
            self?.tableView.endUpdates()

            //Update List
            creditPurchaseHistoryList.forEach{
                var creditHistory = $0
                let purchase = ReachMeUtility.convertUTCNumberToDate(purchaseDate: $0["purchase_dt"] as Any)
                creditHistory["purchase_date"] = purchase.0
                creditHistory["purchase_date_string"] = purchase.1
                self?.purchaseHistory.append(creditHistory)
            }
            
            vnPurchaseHistoryList.forEach{
                var vnHistory = $0
                //Purchase Date
                let purchase = ReachMeUtility.convertUTCNumberToDate(purchaseDate: $0["purchase_dt_ms"] as Any)
                vnHistory["purchase_date"] = purchase.0
                vnHistory["purchase_date_string"] = purchase.1
                
                //Expiry Date
                let expiry = ReachMeUtility.convertUTCNumberToDate(purchaseDate: $0["sub_expiry_ms"] as Any)
                vnHistory["expiry_date"] = expiry.0
                vnHistory["expiry_date_string"] = expiry.1
                
                //Format Number
                vnHistory["formatted_number"] = Common.getInternationalFormatNumber($0["phoneNum"] as? String)

                self?.purchaseHistory.append(vnHistory)
            }
            
            //Sort all purchase according to purchase date
            self?.purchaseHistory.sort(by: { (purchase1, purchase2) -> Bool in
                (purchase1["purchase_date"] as! Date).compare(purchase2["purchase_date"] as! Date) == .orderedDescending
            })

            //Instert new rows
            var reloadIndexList = [IndexPath]()
            for (index, _) in  (self?.purchaseHistory.enumerated())! {
                reloadIndexList.append(IndexPath(row: index, section: 0))
            }
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: reloadIndexList, with: .automatic)
            self?.tableView.endUpdates()

            self?.refreshControl?.endRefreshing()
            }, failure: { (requestAPI, error) in
                self.refreshControl?.endRefreshing()
                print("*** Error in fetching product history: \(error.debugDescription)")
        })
    }
}

//MARK: - TableView Delegate & Datasource
extension PurchaseHistoryViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseHistory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let history = purchaseHistory[indexPath.row]
        
        //Credit Purchase History
        guard let _ = history["poolId"] as? Int8 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CreditHistoryCell.identifier, for: indexPath) as! CreditHistoryCell
            let creditTopupValue = (history["credits"] as! Int32) - (history["pre_credits"] as! Int32)
            cell.currencyLabel.text = "\(history["price_currency"]!) \((history["price"] as! NSNumber).floatValue)"
            cell.topupLabel.text = "+" + "\(creditTopupValue)"
            cell.dateLabel.text = history["purchase_date_string"] as? String
            return cell
        }
        
        //Subscription History
        let cell = tableView.dequeueReusableCell(withIdentifier: SubscribeHistoryCell.identifier, for: indexPath) as! SubscribeHistoryCell
        cell.productTitle.text = history["product_title"] as? String
        cell.productPrice.text = "\(history["priceCurrency"]!) \(history["price"] as! Int32)"
        cell.productNumber.text = history["formatted_number"] as? String
        cell.purchaseDate.text = history["purchase_date_string"] as? String
        if let subscriptionStatus = history["status"] as? String, subscriptionStatus == "AC" { //AC == Active
            cell.cancelButton.isHidden = false
            cell.expiryDate.text = "Next payment due on \(history["expiry_date_string"]!)"
        } else {
            cell.cancelButton.isHidden = true
            cell.expiryDate.text = "Expired on \(history["expiry_date_string"]!)"
        }
        
        cell.cancelSubscriptionHandler = {
            if let purchaseSource = history["purchase_source"] as? String, purchaseSource == "AppleStore" {
                UIApplication.shared.open(NSURL(string: "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions")! as URL, options: [:], completionHandler: nil)
                //UIApplication.shared.open(NSURL(string: "https://apps.apple.com/account/subscriptions")! as URL, options: [:], completionHandler: nil)
            } else { // Android Purchase
                UIApplication.shared.open(NSURL(string: "https://play.google.com/store/account/subscriptions?sku=+\(String(describing: history["product_id"]))+&package=+com.kirusa.instavoice.reachme")! as URL, options: [:], completionHandler: nil)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//MARK: - TableCells
class CreditHistoryCell: UITableViewCell {
    
    static let identifier = String(describing: CreditHistoryCell.self)
    @IBOutlet weak var topupLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class SubscribeHistoryCell: UITableViewCell {
    
    static let identifier = String(describing: SubscribeHistoryCell.self)
    var cancelSubscriptionHandler: (() -> ())?

    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productNumber: UILabel!
    @IBOutlet weak var purchaseDate: UILabel!
    @IBOutlet weak var expiryDate: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        cancelSubscriptionHandler?()
    }
    
}

extension UITableView {
    public func beginRefreshing() {
        guard let refreshControl = refreshControl, !refreshControl.isRefreshing else { return }
        
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
        let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height)
        setContentOffset(contentOffset, animated: true)
    }
}
