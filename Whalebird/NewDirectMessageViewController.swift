//
//  NewDirectMessageViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/11/12.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class NewDirectMessageViewController: UIViewController, UITextViewDelegate {
    
    var replyToUser: String!
    
    var sendToUserLabel: UILabel!
    var newMessageText: UITextView!
    var cancelButton: UIBarButtonItem!
    var sendButton: UIBarButtonItem!
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "DM送信"
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    init(ReplyToUser: String?) {
        super.init()
        self.replyToUser = ReplyToUser
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let maxSize = UIScreen.mainScreen().bounds.size

        self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "onCancelTapped")
        self.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "onSendTapped")
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.sendToUserLabel = UILabel(frame: CGRectMake(0, self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height, maxSize.width, 35))
        self.sendToUserLabel.text = "to: " + self.replyToUser
        self.sendToUserLabel.textAlignment = NSTextAlignment.Center
        self.sendToUserLabel.backgroundColor = UIColor.lightGrayColor()
        self.sendToUserLabel.center.x = maxSize.width / 2.0
        self.view.addSubview(self.sendToUserLabel)
        
        self.newMessageText = UITextView(frame: CGRectMake(0, 100, maxSize.width, maxSize.height / 3.0))
        self.newMessageText.editable = true
        self.newMessageText.delegate = self
        //self.newMessageText.addSubview(self.sendToUserLabel)
        self.view.addSubview(self.newMessageText)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func onCancelTapped() {
        self.navigationController!.popViewControllerAnimated(true)
    
    }
    
    func onSendTapped() {
        if (countElements(self.newMessageText.text as String) > 0 && self.replyToUser != nil) {
            self.postDirectMessage(self.newMessageText.text)
        }
    }
    
    func postDirectMessage(messageBody: String!) {
        var params: Dictionary<String, String>
        params = [
            "screen_name" : self.replyToUser,
            "text" : messageBody
        ]
        let parameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        
        SVProgressHUD.show()
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/direct_message_create.json", params: parameter) { (operation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, { () -> Void in
                var notice = WBSuccessNoticeView.successNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "送信しました")
                SVProgressHUD.dismiss()
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
}