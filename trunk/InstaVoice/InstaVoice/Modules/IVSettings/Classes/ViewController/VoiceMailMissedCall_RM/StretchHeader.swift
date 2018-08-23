//
//  StretchHeader.swift
//  InstaVoice
//
//  Created by Sachin Kumar Patra on 4/17/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit

open class StretchHeader: UIView {
    
    lazy var imageView : UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView())
    fileprivate var contentSize = CGSize.zero
    fileprivate var topInset : CGFloat = 0
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func commonInit() {
        backgroundColor = .lightGray
        addSubview(imageView)
    }
    
    open func stretchHeaderSize(headerSize: CGSize, imageSize: CGSize) {
        
        imageView.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height - 2) // -2 for bottom separator view
        contentSize = imageSize
        self.frame = CGRect(x: 0, y: 0, width: headerSize.width, height: headerSize.height)
    }
    
    open func updateScrollViewOffset(_ scrollView: UIScrollView) {
        
        var scrollOffset : CGFloat = scrollView.contentOffset.y
        scrollOffset += topInset
        
        if scrollOffset < 0 {
            imageView.frame = CGRect(x: scrollOffset ,y: scrollOffset, width: contentSize.width - (scrollOffset * 2) , height: contentSize.height - 2 - scrollOffset); // -2 for bottom separator view
        } else {
            imageView.frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height - 2); // -2 for bottom separator view
        }
    }
}
