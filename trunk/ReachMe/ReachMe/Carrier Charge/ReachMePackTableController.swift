//
//  ReachMePackTableController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 8/24/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit
import CoreData

class ReachMePackTableController: UITableViewController {

    @objc var phoneNumber: String!
    var bundleList = [JSON]() {
        didSet {
            let reloadIndexList = bundleList.enumerated().map { (index, _) in
                return IndexPath(row: index, section: 0)
            }
            tableView.beginUpdates()
            tableView.insertRows(at: reloadIndexList, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let coreDataStack = CoreDataStack(modelFileNames: ["ContactModel"], persistentFileName: "ContactModel.sqlite")
        coreDataStack.performBackgroundTask(inContext: { (context, saveBlock) in
            let purchase = NSEntityDescription.insertNewObject(forEntityName: "BundlePurchase", into: context) as! BundlePurchase
            purchase.bundleName = "testBundle"
        })
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BundlePurchase")
        do {
            let results = try coreDataStack.defaultContext.fetch(fetchRequest)
            guard let profileList = results as? [BundlePurchase] else { return }
            print("")
        } catch let error as NSError {
            print("CoreData Profile Table - Fetch failed: \(error.localizedDescription)")
        }*/


        tableView.tableFooterView = UIView()
        refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.beginRefreshing()

    }
    
    // MARK: Custom Methods
    @IBAction func notNowButtonAction(_ sender: UIBarButtonItem) {
        //tableView.addSubview(refreshControl!)
        //tableView.beginRefreshing()
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
            let response = JSON(responseDisc as Any)
            
            guard let bundles = response["bundles"].array, bundles.count > 0 else {
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
        
        cell.bundle = bundleList[indexPath.row]
        cell.infoBtnHandler = { bundle in
            self.performSegue(withIdentifier: "showPackDetailSegue", sender: bundle["bundle_id"].intValue)
        }
        cell.buyActivateBtnHandler = { bundle in
            guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
                ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
                return
            }
            
            ANLoader.showLoading("", disableUI: true)
            let reqDisc: NSMutableDictionary = ["phone_num": self.phoneNumber,
                                                "bundle_id": bundle["bundle_id"].intValue,
                                                "action": "purchase"]
            NetworkCommon.addData(reqDisc, eventType: BUNDLE_PURCHASE)
            NetworkCommon.shared()?.callNetworkRequest(reqDisc, withSuccess: { (_, responseDisc) in
                ANLoader.hide()
                let response = JSON(responseDisc as Any)

            }, failure: { (_, error) in
                ANLoader.hide()
                ReachMeUtility.showAlert(withMessage: error!.localizedDescription)
            })
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPackDetailSegue", let selectedBundleID = sender as? Int {
            let destVC = segue.destination as! ReachMePackDetailTableController
            destVC.selectedBundleID = selectedBundleID
        }
    }
}

//MARK: - Table Cell
class ReachMePackTableCell: UITableViewCell {
    
    static let identifier = String(describing: ReachMePackTableCell.self)
    
    @IBOutlet weak var bundleImageView: UIImageView!
    @IBOutlet weak var bundleNameLabel: UILabel!
    @IBOutlet weak var bundleDescLabel: UILabel!
    @IBOutlet weak var bundleValueLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activateBtn: DesignableButton!
    @IBOutlet weak var buyActivateBtn: DesignableButton!
    var infoBtnHandler: ((_ bundle: JSON) -> Void)?
    var activateBtnHandler: ((_ bundle: JSON) -> Void)?
    var buyActivateBtnHandler: ((_ bundle: JSON) -> Void)?

    
    var bundle: JSON? {
        didSet {
            guard let bundle = bundle else { return }
            
            let bundleLogoFilePath = IVFileLocator.getBundlePicPath(bundle["logo"].stringValue)!
            if !FileManager.default.fileExists(atPath: bundleLogoFilePath) {
                NetworkCommon.shared()?.downloadData(withURLString: bundle["logo_url"].stringValue , withSuccess: { (_, responseData) in
                    if let imageData = responseData as? Data {
                        self.bundleImageView.image = UIImage(data: imageData)
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
                self.bundleImageView.image = UIImage(contentsOfFile: bundleLogoFilePath)
            }

            
            bundleNameLabel.text = bundle["bundle_name"].stringValue
            bundleDescLabel.text = bundle["bundle_desc"].stringValue
            bundleValueLabel.text = "\(bundle["currency_sym"].stringValue) \(bundle["price"].doubleValue)"
            buyActivateBtn.isHidden = !(bundle["purchase_required"].boolValue)
            activateBtn.isHidden = bundle["purchase_required"].boolValue
            validityLabel.text = "Valid for \(bundle["validity"].stringValue) days (Post activation)"

            for feature in bundle["feature_info"].arrayValue {
                let featureLabel = UILabel()
                featureLabel.text = feature["description"].stringValue
                featureLabel.addOKImage(behindText: false)
                stackView.addArrangedSubview(featureLabel)
            }
        }
    }

    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func infoBtnAction(_ sender: UIButton) {
        infoBtnHandler?(bundle!)
    }
    
    @IBAction func activateBtnAction(_ sender: DesignableButton) {
        activateBtnHandler?(bundle!)
    }
    
    @IBAction func buyActivateBtnAction(_ sender: DesignableButton) {
        buyActivateBtnHandler?(bundle!)
    }
}
