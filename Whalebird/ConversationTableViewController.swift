//
//  ConversationTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/15.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import SVProgressHUD

class ConversationTableViewController: UITableViewController {
    
    //=============================================
    //  instance variables
    //=============================================
    var rootTweetID: String!
    var conversationCell: Array<AnyObject> = []
    var timelineModel: TimelineModel!
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "会話"
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    convenience init(aTweetID: String) {
        self.init()
        self.rootTweetID = aTweetID
        self.timelineModel = TimelineModel(initSinceId: nil, initTimeline: nil)
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
        return self.timelineModel.count()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TimelineViewCell? = tableView.dequeueReusableCellWithIdentifier("TimelineViewCell", forIndexPath: indexPath) as? TimelineViewCell
        if (cell == nil) {
            cell = TimelineViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TimelineViewCell")
        }
        
        self.conversationCell.insert(cell!, atIndex: indexPath.row)
        cell!.cleanCell()
        if let targetMessage = self.timelineModel.getTeetAtIndex(indexPath.row) {
            cell!.configureCell(targetMessage)
        }

        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetMessage = self.timelineModel.getTeetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetMessage)
        }
        return height
    }



    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetMessage = self.timelineModel.getTeetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetMessage)
        }
        return height
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cTweetData = self.timelineModel.getTeetAtIndex(indexPath.row) {
            var tweetModel = TweetModel(dict: cTweetData)
            var detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: indexPath.row)
            /*
            var detailView = TweetDetailViewController(
                aTweetID: cTweetData.objectForKey("id_str") as! String,
                aTweetBody: cTweetData.objectForKey("text") as! String,
                aScreenName: cTweetData.objectForKey("user")?.objectForKey("screen_name") as! String,
                aUserName: cTweetData.objectForKey("user")?.objectForKey("name") as! String,
                aProfileImage: cTweetData.objectForKey("user")?.objectForKey("profile_image_url") as! String,
                aPostDetail: cTweetData.objectForKey("created_at") as! String,
                aRetweetedName: nil,
                aRetweetedProfileImage: nil,
                aFavorited: cTweetData.objectForKey("favorited?") as? Bool,
                aMedia: cTweetData.objectForKey("media") as? NSArray,
                aTimelineModel: self.timelineModel,
                aParentIndex: indexPath.row,
                aProtected: cTweetData.objectForKey("user")?.objectForKey("protected?") as? Bool
            )*/
            self.navigationController?.pushViewController(detailView, animated: true)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    func updateConversation() {
        var params: Dictionary<String, AnyObject> = [
            "id" : self.rootTweetID
        ]
        var parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.timelineModel.updateTimelineOnlyNew("users/apis/conversations.json", requestParameter: parameter,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }, noUpdated: { () -> Void in
                SVProgressHUD.dismiss()
            }, failed: { () -> Void in
            
        })
    }

}
