//
//  ReachMePackTableController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 8/24/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class ReachMePackTableController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
}

//MARK: - TableView Delegate & Datasource
extension ReachMePackTableController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReachMePackTableCell.identifier, for: indexPath) as! ReachMePackTableCell
        
        let myLabel = UILabel()
        myLabel.textAlignment = .left
        myLabel.font = UIFont.systemFont(ofSize: 12)
        myLabel.text = "Free incoming calls on International Roaming."
        myLabel.addOKImage(behindText: false)
        cell.myStack.addArrangedSubview(myLabel)
        
        let myLabel1 = UILabel()
        myLabel1.textAlignment = .left
        myLabel1.font = UIFont.systemFont(ofSize: 12)
        myLabel1.text = "50 minutes of outgoing calls to Philippines"
        myLabel1.addOKImage(behindText: false)
        cell.myStack.addArrangedSubview(myLabel1)
        
        let myLabel2 = UILabel()
        myLabel2.textAlignment = .left
        myLabel2.font = UIFont.systemFont(ofSize: 12)
        myLabel2.text = "1 GB Bundled Roaming Data for General use."
        myLabel2.addOKImage(behindText: false)
        cell.myStack.addArrangedSubview(myLabel2)

        
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
    
    @IBOutlet weak var myStack: UIStackView!
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

