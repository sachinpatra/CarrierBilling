//
//  String+Extention.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 1/26/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}
