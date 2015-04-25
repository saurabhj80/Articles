//
//  SJExtensions.swift
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/23/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func colorUsedInTheApp(red: CGFloat, blue: CGFloat, green: CGFloat) -> UIColor {
        let divisor: CGFloat = 255.0
        return UIColor(red: red/divisor, green: blue/divisor, blue: green/divisor, alpha: 1)
    }
    
}

extension String {
    
    func hasText() -> Bool {
        return count(self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())) > 0 ? true : false
    }
}

extension UIFont {
    
    func heightOfString(#text: String, constrainedToWidth width: Double) -> CGFloat {
        
        let size =  (text as NSString).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
        return ceil(size.height)
    }
    
    class func fontUsedInTheApp(#size: CGFloat) -> UIFont {
        return UIFont(name: "GillSans-Light", size: size)!
    }
}

extension UILabel {
    
    class func addNavLabel(title: String, size: CGFloat) -> UILabel {
        
        let label = UILabel(frame: CGRectMake(0, 0, 50, 50))
        label.textColor = UIColor.whiteColor()
        label.text = title
        label.font = UIFont.fontUsedInTheApp(size: size)
        label.sizeToFit()
        return label
    }
}