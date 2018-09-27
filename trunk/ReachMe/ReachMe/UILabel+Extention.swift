//
//  UILabel+Extention.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 8/31/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func addOKImage(behindText: Bool) {
        textAlignment = .left
        font = UIFont.systemFont(ofSize: 12)
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "Charge_OK")
        attachment.bounds = CGRect(x: 0, y: -3, width: 15, height: 15)
        let attachmentString = NSAttributedString(attachment: attachment)
        
        guard let txt = self.text else {
            return
        }
        
        if behindText {
            let strLabelText = NSMutableAttributedString(string: txt)
            strLabelText.append(attachmentString)
            self.attributedText = strLabelText
        } else {
            let strLabelText = NSAttributedString(string: "  " + txt)
            let mutableAttachmentString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            self.attributedText = mutableAttachmentString
        }
    }
    
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
}
