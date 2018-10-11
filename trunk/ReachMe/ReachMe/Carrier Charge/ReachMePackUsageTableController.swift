//
//  ReachMePackUsageTableController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 9/21/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class ReachMePackUsageController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: PackUsageHeaderTableCell.identifier) as! PackUsageHeaderTableCell
        tableView.tableHeaderView = headerCell
        
        
        
        let reqDisc: NSMutableDictionary = ["tx_ids": 10]
        NetworkCommon.addData(reqDisc, eventType: BUNDLE_STATUS)
        NetworkCommon.shared()?.callNetworkRequest(reqDisc, withSuccess: { (_, responseDisc) in
           print("Temp")
        }, failure: { (_, error) in
            ReachMeUtility.showAlert(withMessage: error!.localizedDescription)
        })
    }


}

//MARK: - TableView Delegate & Datasource
extension ReachMePackUsageController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.row != 0 else { return tableView.dequeueReusableCell(withIdentifier: "PackUsageTitleCell", for: indexPath) }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PackUsageUnlimitedCell", for: indexPath)
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PackUsageDataCell.identifier, for: indexPath) as! PackUsageDataCell
            return cell

        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

//MARK: - Table Cell
class PackUsageHeaderTableCell: UITableViewCell {
    
    static let identifier = String(describing: PackUsageHeaderTableCell.self)
        
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class PackUsageDataCell: UITableViewCell {
    
    static let identifier = String(describing: PackUsageDataCell.self)
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
