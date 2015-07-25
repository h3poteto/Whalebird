
//
//  TimelineTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TimelineTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    //=============================================
    //  instance variables
    //=============================================
    
    var refreshTimeline: ODRefreshControl!
    
    var newTweetButton: UIBarButtonItem!
    
    var timelineModel: TimelineModel!
    
    //=========================================
    //  instance methods
    //=========================================
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "タイムライン"
        self.tabBarItem.image = UIImage(named: "assets/Home.png")
    }
    
    
    override init(style: UITableViewStyle) {
        super.init(style: UITableViewStyle.Plain)
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshTimeline = ODRefreshControl(inScrollView: self.tableView)
        self.refreshTimeline.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "tappedNewTweet")
        self.navigationItem.rightBarButtonItem = self.newTweetButton

        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")

        var userDefaults = NSUserDefaults.standardUserDefaults()
        var getSinceId = userDefaults.stringForKey("homeTimelineSinceId") as String?
        var homeTimeline = userDefaults.arrayForKey("homeTimeline") as Array?
        
        self.timelineModel = TimelineModel(getSinceId: getSinceId, initTimeline: homeTimeline)
        
        // userstream発火のために必要
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidBecomeActive:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillResignActive:", name: UIApplicationWillResignActiveNotification, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Home用のUserstream
        // TODO: timelineのモデル化によりこれは機能しなくなる
        //self.prepareUserstream()
    }
    
    func prepareUserstream() {
        var userDefault = NSUserDefaults.standardUserDefaults()
        if (userDefault.boolForKey("userstreamFlag") && !UserstreamAPIClient.sharedClient.livingStream()) {
            let cStreamURL = NSURL(string: "https://userstream.twitter.com/1.1/user.json")
            let cParams: Dictionary<String,String> = [
                "with" : "followings"
            ]
            UserstreamAPIClient.sharedClient.timelineTable = self
            UserstreamAPIClient.sharedClient.startStreaming(cStreamURL!, params: cParams, callback: {data in
            })
        }
    }
    
    func appDidBecomeActive(notification: NSNotification) {
        //self.prepareUserstream()
    }
    
    func appWillResignActive(notification: NSNotification) {
        UserstreamAPIClient.sharedClient.stopStreaming { () -> Void in
        }
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

        cell!.cleanCell()
        if let targetTimeline = self.timelineModel.getTeetAtIndex(indexPath.row) {
            cell!.configureCell(targetTimeline)
        }

        return cell!
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTeetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTeetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cTweetData = self.timelineModel.getTeetAtIndex(indexPath.row) {
            if TimelineModel.selectMoreIdCell(cTweetData) {
                var sinceID = cTweetData.objectForKey("sinceID") as? String
                if (sinceID == "sinceID") {
                    sinceID = nil
                }
                self.updateTimeline(sinceID, aMoreIndex: indexPath.row)
            } else {
                var detailView = TweetDetailViewController(
                    aTweetID: cTweetData.objectForKey("id_str") as! String,
                    aTweetBody: cTweetData.objectForKey("text")as! String,
                    aScreenName: cTweetData.objectForKey("user")?.objectForKey("screen_name") as! String,
                    aUserName: cTweetData.objectForKey("user")?.objectForKey("name") as! String,
                    aProfileImage: cTweetData.objectForKey("user")?.objectForKey("profile_image_url") as! String,
                    aPostDetail: cTweetData.objectForKey("created_at") as! String,
                    aRetweetedName: cTweetData.objectForKey("retweeted")?.objectForKey("screen_name") as? String,
                    aRetweetedProfileImage: cTweetData.objectForKey("retweeted")?.objectForKey("profile_image_url") as? String,
                    aFavorited: cTweetData.objectForKey("favorited?") as? Bool,
                    aMedia: cTweetData.objectForKey("media") as? NSArray,
                    aParentArray: &self.timelineModel.currentTimeline,
                    aParentIndex: indexPath.row,
                    aProtected: cTweetData.objectForKey("user")?.objectForKey("protected?") as? Bool
                )
                self.navigationController?.pushViewController(detailView, animated: true)
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }


    
    func updateTimeline(aSinceID: String?, aMoreIndex: Int?) {
        
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.timelineModel.updateTimeline(aSinceID, aMoreIndex: aMoreIndex,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                var userDefault = NSUserDefaults.standardUserDefaults()
                if (currentRowIndex != nil && userDefault.integerForKey("afterUpdatePosition") == 2) {
                var indexPath = NSIndexPath(forRow: currentRowIndex!, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                }
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(count) + "件更新")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
            
            }, noUpdated: { () -> Void in
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "新着なし")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
            }, failed: { () -> Void in
            
        })
        
    }
    
    func onRefresh() {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.timelineModel.sinceId, aMoreIndex: nil)
        self.refreshTimeline.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    func tappedNewTweet() {
        var newTweetView = NewTweetViewController()
        self.navigationController?.pushViewController(newTweetView, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        destroy()
    }

    func destroy() {
        self.timelineModel.saveCurrentTimeline("homeTimeline", sinceIdKey: "homeTimelineSinceID")
    }
    // これログアウトで使う
    func clearData() {
        self.timelineModel.clearData()
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "homeTimelineSinceID")
        userDefaults.setObject(nil, forKey: "homeTimeline")
        self.tableView.reloadData()
    }
}
