//
//  StreamTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import ODRefreshControl
import SVProgressHUD
import NoticeView

class StreamTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var streamElement: StreamList.Stream!

    var parentNavigation: UINavigationController!
    var refreshTimeline: ODRefreshControl!
    var newTweetButton: UIBarButtonItem!
    var fCellSelect: Bool = false
    var timelineModel: TimelineModel!
    
    //=============================================
    //  instance methods
    //=============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    
    convenience init(aStreamElement: StreamList.Stream, aParentNavigation: UINavigationController) {
        self.init()
        self.streamElement = aStreamElement
        self.parentNavigation = aParentNavigation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 60.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    
        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")
        
        self.refreshTimeline = ODRefreshControl(inScrollView: self.tableView)
        self.refreshTimeline.addTarget(self, action: #selector(StreamTableViewController.onRefresh(_:)), forControlEvents: .ValueChanged)
        self.edgesForExtendedLayout = UIRectEdge.None
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sinceId = userDefaults.stringForKey(self.streamElement.name + "SinceId") as String?
        let streamTimeline = userDefaults.arrayForKey(self.streamElement.name) as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: streamTimeline)
    }

    
    override func viewWillDisappear(animated: Bool) {
        destroy()
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
        if let targetTimeline = self.timelineModel.getTweetAtIndex(indexPath.row) {
            cell!.configureCell(targetTimeline)
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetTimeline = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetTimeline)
        }
        return height
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let cTweetData = self.timelineModel.getTweetAtIndex(indexPath.row) {
            if TimelineModel.selectMoreIdCell(cTweetData) {
                self.fCellSelect = false
            } else {
                self.fCellSelect = true
            }
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cTweetData = self.timelineModel.getTweetAtIndex(indexPath.row) {
            if TimelineModel.selectMoreIdCell(cTweetData) {
                var sinceID = cTweetData["sinceID"] as? String
                if (sinceID == "sinceID") {
                    sinceID = nil
                }
                self.updateTimeline(sinceID, aMoreIndex: indexPath.row)
            } else {
                let tweetModel = TweetModel(dict: cTweetData)
                let detailView = TweetDetailViewController(aTweetModel: tweetModel, aTimelineModel: self.timelineModel, aParentIndex: indexPath.row)
                self.parentNavigation.pushViewController(detailView, animated: true)
            }
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    
    func getCurrentOffset() ->CGPoint {
        return self.tableView.contentOffset
    }
    
    func setCurrentOffset(offset: CGPoint) {
        self.tableView.setContentOffset(offset, animated: false)
    }
    
    
    
    func updateTimeline(aSinceID: String?, aMoreIndex: Int?) {

        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.timelineModel.updateTimeline("users/apis/list_timeline.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: self.streamElement,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                let userDefault = NSUserDefaults.standardUserDefaults()
                if (currentRowIndex != nil && userDefault.integerForKey("afterUpdatePosition") == 2) {
                    let indexPath = NSIndexPath(forRow: currentRowIndex!, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                }
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNoticeInView(self.parentNavigation.view, title: String(count) + "件更新")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                
            }, noUpdated: { () -> Void in
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNoticeInView(self.parentNavigation.view, title: "新着なし")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
            }, failed: { () -> Void in
                
        })
    }

    func onRefresh(sender: AnyObject) {
        self.refreshTimeline.beginRefreshing()
        updateTimeline(self.timelineModel.sinceId, aMoreIndex: nil)
        self.refreshTimeline.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    
    func destroy() {
        self.timelineModel.saveCurrentTimeline(self.streamElement.name, sinceIdKey: self.streamElement.name + "SinceId")
    }
}
