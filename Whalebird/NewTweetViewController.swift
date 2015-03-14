//
//  NewTweetViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditImageViewControllerDelegate {
    let optionItemBarHeight = CGFloat(40)
    let imageViewSpan = CGFloat(20)
    let progressColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
    
    var maxSize: CGSize!
    var tweetBody: String!
    var replyToID: String?
    
    var newTweetText: UITextView!
    var cancelButton: UIBarButtonItem!
    var sendButton: UIBarButtonItem!
    var photostreamButton: UIBarButtonItem?
    var cameraButton: UIBarButtonItem?
    var minuteButton: UIBarButtonItem?
    var optionItemBar: UIToolbar?
    var currentCharacters: Int = 140
    var currentCharactersView: UIBarButtonItem?
    var uploadImageView: UIImageView?
    var closeImageView: UIButton!
    var uploadedImage: String?
    var progressCount = Int(0)
    var fTopCursor = false
    

    // 右上は送信
    // アラートは敬語
    //======================================
    //  instance method
    //======================================
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "ツイート送信"
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    init(aTweetBody: String!, aReplyToID: String?, aTopCursor: Bool?) {
        super.init()
        self.tweetBody = aTweetBody
        self.replyToID = aReplyToID
        if aTopCursor != nil {
            self.fTopCursor = aTopCursor!
        }
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cWindowSize = UIScreen.mainScreen().bounds

        self.maxSize = cWindowSize.size
        
        self.cancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.Plain, target: self, action: "onCancelTapped")
        self.navigationItem.leftBarButtonItem = self.cancelButton
        
        self.sendButton = UIBarButtonItem(title: "送信", style: UIBarButtonItemStyle.Done, target: self, action: "onSendTapped")
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.newTweetText = UITextView(frame: CGRectMake(0, 0, self.maxSize.width, self.maxSize.height / 2.0))
        self.newTweetText.editable = true
        self.newTweetText.delegate = self
        self.newTweetText.font = UIFont(name: TimelineViewCell.NormalFont, size: 18)
        self.view.addSubview(self.newTweetText)
        
        self.newTweetText.keyboardAppearance = UIKeyboardAppearance.Light
        self.newTweetText.text = self.tweetBody
        self.newTweetText.becomeFirstResponder()
        if (self.fTopCursor) {
            self.newTweetText.selectedTextRange = self.newTweetText.textRangeFromPosition(self.newTweetText.beginningOfDocument, toPosition: self.newTweetText.beginningOfDocument)
        }
        self.currentCharacters = 140 - self.newTweetText.text.utf16Count
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.currentCharacters = 140 - (textView.text.utf16Count - range.length + text.utf16Count)
        if (self.currentCharactersView != nil) {
            self.currentCharactersView?.title = String(self.currentCharacters)
        }
        return true
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
        var windowSize = UIScreen.mainScreen().bounds.size
        var info = notification.userInfo as NSDictionary?
        if (info != nil) {
            self.optionItemBar?.removeFromSuperview()
            var keyboardSize = info!.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue() as CGRect?
            self.optionItemBar = UIToolbar(frame: CGRectMake(0, keyboardSize!.origin.y - self.optionItemBarHeight, windowSize.width, self.optionItemBarHeight))
            self.optionItemBar?.backgroundColor = UIColor.lightGrayColor()
            // 配置するボタン
            var spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            self.photostreamButton = UIBarButtonItem(image: UIImage(named: "assets/Image.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "openPhotostream")
            self.cameraButton = UIBarButtonItem(image: UIImage(named: "assets/Camera-Line.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "openCamera")
            self.minuteButton = UIBarButtonItem(title: "下書き", style: UIBarButtonItemStyle.Plain, target: self, action: "openMinute")
            self.currentCharactersView = UIBarButtonItem(title: String(self.currentCharacters), style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            
            var itemArray = [spacer, self.photostreamButton!, spacer, self.cameraButton!, spacer, self.minuteButton!, spacer, self.currentCharactersView!]
            self.optionItemBar?.setItems(itemArray, animated: true)
            
            self.view.addSubview(self.optionItemBar!)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.optionItemBar != nil) {
            self.optionItemBar?.removeFromSuperview()
        }
    }
    
    func onCancelTapped() {
        if (self.newTweetText.text.isEmpty) {
            self.navigationController!.popViewControllerAnimated(true)
        } else {
            var minuteSheet = UIAlertController(title: "下書き保存しますか？", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let closeAction = UIAlertAction(title: "破棄する", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.newTweetText.text = ""
                self.navigationController!.popViewControllerAnimated(true)
            })
            let minuteAction = UIAlertAction(title: "下書き保存", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                var minuteTableView = MinuteTableViewController()
                minuteTableView.addMinute(self.newTweetText.text as String, minuteReplyToID: self.replyToID)
                self.newTweetText.text = ""
                self.navigationController!.popViewControllerAnimated(true)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
            })
            minuteSheet.addAction(closeAction)
            minuteSheet.addAction(minuteAction)
            minuteSheet.addAction(cancelAction)
            self.presentViewController(minuteSheet, animated: true, completion: nil)
            
        }
        
    }
    
    func openPhotostream() {
        let ipc:UIImagePickerController = UIImagePickerController();
        ipc.delegate = self
        ipc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        ipc.allowsEditing = false
        self.presentViewController(ipc, animated:true, completion:nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            //camera ok
            let ipc:UIImagePickerController = UIImagePickerController();
            ipc.delegate = self
            ipc.sourceType = UIImagePickerControllerSourceType.Camera
            ipc.allowsEditing = false
            self.presentViewController(ipc, animated:true, completion:nil)
            
        }
        
    }
    
    func openMinute() {
        var minuteTableView = MinuteTableViewController()
        self.navigationController!.pushViewController(minuteTableView, animated: true)
        
    }
    
    func editImageViewController(editImageViewcontroller: EditImageViewController, rotationImage: UIImage) {
        var width = CGFloat(rotationImage.size.width)
        var height = CGFloat(rotationImage.size.height)
        
        if (rotationImage.size.width > rotationImage.size.height) {
            width = CGFloat(50.0)
            height = CGFloat(50.0 * rotationImage.size.height / rotationImage.size.width)
        } else {
            width = CGFloat(50.0 * rotationImage.size.width / rotationImage.size.height)
            height = CGFloat(50.0)
        }
        
        self.uploadImageView?.sizeThatFits(CGSize(width: width, height: height))
        self.uploadImageView = UIImageView(frame: CGRectMake(self.imageViewSpan, self.optionItemBar!.frame.origin.y - self.optionItemBarHeight * 2, width, height))
        self.uploadImageView?.image = rotationImage
        self.view.addSubview(self.uploadImageView!)
        
        var progressView = DACircularProgressView(frame: CGRectMake(0, 0, width * 2.0 / 3.0, height * 2.0 / 3.0))
        progressView.center = CGPoint(x: width / 2.0, y: height / 2.0)
        progressView.roundedCorners = 0
        progressView.progressTintColor = self.progressColor
        progressView.trackTintColor = UIColor.grayColor()
        progressView.setProgress(0.0, animated: true)
        self.uploadImageView!.addSubview(progressView)
        
        self.closeImageView = UIButton(frame: CGRectMake(self.uploadImageView!.frame.origin.x - 15.0, self.uploadImageView!.frame.origin.y - 20, 20.0, 20.0))
        self.closeImageView.setImage(UIImage(named: "assets/Close-Filled.png"), forState: UIControlState.Normal)
        self.closeImageView.addTarget(self, action: "removeImage", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.closeImageView)
        
        // upload処理
        // Whalebirdのapiにupload
        // ファイルパスだけ戻してもらってpostのparameterに付随させてtweet判定
        WhalebirdAPIClient.sharedClient.postImage(rotationImage, progress: { (written) -> Void in
            self.progressCount = Int(written * 100)
            println(self.progressCount)
            progressView.setProgress(CGFloat(written), animated: true)
        
        }, callback: { (response) -> Void in
            println(response)
            self.uploadedImage = (response as NSDictionary).objectForKey("filename") as? String
            progressView.removeFromSuperview()
        })
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if (info[UIImagePickerControllerOriginalImage] != nil) {
            let image:UIImage = info[UIImagePickerControllerOriginalImage]  as UIImage
            // カメラで撮影するだけでは保存はされていない
            if (picker.sourceType == UIImagePickerControllerSourceType.Camera) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            // 編集画面を挟む
            var imageEditView = EditImageViewController(aPickerImage: image, aPicker: picker)
            picker.presentViewController(imageEditView, animated: true, completion: nil)
            imageEditView.delegate = self
        }
    }
    

    func removeImage() {
        if (self.uploadImageView != nil) {
            self.uploadImageView!.removeFromSuperview()
            self.uploadImageView = nil
        }
        self.closeImageView.removeFromSuperview()
        self.uploadedImage = nil
        WhalebirdAPIClient.sharedClient.cancelRequest()
    }
    
    //-----------------------------------------
    //  送信ボタンを押した時の処理
    //-----------------------------------------
    func onSendTapped() -> Bool {
        if (self.uploadImageView != nil) {
            if (self.uploadedImage == nil) {
                var alertController = UIAlertController(title: "画像アップロード中です", message: "アップロード後にもう一度送信してください", preferredStyle: .Alert)
                let cOkAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                })
                alertController.addAction(cOkAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
                return false
            }
        }
        if (countElements(newTweetText.text as String) > 0) {
            postTweet(newTweetText.text)
            return true
        }
        return false
    }
    
    
    //-----------------------------------------
    //  whalebirdにPOST
    //-----------------------------------------
    func postTweet(aTweetBody: NSString) {
        var params: Dictionary<String, String> = [:]
        var parameter: Dictionary<String, AnyObject> = [
            "status" : newTweetText.text
        ]
        if (self.replyToID != nil) {
            params["in_reply_to_status_id"] = self.replyToID!
        }
        if (self.uploadedImage != nil) {
            params["media"] = self.uploadedImage!
        }
        
        if (params.count != 0) {
            parameter["settings"] = params
        }
        SVProgressHUD.showWithStatus("キャンセル", maskType: SVProgressHUDMaskType.Clear)
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("users/apis/tweet.json", params: parameter) { (aOperation) -> Void in
            var q_main = dispatch_get_main_queue()
            dispatch_async(q_main, {()->Void in
                var notice = WBSuccessNoticeView.successNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "投稿しました")
                SVProgressHUD.dismiss()
                notice.alpha = 0.8
                notice.originY = (UIApplication.sharedApplication().delegate as AppDelegate).alertPosition
                notice.show()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
}
