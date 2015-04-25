//
//  SJButton.swift
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/25/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import UIKit

@IBDesignable
class SJButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }

    // Drawing
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor.colorUsedInTheApp(28, blue: 111, green: 167).CGColor)
        CGContextFillRect(context, rect)
        
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(context, 2.0)
        CGContextStrokeRect(context, CGRectInset(rect, 5, 5))
    
    }
}
