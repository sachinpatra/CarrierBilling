//
//  CarrierChargePopupViewController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 8/24/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

@objc extension UIAlertController {
    func addPopoverController() {
        let vc = UIStoryboard(name: "CarrierCharge", bundle: Bundle.main).instantiateInitialViewController()
        set(viewController: vc)
    }
}

class CarrierChargePopupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize.height = 280
    }
    
}
