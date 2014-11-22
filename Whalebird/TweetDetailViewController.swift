//
//  TweetDetailViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/02.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController, UIActionSheetDelegate, TTTAttributedLabelDelegate {
    let LabelPadding = CGFloat(10)
    
    //=====================================
    //  instance variables
    //=====================================
    var tweetID: String!
    var tweetBody: String?
    var screenName: String!
    var userName: String!
    var postDetail: String!
    var profileImage: String!
    var retweetedName: String?
    var retweetedProfileImage: String?
    
    var blankView: UIView!
    var screenNameLabel: UIButton!
    var userNameLabel: UIButton!
    var tweetBodyLabel: TTTAttributedLabel!
    var postDetailLabel: UILabel!
    var profileImageLabel: UIImageView!
    var retweetedNameLabel: UIButton?
    var retweetedProfileImageLabel: UIImageView?
    
    var replyButton: UIButton!
    var conversationButton: UIButton!
    var favButton: UIButton!
    var deleteButton: UIButton!
    var moreButton: UIButton!
    
    var optionButtonArea: UILabel!
    
    var newTweetButton: UIBarButtonItem!
    
    //=====================================
    //  instance method
    //=====================================
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    init(tweet_id: String, tweet_body: String, screen_name: String, user_name: String, profile_image: String, post_detail: String, retweeted_name: String?, retweeted_profile_image: String?) {
        super.init()
        self.tweetID = tweet_id
        self.tweetBody = tweet_body
        self.screenName = screen_name
        self.postDetail = WhalebirdAPIClient.convertLocalTime(post_detail)
        self.profileImage = profile_image
        self.userName = user_name
        self.retweetedName = retweeted_name
        self.retweetedProfileImage = retweeted_profile_image
        
    }
    
    override func loadView() {
        super.loadView()
        self.blankView = UIView(frame: self.view.bounds)
        self.blankView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.blankView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "tappedNewTweet:")
        self.navigationItem.rightBarButtonItem = self.newTweetButton
        
        let windowSize = UIScreen.mainScreen().bounds
        var userDefault = NSUserDefaults.standardUserDefaults()
        
        self.profileImageLabel = UIImageView(frame: CGRectMake(windowSize.size.width * 0.05, self.navigationController!.navigationBar.frame.size.height * 2.0, windowSize.size.width * 0.9, 40))
        var imageURL = NSURL(string: self.profileImage)
        var error = NSError?()
        var imageData = NSData(contentsOfURL: imageURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
        if (error == nil) {
            self.profileImageLabel.image = UIImage(data: imageData!)
            self.profileImageLabel.sizeToFit()
        }
        self.blankView.addSubview(self.profileImageLabel)
        
        if (self.retweetedProfileImage != nil) {
            self.retweetedProfileImageLabel = UIImageView(frame: CGRectMake(self.profileImageLabel.frame.origin.x + self.profileImageLabel.frame.size.width * 2.0 / 3.0, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height * 2.0 / 3.0, self.profileImageLabel.frame.size.width * 2.0 / 4.0, self.profileImageLabel.frame.size.height * 2.0 / 4.0))
            var imageURL = NSURL(string: self.retweetedProfileImage!)
            var error = NSError?()
            var imageData = NSData(contentsOfURL: imageURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
            if (error == nil) {
                self.retweetedProfileImageLabel!.image = UIImage(data: imageData!)
                self.blankView.addSubview(self.retweetedProfileImageLabel!)
            }
        }

        self.userNameLabel = UIButton(frame: CGRectMake(windowSize.size.width * 0.05 + 70, self.navigationController!.navigationBar.frame.size.height * 2.0, windowSize.size.width * 0.9, 15))
        self.userNameLabel.setTitle(self.userName, forState: .Normal)
        self.userNameLabel.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.userNameLabel.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.userNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.userNameLabel.titleEdgeInsets = UIEdgeInsetsZero
        self.userNameLabel.sizeToFit()
        self.userNameLabel.frame.size.height = self.userNameLabel.titleLabel!.frame.size.height
        self.userNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 3 ) {
            self.blankView.addSubview(self.userNameLabel)
        }
        
        self.screenNameLabel = UIButton(frame: CGRectMake(windowSize.size.width * 0.05 + 70, self.navigationController!.navigationBar.frame.size.height * 2.0 + self.userNameLabel.frame.size.height + 5, windowSize.size.width * 0.9, 15))
        self.screenNameLabel.setTitle("@" + self.screenName, forState: UIControlState.Normal)
        self.screenNameLabel.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        self.screenNameLabel.titleLabel?.font = UIFont.systemFontOfSize(13)
        self.screenNameLabel.titleLabel?.textAlignment = NSTextAlignment.Left
        self.screenNameLabel.contentEdgeInsets = UIEdgeInsetsZero
        self.screenNameLabel.sizeToFit()
        self.screenNameLabel.frame.size.height = self.screenNameLabel.titleLabel!.frame.size.height
        self.screenNameLabel.addTarget(self, action: "tappedUserProfile", forControlEvents: UIControlEvents.TouchDown)
        if (userDefault.objectForKey("displayNameType") == nil || userDefault.integerForKey("displayNameType") == 1 || userDefault.integerForKey("displayNameType") == 2 ) {
            self.blankView.addSubview(self.screenNameLabel)
        }
        
        self.tweetBodyLabel = TTTAttributedLabel(frame: CGRectMake(windowSize.size.width * 0.05, self.profileImageLabel.frame.origin.y + self.profileImageLabel.frame.size.height + self.LabelPadding + 10, windowSize.size.width * 0.9, 15))
        self.tweetBodyLabel.delegate = self
        self.tweetBodyLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        self.tweetBodyLabel.numberOfLines = 0
        self.tweetBodyLabel.font = UIFont.systemFontOfSize(15)
        self.tweetBodyLabel.text = self.tweetBody
        self.tweetBodyLabel.sizeToFit()
        self.blankView.addSubview(self.tweetBodyLabel)
        
        self.postDetailLabel = UILabel(frame: CGRectMake(windowSize.size.width * 0.05, self.tweetBodyLabel.frame.origin.y + self.tweetBodyLabel.frame.size.height + self.LabelPadding, windowSize.size.width * 0.9, 15))
        self.postDetailLabel.textAlignment = NSTextAlignment.Right
        self.postDetailLabel.text = self.postDetail
        self.postDetailLabel.font = UIFont.systemFontOfSize(11)
        self.blankView.addSubview(self.postDetailLabel)
        
        if (self.retweetedName != nil) {
            self.retweetedNameLabel = UIButton(frame: CGRectMake(windowSize.size.width * 0.05, self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + self.LabelPadding, windowSize.size.width * 0.9, 15))
            self.retweetedNameLabel?.setTitle("Retweeted by @" + self.retweetedName!, forState: UIControlState.Normal)
            self.retweetedNameLabel?.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            self.retweetedNameLabel?.titleLabel?.font = UIFont.systemFontOfSize(13)
            self.retweetedNameLabel?.contentEdgeInsets = UIEdgeInsetsZero
            self.retweetedNameLabel?.addTarget(self, action: "tappedRetweetedProfile", forControlEvents: UIControlEvents.TouchDown)
            self.blankView.addSubview(self.retweetedNameLabel!)
        }
        
        

        
        let importImage = UIImage(named: "Import-Line.png")
        self.replyButton = UIButton(frame: CGRectMake(0, 100, importImage!.size.width, importImage!.size.height))
        self.replyButton.setBackgroundImage(importImage, forState: .Normal)
        self.replyButton.center = CGPoint(x: windowSize.size.width / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
        self.replyButton.addTarget(self, action: "tappedReply", forControlEvents: UIControlEvents.TouchDown)
        self.blankView.addSubview(self.replyButton)
        
        let conversationImage = UIImage(named: "Conversation-Line.png")
        self.conversationButton = UIButton(frame: CGRectMake(0, 100, conversationImage!.size.width, conversationImage!.size.height))
        self.conversationButton.setBackgroundImage(conversationImage, forState: .Normal)
        self.conversationButton.center = CGPoint(x: windowSize.size.width * 3.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
        self.conversationButton.addTarget(self, action: "tappedConversation", forControlEvents: .TouchDown)
        self.blankView.addSubview(self.conversationButton)
        
        let starImage = UIImage(named: "Star-Line.png")
        self.favButton = UIButton(frame: CGRectMake(0, 100, starImage!.size.width, starImage!.size.height))
        self.favButton.setBackgroundImage(starImage, forState: .Normal)
        self.favButton.center = CGPoint(x: windowSize.size.width * 5.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
        self.favButton.addTarget(self, action: "tappedFavorite", forControlEvents: .TouchDown)
        self.blankView.addSubview(self.favButton)
        
        let user_default = NSUserDefaults.standardUserDefaults()
        let username = user_default.stringForKey("username")
        
        if (username == self.screenName) {
            let trashImage = UIImage(named: "Trash-Line.png")
            self.deleteButton = UIButton(frame: CGRectMake(0, 100, trashImage!.size.width, trashImage!.size.height))
            self.deleteButton.setBackgroundImage(trashImage, forState: .Normal)
            self.deleteButton.center = CGPoint(x: windowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
            self.deleteButton.addTarget(self, action: "tappedDelete", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.deleteButton)
        } else {
            let moreImage = UIImage(named: "More-Line.png")
            self.moreButton = UIButton(frame: CGRectMake(0, 100, moreImage!.size.width, moreImage!.size.height))
            self.moreButton.setBackgroundImage(moreImage, forState: .Normal)
            self.moreButton.center = CGPoint(x: windowSize.size.width * 7.0 / 8.0, y: self.postDetailLabel.frame.origin.y + self.postDetailLabel.frame.size.height + 60)
            self.moreButton.addTarget(self, action: "tappedMore", forControlEvents: .TouchDown)
            self.blankView.addSubview(self.moreButton)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //---------------------------------------------------
    // TODO: 複数人の会話の場合全員をターゲットにしているか確認
    //---------------------------------------------------
    func tappedReply() {
        var newTweetView = NewTweetViewController(TweetBody: "@" + self.screenName + " ", ReplyToID: self.tweetID)
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    func tappedConversation() {
        var conversationView = ConversationTableViewController(tweetID: self.tweetID)
        self.navigationController!.pushViewController(conversationView, animated: true)
    }
    
    //-------------------------------------------------
    //  memo: favDeleteアクションに関しては初期段階では不要
    //-------------------------------------------------
    func tappedFavorite() {
        let params:Dictionary<String, String> = [
            "id" : self.tweetID
        ]
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/favorite.json", params: parameter) { (operation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                SVProgressHUD.dismiss()
                var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "お気に入り追加")
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            })
        }
    }

    func tappedDelete() {
        var alertController = UIAlertController(title: "ツイート削除", message: "削除していい？", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: {action in
            println("OK")
            let params:Dictionary<String, String> = [
                "id" : self.tweetID
            ]
            let parameter: Dictionary<String, AnyObject> = [
                "settings" : params
            ]
            SVProgressHUD.show()
            WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/delete.json", params: parameter, callback: { (operation) -> Void in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    SVProgressHUD.dismiss()
                    var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "削除完了")
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                    self.navigationController!.popViewControllerAnimated(true)
                })
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {action in
            println("Cancel")
        })
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func tappedMore() {
        var retweetSelectSheet = UIActionSheet(title: "Retweet", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        retweetSelectSheet.addButtonWithTitle("公式RT")
        retweetSelectSheet.addButtonWithTitle("非公式RT")
        retweetSelectSheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent
        retweetSelectSheet.showInView(self.view)
        
    }
    
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex{
        case 1:
            // 公式RTの処理．直接POSTしちゃって構わない
            var alertController = UIAlertController(title: "公式RT", message: "RTしていい？", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: {action in
                println("OK")
                let params:Dictionary<String, String> = [
                    "id" : self.tweetID
                ]
                let parameter: Dictionary<String, AnyObject> = [
                    "settings" : params
                ]
                SVProgressHUD.show()
                WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/retweet.json", params: parameter, callback: { (operation) -> Void in
                    var q_main = dispatch_get_main_queue()
                    dispatch_async(q_main, {()->Void in
                        SVProgressHUD.dismiss()
                        var notice = WBSuccessNoticeView.successNoticeInView(self.navigationController!.view, title: "リツイートしました")
                        notice.alpha = 0.8
                        notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                        notice.show()
                    })
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {action in
                println("Cancel")
            })
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
            break
        case 2:
            var retweetView = NewTweetViewController(TweetBody: "RT @" + self.userName + " " + self.tweetBody!, ReplyToID: self.tweetID)
            self.navigationController!.pushViewController(retweetView, animated: true)
            break
        default:
            break
        }
    }
    
    func tappedNewTweet(sender: AnyObject) {
        var newTweetView = NewTweetViewController()
        self.navigationController!.pushViewController(newTweetView, animated: true)
    }
    
    func tappedUserProfile() {
        var userProfileView = ProfileViewController(screenName: self.screenName)
        self.navigationController!.pushViewController(userProfileView, animated: true)
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url)
    }
    
    func tappedRetweetedProfile() {
        var userProfileView = ProfileViewController(screenName: self.retweetedName!)
        self.navigationController!.pushViewController(userProfileView, animated: true)
    }
}
