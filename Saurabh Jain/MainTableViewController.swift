//
//  MainTableViewController.swift
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/22/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    private var resultsDictionary: NSDictionary?
    private var articles: NSArray?
    private var progress: SJOverlayView!
    private var showIndicator = true
    private var type = SJArticleType.Search

    @IBOutlet weak var searchBar: UISearchBar!
    
    let NAV_TITLE_FONT: CGFloat = 22.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress = SJOverlayView()
        
        // Add observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sj_articles:", name: DOWNLOADED_KEY, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sj_fail", name: FAILED_KEY, object: nil)
        
        // Start downloading
        Downloader.sharedDownloader().queryForArticles("Health Problems", andType: .Search)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.navigationItem.titleView = UILabel.addNavLabel("Health", size: NAV_TITLE_FONT)
        
        searchBar.delegate = self
        searchBar.keyboardAppearance = .Dark
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if showIndicator {
            progress.showProgressView(true)
        }
    }
    
    deinit {
        // Remove Observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func searchForMostViewed(sender: UIBarButtonItem) {
        
        progress.showProgressView(true)
        Downloader.sharedDownloader().queryForArticles(nil, andType: .MostViewed)
    }
}

// MARK : Notifications
extension MainTableViewController {
    
    func sj_articles(notification: NSNotification) {
        
        // Clear out the datasource
        articles = []
        
        // Clear out the rows
        var count = tableView.numberOfRowsInSection(0)
        if count > 0 {
            tableView.beginUpdates()
            for var j = 0; j < count; j++ {
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: j, inSection: 0)], withRowAnimation: .Fade)
            }
            tableView.endUpdates()
        }

        if let object: AnyObject = notification.object {
            resultsDictionary = object as? NSDictionary
            
            let userinfo = notification.userInfo!
            
            let value = SJArticleType(rawValue: userinfo["type"] as! SJArticleType.RawValue)
            
            switch value! {
                case .Search:
                    if let item1 = resultsDictionary?["response"] as? NSDictionary {
                        if let item2 = item1["docs"] as? NSArray {
                            articles = item2
                        }
                    }
                    type = .Search
                    break
                    
                case .MostViewed:
                    if let item = resultsDictionary?["results"] as? NSArray {
                        articles = item
                    }
                    type = .MostViewed
                   
                default:
                    break
            }

            // Batch updates, rather than reloading
            tableView.beginUpdates()
            
            if let articles = articles {
                for var i = 0; i < articles.count; i++ {
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
                    
                }
            }
            
            tableView.endUpdates()
        }
        
        // Hide the progress view
        progress.hideView(true)
        
    }
    
    // Download fail
    func sj_fail() {
        progress.hideView(true)
    }
}


// MARK - Table View Data Source

extension MainTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let articles = articles {
            return articles.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
                
        // Configure the cell...
        configureCell(cell, indexPath: indexPath, type: type)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.clipsToBounds = true
        
        return cell
    }
    
    private func configureCell(cell: TableViewCell, indexPath: NSIndexPath, type: SJArticleType) {
        
        if type == .Search {
            
            if let articles = articles {
                
                // The headline
                if let headline = articles[indexPath.row]["headline"] as? NSDictionary {
                    if let main = headline["main"] as? String {
                        cell.headline = main
                    }
                }
                
                // Lead Paragraph
                if let lead_paragraph = articles[indexPath.row]["lead_paragraph"] as? String {
                    cell.leadParagraph = lead_paragraph
                }
                
                // Web Url
                if let web_url = articles[indexPath.row]["web_url"] as? String {
                    cell.web_url = NSURL(string: web_url)
                }
            }
            
        } else {
            
            if let articles = articles {
                
                if let headline = articles[indexPath.row]["title"] as? String {
                    cell.headline = headline
                }
                
                if let abstract = articles[indexPath.row]["abstract"] as? String {
                    cell.leadParagraph = abstract
                }
                
                if let web_url = articles[indexPath.row]["url"] as? String {
                    cell.web_url = NSURL(string: web_url)
                }
            }
        }
        
    }
}

// MARK : Table View Delegate
extension MainTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        
        if let url = cell.web_url {
            self.performSegueWithIdentifier("webViewSegue", sender: cell)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = 0.0
        
        if let articles = articles {
            
            if type == .Search {
                if let headline = articles[indexPath.row]["headline"] as? NSDictionary {
                    if let main = headline["main"] as? String {
                        height = UIFont.fontUsedInTheApp(size: TEXTLABEL_FONT_SIZE).heightOfString(text: main, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
                    }
                }
                
                if let lead_paragraph = articles[indexPath.row]["lead_paragraph"] as? String {
                    height += UIFont.fontUsedInTheApp(size: DETAILTEXTLABEL_FONT_SIZE).heightOfString(text: lead_paragraph, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
                }
                
            } else {
                
                if let headline = articles[indexPath.row]["title"] as? String {
                    height = UIFont.fontUsedInTheApp(size: TEXTLABEL_FONT_SIZE).heightOfString(text: headline, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
                }
                
                if let abstract = articles[indexPath.row]["abstract"] as? String {
                    height += UIFont.fontUsedInTheApp(size: DETAILTEXTLABEL_FONT_SIZE).heightOfString(text: abstract, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
                }
            }
        }
        
        let padding: CGFloat = 32
        
        return height + padding
    }
    
}

// MARK : Navigation

extension MainTableViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "webViewSegue" {
            
            let controller = segue.destinationViewController as! SJWebViewController
            controller.delegate = self
            
            let cell = sender as! TableViewCell
            controller.web_url = cell.web_url
        }
    }
}

extension MainTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text.hasText() {
            progress.showProgressView(true)
            searchBar.resignFirstResponder()
        Downloader.sharedDownloader().queryForArticles(searchBar.text, andType: .Search)
        }
        searchBar.text = ""
    }
}

extension MainTableViewController: SJWebViewDelegate {
    
    func didTapDone() {
        showIndicator = false
        dismissViewControllerAnimated(true, completion: nil)
    }
}
