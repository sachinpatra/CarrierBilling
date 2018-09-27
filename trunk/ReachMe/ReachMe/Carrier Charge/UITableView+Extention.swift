//
//  UITableView+Extention.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 9/26/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import Foundation

extension UITableView {
    public func beginRefreshing() {
        guard let refreshControl = refreshControl, !refreshControl.isRefreshing else { return }
        
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
        let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height)
        setContentOffset(contentOffset, animated: true)
    }
}
