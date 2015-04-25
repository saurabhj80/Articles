//
//  SJWebViewController.swift
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/24/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.


import Foundation
import UIKit

protocol SJWebViewDelegate: NSObjectProtocol {
    func didTapDone()
}

class SJWebViewController: UIViewController {
    
    weak var delegate: SJWebViewDelegate?
    var web_url: NSURL!
    var progress: SJOverlayView!
    
    // IBOutlet
    @IBOutlet private var sj_webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress = SJOverlayView()
        sj_webView.loadRequest(NSURLRequest(URL: web_url))
        sj_webView.delegate = self
        progress.showProgressView(true)
    }
    
    @IBAction func dismiss(sender: UIBarButtonItem) {
        delegate?.didTapDone()
    }
}

extension SJWebViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        progress.hideView(true)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        progress.hideView(true)
    }
}
