//
//  DirectMessageTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/10.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit
import ODRefreshControl
import SVProgressHUD
import NoticeView

class DirectMessageTableViewController: UITableViewController {

    //=============================================
    //  instance variables
    //=============================================
    var refreshMessage: ODRefreshControl!
    var newMessageButton: UIBarButtonItem!
    var timelineModel: TimelineModel!
    
    //============================================
    //  instance methods
    //============================================
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        self.title = "DM"
        self.tabBarItem.image = UIImage(named: "Mail")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let sinceId = userDefaults.stringForKey("directMessageSinceId") as String?
        let directMessage = userDefaults.arrayForKey("directMessage") as Array?
        
        self.timelineModel = TimelineModel(initSinceId: sinceId, initTimeline: directMessage)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.refreshMessage = ODRefreshControl(inScrollView: self.tableView)
        self.refreshMessage.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.edgesForExtendedLayout = UIRectEdge.None
        
        self.tableView.registerClass(TimelineViewCell.classForCoder(), forCellReuseIdentifier: "TimelineViewCell")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
            cell = TimelineViewCell(style: .Default, reuseIdentifier: "TimelineViewCell")
        }
        cell!.cleanCell()
        if let targetMessage = self.timelineModel.getTweetAtIndex(indexPath.row) {
            cell!.configureCell(targetMessage)
        }


        return cell!
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetMessage = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetMessage)
        }
        return height
    }

    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = CGFloat(60)
        if let targetMessage = self.timelineModel.getTweetAtIndex(indexPath.row) {
            height = TimelineViewCell.estimateCellHeight(targetMessage)
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cMessageData = self.timelineModel.getTweetAtIndex(indexPath.row) {
            if TimelineModel.selectMoreIdCell(cMessageData) {
                var sinceID = cMessageData["sinceID"] as? String
                if (sinceID == "sinceID") {
                    sinceID = nil
                }
                self.updateMessage(sinceID, aMoreIndex: indexPath.row)
            } else {
                let messageModel = MessageModel(dict: cMessageData)
                let detailView = MessageDetailViewController(aMessageModel: messageModel)
                self.navigationController?.pushViewController(detailView, animated: true)
                
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func updateMessage(aSinceID: String?, aMoreIndex: Int?) {
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        self.timelineModel.updateTimeline("users/apis/direct_messages.json", aSinceID: aSinceID, aMoreIndex: aMoreIndex, streamElement: nil,
            completed: { (count, currentRowIndex) -> Void in
                self.tableView.reloadData()
                let userDefault = NSUserDefaults.standardUserDefaults()
                if (currentRowIndex != nil && userDefault.integerForKey("afterUpdatePosition") == 2) {
                    let indexPath = NSIndexPath(forRow: currentRowIndex!, inSection: 0)
                    self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
                }
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: String(count) + "件更新")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
                
            }, noUpdated: { () -> Void in
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
                let notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "新着なし")
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as! AppDelegate).alertPosition
                notice.show()
            }, failed: { () -> Void in
                
        })
    }

    
    func onRefresh() {
        self.refreshMessage.beginRefreshing()
        updateMessage(self.timelineModel.sinceId, aMoreIndex: nil)
        self.refreshMessage.endRefreshing()
        NotificationUnread.clearUnreadBadge()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.destroy()
    }
    
    func destroy() {
        self.timelineModel.saveCurrentTimeline("directMessage", sinceIdKey: "directMessageSinceId")
    }
    
    func clearData() {
        self.timelineModel.clearData()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(nil, forKey: "directMessageSinceID")
        userDefaults.setObject(nil, forKey: "directMessage")
        self.tableView.reloadData()
    }
}
