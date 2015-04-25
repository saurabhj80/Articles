//
//  TableViewCell.swift
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/22/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import Foundation
import UIKit

let TEXTLABEL_FONT_SIZE: CGFloat = 22
let DETAILTEXTLABEL_FONT_SIZE: CGFloat = 14


class TableViewCell: UITableViewCell {
    
    // Headline
    var headline: String? {
        didSet {
            if let headline = headline {
                self.textLabel?.text = headline
            }
        }
    }
    
    // Lead Paragraph
    var leadParagraph: String? {
        didSet {
            if let para = leadParagraph {
                detailTextLabel?.text = para
            } else {
                detailTextLabel?.text = ""
            }
        }
    }
    
    var web_url: NSURL?
    
    
    // Initialiazation
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    private func setUp() {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.textLabel?.font = UIFont(name: "GillSans-Light", size: TEXTLABEL_FONT_SIZE)
        self.detailTextLabel?.font = UIFont(name: "GillSans-Light", size: DETAILTEXTLABEL_FONT_SIZE)
    }
}
