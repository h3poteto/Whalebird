//
//  ConversationTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController {
    
    var rootTweetID: String!
    var newConversation: NSArray = NSArray()
    var conversationCell: NSMutableArray = NSMutableArray()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "会話"
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init() {
        super.init()
    }
    
    init(tweetID: String) {
        super.init()
        self.rootTweetID = tweetID
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.updateConversation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.newConversation.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }
        
        self.conversationCell.insertObject(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        cell!.configureCell(self.newConversation.objectAtIndex(indexPath.row) as NSDictionary)

        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat!
        if (self.conversationCell.count > 0 && indexPath.row < self.conversationCell.count) {
            var cell: TimelineViewCell = self.conversationCell.objectAtIndex(indexPath.row) as TimelineViewCell
            height = cell.cellHeight()
        } else {
            height = 30.0
        }
        
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweetData = self.newConversation.objectAtIndex(indexPath.row) as NSDictionary
        var detailView = TweetDetailViewController(
            TweetID: tweetData.objectForKey("id_str") as String,
            TweetBody: tweetData.objectForKey("text") as String,
            ScreenName: tweetData.objectForKey("user")?.objectForKey("screen_name") as String,
            UserName: tweetData.objectForKey("user")?.objectForKey("name") as String,
            ProfileImage: tweetData.objectForKey("user")?.objectForKey("profile_image_url") as String,
            PostDetail: tweetData.objectForKey("created_at") as String)
        self.navigationController!.pushViewController(detailView, animated: true)
    }
    
    
    func updateConversation() {
        var params: Dictionary<String, AnyObject> = [
            "id" : self.rootTweetID
        ]
        var parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/conversations.json", params: parameter) { (new_conversation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, { () -> Void in
                self.newConversation = new_conversation.reverseObjectEnumerator().allObjects
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            })
        }
    }

}
