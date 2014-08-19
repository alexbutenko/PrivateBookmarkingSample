//
//  MasterViewController.swift
//  PrivateBookmarking
//
//  Created by alexbutenko on 7/21/14.
//  Copyright (c) 2014 alex. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [BookmarkEntity]()
    var securityManager = SecurityManager()
    var onDidSelectRow:((URL:NSURL) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("unlockData"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("lockData"), name: UIApplicationDidEnterBackgroundNotification, object: nil)

        tableView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    func lockData() {
        tableView.hidden = true
    }
    
    func unlockData() {
        reloadData()

        if (securityManager.canEvaluatePolicy() && tableView.hidden) {
            
            securityManager.evaluatePolicyWithCompletion{
                    if ($0) {
                        println("unlocked successfully")
                        dispatch_async(dispatch_get_main_queue(), {self.tableView.hidden = false})
                    } else if ($1) {
                        println("error \($1.localizedDescription)")
                    }
                }
        } else if (tableView.hidden) {
            //touch ID not enabled, skip
            self.tableView.hidden = false
        }
    }
    
    func reloadData () {

        objects = CoreDataManager.sharedInstance.allBookmarks()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            let object = objects[indexPath.row] as BookmarkEntity
            
            println("selected \(object)")
            ((segue.destinationViewController as UINavigationController).topViewController as DetailViewController).detailItem = object
        }
    }

    // #pragma mark - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object = objects[indexPath.row] as BookmarkEntity
        cell.textLabel.text = object.url
        cell.detailTextLabel.text = object.date.description
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var object = objects[indexPath.row] as BookmarkEntity
            objects.removeAtIndex(indexPath.row)
            CoreDataManager.sharedInstance.removeBookMark(object)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = objects[indexPath.row] as BookmarkEntity

        if (nil != onDidSelectRow) {
            onDidSelectRow!(URL: NSURL(string: object.url))
        }
    }
}

