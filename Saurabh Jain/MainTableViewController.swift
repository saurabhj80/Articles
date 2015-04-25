//
//  MainTableViewController.swift
//  Saurabh Jain
//
//  Created by Saurabh Jain on 4/22/15.
//  Copyright (c) 2015 Saurabh Jain. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    // The Data
    private var resultsDictionary: NSDictionary?
    private var articles: NSArray?
    
    private var progress: SJOverlayView!
    private var showIndicator = true
    private var type = SJArticleType.Search
    
    // Search Bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Nav bar font size
    let NAV_TITLE_FONT: CGFloat = 24.0
    
    
    // MARK : VC Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress = SJOverlayView()
        
        // Add observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sj_articles:", name: DOWNLOADED_KEY, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sj_fail", name: FAILED_KEY, object: nil)
        
        // Start downloading
        Downloader.sharedDownloader().queryForArticles("Health", andType: .Search)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.navigationItem.titleView = UILabel.addNavLabel("Learn", size: NAV_TITLE_FONT)
        
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
        
        // Optional Binding
        if let object = notification.object as? NSDictionary {
            resultsDictionary = object
            
            // Clear out the datasource, in order to avoid copying
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
            
            // Get the userinfo, in order to chck the enum values
            let userinfo = notification.userInfo!
            
            // userinfo["type"] will always exist
            let value = SJArticleType(rawValue: userinfo["type"] as! SJArticleType.RawValue)
            
            // Switch on the Enum
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
    
    // Notification - Failed Download
    func sj_fail() {
        progress.hideView(true)
        
        // Later : show an alert
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
        
        // Configure the Cell
        configureCell(cell, indexPath: indexPath, type: type)
        
        // Set the number of lines to be 0
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    private func configureCell(cell: TableViewCell, indexPath: NSIndexPath, type: SJArticleType) {
        
        // Optional
        if let articles = articles {
            
            if type == .Search {
                
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
                
            } else {
                
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
        
        // Height of the cell
        var height: CGFloat = 0.0
        
        // Padding on the top and the bottom
        let padding: CGFloat = 32

        if let articles = articles {
            
            if type == .Search {
                
                dataForCellForType_Search(articles, height: &height, indexPath: indexPath)
                
            } else {
                
                dataForCellForType_MostViewed(articles, height: &height, indexPath: indexPath)
            }
        }
        
        return height + padding
    }
    
    // Search
    private func dataForCellForType_Search(articles: NSArray, inout height: CGFloat, indexPath: NSIndexPath) {
    
        if let headline = articles[indexPath.row]["headline"] as? NSDictionary {
            if let main = headline["main"] as? String {
                height = UIFont.fontUsedInTheApp(size: TEXTLABEL_FONT_SIZE).heightOfString(text: main, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
            }
        }
        
        if let lead_paragraph = articles[indexPath.row]["lead_paragraph"] as? String {
            height += UIFont.fontUsedInTheApp(size: DETAILTEXTLABEL_FONT_SIZE).heightOfString(text: lead_paragraph, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
        }
    }
    
    
    // Most Viewed
    private func dataForCellForType_MostViewed(articles: NSArray, inout height: CGFloat, indexPath: NSIndexPath) {
        
        if let headline = articles[indexPath.row]["title"] as? String {
            height = UIFont.fontUsedInTheApp(size: TEXTLABEL_FONT_SIZE).heightOfString(text: headline, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
        }
        
        if let abstract = articles[indexPath.row]["abstract"] as? String {
            height += UIFont.fontUsedInTheApp(size: DETAILTEXTLABEL_FONT_SIZE).heightOfString(text: abstract, constrainedToWidth: Double(CGRectGetWidth(tableView.bounds)))
        }
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

// MARK : Search bar Delegate
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

// MARK : The VC delegate
extension MainTableViewController: SJWebViewDelegate {
    
    func didTapDone() {
        showIndicator = false
        dismissViewControllerAnimated(true, completion: nil)
    }
}
