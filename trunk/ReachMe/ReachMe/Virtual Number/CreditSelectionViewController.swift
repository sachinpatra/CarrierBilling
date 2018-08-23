//
//  CreditSelectionViewController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 7/2/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

@objc extension UIAlertController {
    func addCreditSelectionController(productList: [[String: Any]], action: CreditSelectionViewController.Action?) {
        let vc = UIStoryboard(name: "Store", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreditSelectionViewController") as! CreditSelectionViewController
        vc.action = action
        vc.productList = productList
        set(viewController: vc)
    }
}

class CreditSelectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    public typealias Action = ([String: Any]) -> Swift.Void
    fileprivate var action: Action?
    var productList: [[String: Any]]!

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize.height = 70
    }

    // MARK: - Button Actions
    @IBAction func onProductButtonAction(_ sender: DesignableButton) {
        action!(self.productList[sender.tag])
        navigationItem.rightBarButtonItem?.isEnabled = true
        collectionView.selectItem(at: IndexPath(row: sender.tag, section: 0), animated: true, scrollPosition: .top)
    }
}

// MARK: - UICollectionView Delegate & Datasource
extension CreditSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreditProductListCell.identifier, for: indexPath) as! CreditProductListCell
        let prodcut = self.productList[indexPath.row]
        cell.productButton.setTitle("\(prodcut["price_currency"]!)\(prodcut["price"]!)", for: .normal)
        cell.productButton.tag = indexPath.row
        
        return cell
    }
}

// MARK: - TableCells
class CreditProductListCell: UICollectionViewCell {
    
    static let identifier = String(describing: CreditProductListCell.self)
    @IBOutlet weak var productButton: DesignableButton!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                productButton.alpha = 1.0
            } else {
                productButton.alpha = 0.5
            }
        }
    }    
}
