
//
//  TimelineTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import Accounts
import Social

class TimelineTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var accountStore: ACAccountStore = ACAccountStore()
    var account: ACAccount?
    var newTimeline: NSMutableArray = NSMutableArray()
    var currentTimeline: NSMutableArray = NSMutableArray()
    
    var timelineCell: NSMutableArray = NSMutableArray()
    var refreshTimeline: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshTimeline = UIRefreshControl()
        self.refreshTimeline.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshTimeline)
        
        var nibName = UINib(nibName: "TimelineCellDesign", bundle: nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "TimelineViewCell")
         updateTimeline(0)
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return currentTimeline.count
    }


    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: TimelineViewCell = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as TimelineViewCell
        
        self.timelineCell.insertObject(cell, atIndex: indexPath.row)
        
        cell.configureCell(self.newTimeline.objectAtIndex(indexPath.row) as NSDictionary)

        return cell
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var height: CGFloat!
        if (self.timelineCell.count > 0 && indexPath.row < self.newTimeline.count) {
            var cell: TimelineViewCell  = self.timelineCell.objectAtIndex(indexPath.row) as TimelineViewCell
            height = cell.cellHeight()
        } else {
            height = 60.0
        }
        return height
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    func updateTimeline(since_id: Int) {
        var flag = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
        // なぜかfalseになるので強制的に実行：一時対応
        if (true) {
            var twitterAccountType: ACAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)!
            
            self.accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil, completion: {granted, error in
                if (granted) {
                    var twitterAccounts: NSArray = self.accountStore.accountsWithAccountType(twitterAccountType)
                    var url: NSURL = NSURL.URLWithString("https://api.twitter.com/1.1/statuses/home_timeline.json")
                    var params: Dictionary<String, String> = [
                        "contributor_details" : "true",
                        "trim_user" : "0",
                        "count" : "10"
                    ]
                    var request: SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: params)
                    var count = twitterAccounts.count
                    if (twitterAccounts.count > 0) {
                        request.account = twitterAccounts.lastObject as ACAccount
                        
                        request.performRequestWithHandler({responseData, urlResponse, error in
                            if (responseData != nil) {
                                if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                                    var jsonError: NSError?
                                    self.newTimeline = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSMutableArray
                                    
                                    if (self.newTimeline.count > 0) {
                                        self.currentTimeline = self.newTimeline
                                        self.tableView.reloadData()
                                    } else {
                                        println(jsonError)
                                    }
                                }
                            }
                        })
                    } else {
                        var alertController = UIAlertController(title: "Account not found", message: "設定からアカウントを登録してください", preferredStyle: UIAlertControllerStyle.Alert)
                        //var destructiveAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        //alertController.addAction(destructiveAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                }
                }
            )}
    }
    
    func onRefresh(sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(0)
        self.refreshTimeline.endRefreshing()
    }

}
