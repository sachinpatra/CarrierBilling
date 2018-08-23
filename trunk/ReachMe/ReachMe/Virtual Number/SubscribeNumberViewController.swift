//
//  SubscribeNumberViewController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 8/6/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

class SubscribeNumberViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if Profile.sharedUser().profileData.additionalVerifiedNumbers.count > 10 {
            ReachMeUtility.showAlert(withMessage: "You have already linked 10 numbers to your account. Please unlink any one of them to subscribe to a new ReachMe number")
            return false
        }
        return true
    }
}
