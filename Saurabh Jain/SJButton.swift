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

}
