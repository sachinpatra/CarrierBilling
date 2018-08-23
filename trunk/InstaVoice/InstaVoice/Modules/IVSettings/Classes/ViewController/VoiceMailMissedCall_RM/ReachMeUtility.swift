//
//  ReachMeUtility.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 1/26/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import Foundation
import UIKit

class ReachMeUtility: NSObject {
    @objc class func showAlert(withMessage message:String, title:String? = nil, completion: (() -> Swift.Void)? = nil) {
        let alert =  UIAlertController(style: .alert, title: title, message: message)
        alert.addAction(title: "OK", style: .default)
        alert.show() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion?()
            }
        }
    }

    @objc class func parseJSONToDictionary(inputString: String) -> [String: Any]? {
        if let data = inputString.data(using: String.Encoding.utf8) {
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
                return result
            } catch {
                print("Error in JSON Parsing")
            }
        }
        return nil
    }
    
    class func convertUTCNumberToDate(purchaseDate: Any) -> (Date, String) {
        var date: Date!
        if let utcNumber = purchaseDate as? Int64 {
            let value = Double(utcNumber) / 1000
            date = Date(timeIntervalSince1970: value)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        return (date, dateFormatter.string(from: date))
    }
}
