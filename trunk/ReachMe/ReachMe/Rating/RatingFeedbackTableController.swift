//
//  RatingFeedbackTableController.swift
//  MyTest
//
//  Created by Sachin Kumar Patra on 1/19/18.
//  Copyright © 2018 sachin. All rights reserved.
//

import UIKit

@objc extension UIAlertController {
    func addFeedbackController(alertButtons: [UIAlertAction], action: RatingFeedbackTableController.Action?) {
        let vc = RatingFeedbackTableController(alertButtons: alertButtons, action: action)
        set(viewController: vc)
    }
}

enum RatingFeedbackCellSelctionType: String {
    case unSelect = "Un-Selected"
    case select = "Selected"
    
    var image: UIImage {
        switch self {
        case .unSelect: return #imageLiteral(resourceName: "Rating_Unselect")
        case .select: return #imageLiteral(resourceName: "Rating_Select")
        }
    }
}

final class RatingFeedbackTableController: UITableViewController {
    
    @objc var infoList: [String] = ["", ""] //NOTE: First position - Rating Value, Second position - Textfield value
    public typealias Action = ([String]) -> Swift.Void
    var numberOfRows: Int = 0
    var numberOfSection: Int = 0
    var alertButtons: [UIAlertAction]
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .lightGray
        return $0
    }(UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge))
    
    
    fileprivate var action: Action?
    //action?(infoList) ----- Put this where ever you want action
    
    
    // MARK: Initialize
    init(alertButtons: [UIAlertAction], action: Action?) {
        self.action = action
        self.alertButtons = alertButtons
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(indicatorView)
        
        tableView.register(RatingFeedbackTableCell.self, forCellReuseIdentifier: RatingFeedbackTableCell.identifier)
        preferredContentSize.height = 62

        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.isScrollEnabled = false
        
        let headerView = RatingFeedbackTableHeaderView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height: 80))
        headerView.ratingView.delegate = self
        tableView.tableHeaderView = headerView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var size = view.center
        size.y += 10
        indicatorView.center = size
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Custom Methods
    func updateDataSource() {
        indicatorView.startAnimating()
        preferredContentSize.height = 105

        DispatchQueue.global(qos: .userInitiated).async {
            self.numberOfSection = 1
            self.numberOfRows = 5
            sleep(1)
            
            DispatchQueue.main.async {
                let footerView = RatingFeedbackTableFooterView(frame: CGRect(x:0, y:0, width:self.tableView.frame.size.width, height: 45))
                footerView.textField.delegate = self
                self.tableView.tableFooterView = footerView
                
                self.indicatorView.stopAnimating()
                self.preferredContentSize.height = 368
                self.tableView.isScrollEnabled = true

                self.tableView.reloadData()
            }
        }
    }
    
}

// MARK: - TableViewDatasource
extension RatingFeedbackTableController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSection
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RatingFeedbackTableCell.identifier) as!  RatingFeedbackTableCell
        switch cell.selectedType {
        case .select:
            cell.imageView?.image = RatingFeedbackCellSelctionType.select.image
        case .unSelect:
            cell.imageView?.image = RatingFeedbackCellSelctionType.unSelect.image
        }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "My call dropped"
        case 1:
            cell.textLabel?.text = "I was hearing my own voice"
        case 2:
            cell.textLabel?.text = "There was background noise"
        case 3:
            cell.textLabel?.text = "Voice was not audible"
        case 4:
            cell.textLabel?.text = "Voice was pausing"
        default:
            break
        }
        
        return cell
    }
}

// MARK: - TableViewDelegate
extension RatingFeedbackTableController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RatingFeedbackTableCell
        switch cell.selectedType {
        case .select:
            cell.imageView?.image = RatingFeedbackCellSelctionType.unSelect.image
            cell.selectedType = .unSelect
            infoList = infoList.filter { $0 != ("\(indexPath.row + 1)") }
        case .unSelect:
            cell.imageView?.image = RatingFeedbackCellSelctionType.select.image
            cell.selectedType = .select
            infoList.append("\(indexPath.row + 1)") //Appending serial number, EX:- 1 , 2 or 5
        }
    }
}

// MARK: ReachMeRatingViewDelegate
extension RatingFeedbackTableController: ReachMeRatingViewDelegate {
    func reachMeRatingView(_ ratingView: ReachMeRatingView, isUpdating rating: Double) {
        alertButtons.last?.isEnabled = true
        infoList[0] = String(rating)
        if Int(rating) <= 3 {
            ratingView.editable = false
            updateDataSource()
        }
    }
    
    func reachMeRatingView(_ ratingView: ReachMeRatingView, didUpdate rating: Double) {
        
    }
}

//MARK: - UITextFieldDelegate
extension RatingFeedbackTableController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tableView.scrollToRow(at: IndexPath(row: 4, section: 0), at: .middle, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        infoList[1] = textField.text!
    }
}

//MARK: - Table Cell
final class RatingFeedbackTableCell: UITableViewCell {
    
    static let identifier = String(describing: RatingFeedbackTableCell.self)
    var selectedType: RatingFeedbackCellSelctionType = .unSelect
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        contentView.backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.font = UIFont(name: "Helvetica Neue", size: 15.5)
    }
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: - Table FooterView
final class RatingFeedbackTableFooterView: UIView {
    
    let textField = UITextField()
    
    //MARK: - Initializers
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    private func loadViewFromNib() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
        addConstraint(NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16))
        addConstraint(NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16))
        
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.placeholder = "  Anything else"
        textField.font = .systemFont(ofSize: 14)
        textField.borderStyle = .line
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
    }
}

//MARK: - Table HeaderView
final class RatingFeedbackTableHeaderView: UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var ratingView: ReachMeRatingView!
    
    //MARK: - Initializers
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    private func loadViewFromNib() {
        Bundle.main.loadNibNamed("RatingFeedbackTableHeaderView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

