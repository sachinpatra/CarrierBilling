//
//  ReachMePackTableController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 8/24/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class ReachMePackTableController: UITableViewController {

    @objc var phoneNumber: String!
    var bundleList = [[String: Any]]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)

        tableView.beginRefreshing()
    }
    
    // MARK: Custom Methods
    @IBAction func notNowButtonAction(_ sender: UIBarButtonItem) {
        tableView.addSubview(refreshControl!)
        tableView.beginRefreshing()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchBundleList()
    }
    
    func fetchBundleList() {
        guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
            ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
            return
        }
        
        let reqDisc: NSMutableDictionary = ["phone_num": phoneNumber]
        NetworkCommon.addData(reqDisc, eventType: FETCH_BUNDLE_LIST)
        NetworkCommon.shared()?.callNetworkRequest(reqDisc, withSuccess: { (_, responseDisc) in
            self.refreshControl?.endRefreshing()
            self.refreshControl?.removeFromSuperview()
            guard let bundles = responseDisc?["bundles"] as? [[String:Any]], bundles.count > 0 else {
                ReachMeUtility.showAlert(withMessage: "Bundle pack not availabel", completion: {
                    self.navigationController?.popViewController(animated: true)
                })
                return
            }
            self.bundleList = bundles
            
        }, failure: { (_, error) in
            self.refreshControl?.endRefreshing()
            self.refreshControl?.removeFromSuperview()
            ReachMeUtility.showAlert(withMessage: error!.localizedDescription)
        })
    }
}

//MARK: - TableView Delegate & Datasource
extension ReachMePackTableController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bundleList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReachMePackTableCell.identifier, for: indexPath) as! ReachMePackTableCell
        
        let bundle = bundleList[indexPath.row]
        
        cell.bundleNameLabel.text = bundle["bundle_name"] as? String
        cell.bundleDescLabel.text = bundle["bundle_desc"] as? String
        cell.bundleValueLabel.text = "\(bundle["currency_sym"] as! String) \(bundle["price"] as! Double)"

        for feature in (bundle["feature_info"] as! [[String: Any]]) {
            let featureLabel = UILabel()
            featureLabel.text = feature["description"] as? String
            featureLabel.addOKImage(behindText: false)
            cell.stackView.addArrangedSubview(featureLabel)
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

//MARK: - Table Cell
class ReachMePackTableCell: UITableViewCell {
    
    static let identifier = String(describing: ReachMePackTableCell.self)
    
    @IBOutlet weak var bundleNameLabel: UILabel!
    @IBOutlet weak var bundleDescLabel: UILabel!
    @IBOutlet weak var bundleValueLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
