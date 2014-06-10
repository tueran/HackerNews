//
//  MainTableViewController.swift
//  HackerNews
//
//  Copyright (c) 2014 Amit Burstein. All rights reserved.
//  See LICENSE for licensing information.
//
//  Abstract:
//      Handles fetching and displaying posts from Hacker News.
//

import UIKit

class MainTableViewController: UITableViewController, UITableViewDataSource {
    
    // MARK: Properties

    let postCellIdentifier = "PostCell"
    let showBrowserIdentifier = "ShowBrowser"
    var posts = HNPost[]()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        fetchPosts()
    }
    
    // MARK: Functions
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "fetchPosts", forControlEvents: .ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        self.refreshControl = refreshControl
    }
    
    func fetchPosts() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        
        HNManager.sharedManager().loadPostsWithFilter(.Top, completion: { posts in
            if (posts != nil && posts.count > 0) {
                self.posts = posts as HNPost[]
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                    self.refreshControl.endRefreshing()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
            } else {
                println("Could not fetch posts!")
                self.refreshControl.endRefreshing()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
            }
        })
    }
    
    func stylePostCellAsRead(cell: UITableViewCell) {
        cell.textLabel.textColor = UIColor(red: 119/255.0, green: 119/255.0, blue: 119/255.0, alpha: 1)
        cell.detailTextLabel.textColor = UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier(postCellIdentifier) as UITableViewCell
        
        let post = posts[indexPath.row]
        
        if HNManager.sharedManager().hasUserReadPost(post) {
            stylePostCellAsRead(cell)
        }
        
        cell.textLabel.text = post.Title
        cell.detailTextLabel.text = "\(post.Points) points by \(post.Username)"
        
        return cell
    }
    
    // MARK: UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == showBrowserIdentifier {
            let webView = segue.destinationViewController as BrowserViewController
            let cell = sender as UITableViewCell
            let post = posts[tableView.indexPathForCell(cell).row]
            
            HNManager.sharedManager().setMarkAsReadForPost(post)
            stylePostCellAsRead(cell)

            webView.post = post
        }
    }
    
}
