//
//  SJOverlayView.swift
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/24/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import UIKit

class SJOverlayView: MRProgressOverlayView {

    var progressView: MRProgressOverlayView!

    func showProgressView(animated: Bool) {
        progressView = MRProgressOverlayView.showOverlayAddedTo(UIApplication.sharedApplication().delegate!.window!, title: "Loading", mode: .Indeterminate, animated: animated)
    }
    
    func hideView(animated: Bool) {
        progressView.dismiss(animated)
    }
}
