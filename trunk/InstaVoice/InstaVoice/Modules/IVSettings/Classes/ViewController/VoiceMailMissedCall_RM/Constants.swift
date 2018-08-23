//
//  Constants.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 1/25/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import Foundation
import UIKit

@objc class Constants: NSObject {
    @objc static let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    static let CHANGE_PASS_MIN_LENGTH = 6
    static let CHANGE_PASS_MAX_LENGTH = 25
    @objc static let BUNDLE_ID = Bundle.main.bundleIdentifier
    @objc static let RINGTONE_NAME = "AudioResource.bundle/RingTones/ReachMeDefaultRingTone.mp3"
}
