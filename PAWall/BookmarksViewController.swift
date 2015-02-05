
//
//  BookmarksViewController.swift
//  PAWall
//
//  Created by D on 2/4/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class BookmarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myBookmarks:[PFObject] = [PFObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var myLocation:PFGeoPoint = PFGeoPoint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
//        self.tableView.estimatedRowHeight = 100.0
//        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            //TODO: handle error properly
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                // do something with the new geoPoint
                self.myLocation = geoPoint
            }
        }
        
        var query = PFQuery(className:GBOOKMARK.CLASS_NAME)
        
        query.whereKey(GBOOKMARK.CREATED_BY, equalTo: DEVICE_UUID) // all bookmarks created by me
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                
                NSLog("Successfully retrieved \(objects.count) bookmarks")
                self.myBookmarks = objects as [PFObject]
                self.tableView.reloadData()
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
                
                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving bookmarks, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myBookmarks.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var bookmark:PFObject = myBookmarks[indexPath.row]
        
        var cell:BookmarkTableViewCell = BookmarkTableViewCell()
        
        cell  = self.tableView.dequeueReusableCellWithIdentifier("bookmark_cell") as BookmarkTableViewCell
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        cell.createdAt.text = NSString(format: "%@", df.stringFromDate(bookmark.createdAt))
        cell.bookmarkText.text = bookmark[GBOOKMARK.SEARCH_TEXT] as? String
        let roundedDistance = roundMoney((bookmark[GBOOKMARK.LOCATION] as PFGeoPoint).distanceInMilesTo(myLocation))
//        cell.distance.text = "\(roundedDistance) Miles"
        
        let deleteButton:UIButton = cell.deleteButton
        
        deleteButton.tag = indexPath.row
        deleteButton.addTarget(self, action: "deleteButtonClicket:", forControlEvents: UIControlEvents.TouchUpInside)

        return cell
    }
    
    func deleteButtonClicket(sender:UIButton) {
        let deleteButton:UIButton = sender as UIButton
        let buttonRow:Int = sender.tag
        NSLog("button clicked: \(buttonRow)")
        
        let bookmarkObject = myBookmarks[buttonRow]

        
        let alertMessage = UIAlertController(title: "Warning", message: "Sure want to delete bookmark?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in})
        let ok =     UIAlertAction(title: "OK",     style: .Default, handler: { (action) -> Void in
            bookmarkObject.delete()
            self.myBookmarks.removeAtIndex(buttonRow)
            self.tableView.reloadData()
        })
        alertMessage.addAction(cancel)
        alertMessage.addAction(ok)
        presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell #\(indexPath.row)!")
        
        if self.parentViewController as? UITabBarController != nil {
            var tababarController = self.parentViewController as UITabBarController
            let searchPostsViewController:SearchPostsViewController = tababarController.viewControllers![0] as SearchPostsViewController
            let searchForText:String = myBookmarks[indexPath.row][GBOOKMARK.SEARCH_TEXT] as String

            tababarController.selectedIndex = 0

            searchPostsViewController.searchBar.becomeFirstResponder()
            searchPostsViewController.searchBar.text = searchForText
            searchPostsViewController.filterContentForSearchText(searchForText)

        }

    }
    

}
