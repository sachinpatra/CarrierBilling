//
//  ReachMePackDetailTableController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 9/21/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class ReachMePackDetailTableController: UITableViewController {

    var selectedBundleID: Int!
    var benifits: [JSON]?
    var bundle = JSON() {
        didSet {
            benifits = bundle["benefit_json"].dictionaryValue["benefits"]?.array
            var reloadIndexList = [IndexPath]()
            for index in 0..<((benifits?.count)! + 1/*Header Cell*/ + 1/*T&C Cell*/) {
                reloadIndexList.append(IndexPath(row: index, section: 0))
            }
            tableView.beginUpdates()
            tableView.insertRows(at: reloadIndexList, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.beginRefreshing()

    }
    
    @IBAction func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchBundleDetail()
    }
    
    func fetchBundleDetail() {
        guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
            ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
            return
        }
        
        let reqDisc: NSMutableDictionary = ["bundle_id": selectedBundleID,
                                            "fetch_benefits": true,
                                            "fetch_purchase_data": false]
        NetworkCommon.addData(reqDisc, eventType: FETCH_BUNDLE_LIST)
        NetworkCommon.shared()?.callNetworkRequest(reqDisc, withSuccess: { (_, responseDisc) in
            self.refreshControl?.endRefreshing()
            self.refreshControl?.removeFromSuperview()
            let response = JSON(responseDisc as Any)

            guard let bundle = response["bundles"].arrayValue.first else { return }
            self.bundle = bundle
            
        }, failure: { (_, error) in
            self.refreshControl?.endRefreshing()
            self.refreshControl?.removeFromSuperview()
            ReachMeUtility.showAlert(withMessage: error!.localizedDescription)
        })
    }
}

extension ReachMePackDetailTableController  {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let benifitsCount = benifits?.count else { return 0 }
        return benifitsCount + 1 + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
             let cell = tableView.dequeueReusableCell(withIdentifier: PackDetailHeaderTableCell.identifier, for: indexPath) as! PackDetailHeaderTableCell
             if let benifitJSON = bundle["benefit_json"].dictionary {
                let bundleLogoFilePath = IVFileLocator.getBundlePicPath(bundle["logo"].stringValue)!
                if !FileManager.default.fileExists(atPath: bundleLogoFilePath) {
                    NetworkCommon.shared()?.downloadData(withURLString: bundle["logo_url"].stringValue , withSuccess: { (_, responseData) in
                        if let imageData = responseData as? Data {
                            cell.bundleImageView.image = UIImage(data: imageData)
                            do {
                                try imageData.write(to: URL(fileURLWithPath: bundleLogoFilePath), options: .atomic)
                            } catch {
                                print(error)
                            }
                        }
                    }, failure: { (_, error) in
                        ReachMeUtility.showAlert(withMessage: error!.localizedDescription)
                    })
                } else {
                    cell.bundleImageView.image = UIImage(contentsOfFile: bundleLogoFilePath)
                }
                
                cell.bundleName.text = bundle["bundle_name"].stringValue
                cell.priceLabel.text = "\(bundle["currency_sym"].stringValue) \(bundle["price"].doubleValue)"
                cell.validityLabel.text = "Valid for \(bundle["validity"].stringValue) days"
                cell.benifitDescLabel.text = benifitJSON["desc"]?.stringValue
                cell.benifitTitleLabel.text = benifitJSON["benefit_title"]?.stringValue
             }
            return cell
            
        } else if indexPath.row == ((benifits?.count)! + 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: PackDetailTermsCell.identifier, for: indexPath) as! PackDetailTermsCell
            if let benifitJSON = bundle["benefit_json"].dictionary {
                cell.titleLabel.text = benifitJSON["tnc_title"]?.stringValue
                for termCondion in benifitJSON["tnc"]!.arrayValue {
                    let termConditionLabel = UILabel()
                    termConditionLabel.font = UIFont(name: "Helvetica Neue", size: 13.0)
                    termConditionLabel.text = "•    \(termCondion.stringValue)"
                    cell.stackView.addArrangedSubview(termConditionLabel)
                }
            }
            return cell
            
        } else {
            guard let benifit = benifits?[indexPath.row - 1] else { return UITableViewCell() }
            
            if benifit["val_type"].stringValue == "s" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PackDetailFeatureTextCell", for: indexPath)
                cell.textLabel?.text = benifit["title"].stringValue
                cell.detailTextLabel?.text = benifit["val_str"].stringValue
                return cell
                
            } else if benifit["val_type"].stringValue == "i" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PackDetailFeatureTextCell", for: indexPath)
                cell.textLabel?.text = benifit["title"].stringValue
                cell.detailTextLabel?.text = "\(benifit["val_int"].intValue)"
                return cell

            } else if benifit["val_type"].stringValue == "b", benifit["val_bool"].boolValue == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PackDetailFeatureYesCell", for: indexPath)
                cell.textLabel?.text = benifit["title"].stringValue
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PackDetailFeatureNoCell", for: indexPath)
                cell.textLabel?.text = benifit["title"].stringValue
                return cell
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//MARK: - Table Cell
class PackDetailHeaderTableCell: UITableViewCell {
    
    static let identifier = String(describing: PackDetailHeaderTableCell.self)
    @IBOutlet weak var bundleImageView: UIImageView!
    @IBOutlet weak var bundleName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    @IBOutlet weak var benifitDescLabel: UILabel!
    @IBOutlet weak var benifitTitleLabel: UILabel!
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class PackDetailTermsCell: UITableViewCell {
    
    static let identifier = String(describing: PackDetailTermsCell.self)
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
