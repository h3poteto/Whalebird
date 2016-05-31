//
//  TimelineModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/07/25.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

protocol TimelineModelDelegate {
    func updateTimelineFromUserstream(timelineModel: TimelineModel)
}

class TimelineModel: NSObject {
    //=============================================
    //  instance variables
    //=============================================
    let tweetCount = Int(50)
    private var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    
    var sinceId: String?
    var userstreamApiClient: UserstreamAPIClient?
    
    var delegate: TimelineModelDelegate!
    
    // class methods
    class func selectMoreIdCell(tweetData: NSDictionary)-> Bool {
        if tweetData.objectForKey("moreID") != nil && tweetData.objectForKey("moreID") as! String != "moreID" {
            return true
        } else {
            return false
        }
    }
    
    
    convenience init(initSinceId: String?, initTimeline: Array<AnyObject>?) {
        self.init()
        self.sinceId = initSinceId
        
        if initTimeline != nil {
            for tweet in initTimeline! {
                self.currentTimeline.insert(tweet, atIndex: 0)
            }
            if let moreID = self.currentTimeline.last?.objectForKey("id_str") as? String {
                let readMoreDictionary = NSMutableDictionary(dictionary: [
                    "moreID" : moreID,
                    "sinceID" : "sinceID"
                    ])
                self.currentTimeline.insert(readMoreDictionary, atIndex: self.currentTimeline.count)
            }
        }
    }


    
    func count()-> Int {
        return self.currentTimeline.count
    }
    
    func getTweetAtIndex(index: Int)-> [NSObject : AnyObject]? {
        if let body = self.currentTimeline[index].valueForKey("text") as? String {
            TagsList.sharedClient.findAndAddtag(body)
        }
        return self.currentTimeline[index] as? [NSObject : AnyObject]
    }
    
    func setTweetAtIndex(index: Int, object: [NSObject : AnyObject]) {
        self.currentTimeline[index] = object
    }
    
    func updateTimeline(APIPath: String, aSinceID: String?, aMoreIndex: Int?, streamElement: StreamList.Stream? ,completed: (Int, Int?)-> Void, noUpdated: ()-> Void, failed: ()-> Void) {

        var apiURL = APIPath
        var params: Dictionary<String, String> = [
            "count" : String(self.tweetCount)
        ]
        if (aSinceID != nil) {
            params["since_id"] = aSinceID as String!
        }
        if (aMoreIndex != nil) {
            if let strMoreID = (self.currentTimeline[aMoreIndex!] as! NSDictionary).objectForKey("moreID") as? String {
                // max_idは「以下」という判定になるので自身を含めない
                // iPhone5以下は32bitなので，Intで扱える範囲を超える
                params["max_id"] = BigInteger(string: strMoreID).decrement()
            }
        }
        var requestParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        
        // リストのと場合だけパラメータを上書きする必要がある
        if streamElement != nil {
            apiURL = "users/apis/list_timeline.json"
            switch streamElement!.type {
            case "list":
                params["list_id"] = streamElement!.id as String!
                break
            case "myself":
                apiURL = streamElement!.uri
                break
            case "search":
                apiURL = streamElement!.uri
                break
            default:
                break
            }
            
            let userDefault = NSUserDefaults.standardUserDefaults()
            requestParameter["settings"] = params
            requestParameter["screen_name"] = userDefault.objectForKey("username") as! String
            requestParameter["q"] = streamElement!.name
        }
        WhalebirdAPIClient.sharedClient.getArrayAPI(apiURL, displayError: true, params: requestParameter,
            completed: {aNewTimeline in
                let q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    self.newTimeline = []
                    for timeline in aNewTimeline {
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.append(mutableTimeline)
                        }
                    }
                    if aMoreIndex == nil {
                        // 未読フラグの削除
                        for i in 0 ..< self.currentTimeline.count {
                            if (self.currentTimeline[i] as? NSDictionary)?.objectForKey("unread") as? Bool != nil {
                                (self.currentTimeline[i] as? NSMutableDictionary)?.removeObjectForKey("unread")
                            }
                        }
                    }

                    var currentRowIndex: Int?
                    if (self.newTimeline.count > 0) {
                        if (aMoreIndex == nil) {
                            // refreshによる更新
                            // index位置固定は保留
                            if (self.newTimeline.count >= self.tweetCount) {
                                let moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                                var readMoreDictionary = NSMutableDictionary()
                                if (self.currentTimeline.count > 0) {
                                    let sinceID = self.currentTimeline.first?.objectForKey("id_str") as! String
                                    readMoreDictionary = NSMutableDictionary(dictionary: [
                                        "moreID" : moreID,
                                        "sinceID" : sinceID
                                        ])
                                } else {
                                    readMoreDictionary = NSMutableDictionary(dictionary: [
                                        "moreID" : moreID,
                                        "sinceID" : "sinceID"
                                        ])
                                }
                                self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                            }
                            if (self.currentTimeline.count > 0) {
                                currentRowIndex = self.newTimeline.count
                            }
                            for newTweet in self.newTimeline {
                                if let tweetObject = newTweet as? NSMutableDictionary {
                                    // 未読フラグの追加
                                    tweetObject.setObject(true, forKey: "unread")
                                    self.currentTimeline.insert(tweetObject, atIndex: 0)
                                    self.sinceId = tweetObject.objectForKey("id_str") as? String
                                }
                            }
                        } else {
                            // readMoreを押した場合
                            // tableの途中なのかbottomなのかの判定
                            if (aMoreIndex == self.currentTimeline.count - 1) {
                                // bottom
                                let moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                                let readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : "sinceID"
                                    ])
                                self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                                self.currentTimeline.removeLast()
                                self.currentTimeline += Array(self.newTimeline.reverse())
                            } else {
                                // 途中
                                if (self.newTimeline.count >= self.tweetCount) {
                                    let moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                                    let sinceID = (self.currentTimeline[aMoreIndex! + 1] as! NSDictionary).objectForKey("id_str") as! String
                                    let readMoreDictionary = NSMutableDictionary(dictionary: [
                                        "moreID" : moreID,
                                        "sinceID" : sinceID
                                        ])
                                    self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                                }
                                self.currentTimeline.removeAtIndex(aMoreIndex!)
                                for newTweet in self.newTimeline {
                                    self.currentTimeline.insert(newTweet, atIndex: aMoreIndex!)
                                }
                                
                            }
                        }
                        completed(aNewTimeline.count, currentRowIndex)
                    } else {
                        noUpdated()
                    }
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    
    func updateTimelineWithoutMoreCell(APIPath: String, requestParameter: Dictionary<String, AnyObject>, moreIndex: Int?, completed: (Int, Int?)-> Void, noUpdated: ()-> Void, failed: ()-> Void) {
        WhalebirdAPIClient.sharedClient.getArrayAPI(APIPath, displayError: true, params: requestParameter,
            completed: { [unowned self] (aNewTimeline) -> Void in
                let q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    self.newTimeline = []
                    for timeline in aNewTimeline {
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.append(mutableTimeline)
                        }
                    }
                    if (moreIndex == nil) {
                        for newTweet in self.newTimeline {
                            self.currentTimeline.insert(newTweet, atIndex: 0)
                        }
                    } else {
                        for newTweet in Array(self.newTimeline.reverse()) {
                            self.currentTimeline.append(newTweet)
                        }
                    }
                    
                    completed(aNewTimeline.count, nil)
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    func updateTimelineWitoutMoreAndSince(APIPath: String, requestParameter: Dictionary<String, AnyObject>, completed: (Int, Int?)-> Void, noUpdated: ()-> Void, failed: ()-> Void) {
        WhalebirdAPIClient.sharedClient.getArrayAPI(APIPath, displayError: true, params: requestParameter,
            completed: { (aNewResult) -> Void in
                let q_main = dispatch_get_main_queue()
                dispatch_async(q_main, { () -> Void in
                    self.newTimeline = []
                    for timeline in aNewResult {
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.append(mutableTimeline)
                        }
                    }
                    if (self.newTimeline.count > 0) {
                        for newResult in self.newTimeline {
                            self.currentTimeline.insert(newResult, atIndex: 0)
                        }
                        completed(aNewResult.count, nil)
                    } else {
                        noUpdated()
                    }
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    func updateTimelineOnlyNew(APIPath: String, requestParameter: Dictionary<String, AnyObject>, completed: (Int, Int?)-> Void, noUpdated: ()-> Void, failed: ()-> Void) {
        WhalebirdAPIClient.sharedClient.getArrayAPI("users/apis/conversations.json", displayError: true, params: requestParameter,
            completed: { (aNewTimeline) -> Void in
                let q_main = dispatch_get_main_queue()
                dispatch_async(q_main, { () -> Void in
                    for timeline in aNewTimeline {
                        if let mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.insert(mutableTimeline, atIndex: 0)
                        }
                    }
                    if self.newTimeline.count > 0 {
                        self.currentTimeline = self.newTimeline
                        completed(aNewTimeline.count, nil)
                    } else{
                        noUpdated()
                    }
                })
            }, failed: { () -> Void in
                failed()
        })
    }
    
    func clearData() {
        self.currentTimeline = []
        self.newTimeline = []
        self.sinceId = nil
    }
    
    func saveCurrentTimeline(timelineKey: String, sinceIdKey: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        let cTimelineMin = min(self.currentTimeline.count, self.tweetCount)
        if (cTimelineMin < 1) {
            return
        }
        for timeline in self.currentTimeline[0...(cTimelineMin - 1)] {
            let dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as! NSDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(Array(cleanTimelineArray.reverse()), forKey: timelineKey)
        userDefaults.setObject(self.sinceId, forKey: sinceIdKey)
    }
    
    func addFavorite(index: Int) {
        if var object = self.getTweetAtIndex(index) {
            object["favorited?"] = 1
            self.setTweetAtIndex(index, object: object)
        }
    }
    
    func deleteFavorite(index: Int) {
        if var object = self.getTweetAtIndex(index) {
            object["favorited?"] = 0
            self.setTweetAtIndex(index, object: object)
        }
    }
    
    //----------------------------------------------
    // userstream用
    //----------------------------------------------
    func prepareUserstream() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        if (userDefault.boolForKey("userstreamFlag") && !UserstreamAPIClient.sharedClient.livingStream()) {
            let cStreamURL = NSURL(string: "https://userstream.twitter.com/1.1/user.json")
            let cParams: Dictionary<String,String> = [
                "with" : "followings"
            ]
            UserstreamAPIClient.sharedClient.timeline = self
            UserstreamAPIClient.sharedClient.startStreaming(cStreamURL!, params: cParams, callback: {data in
            })
        }
    }
    
    func realtimeUpdate(object: NSMutableDictionary) {
        self.currentTimeline.insert(object, atIndex: 0)
        self.sinceId = object.objectForKey("id_str") as? String
        // hometimelineの更新
        self.delegate.updateTimelineFromUserstream(self)
    }
    
    func stopUserstream() {
        UserstreamAPIClient.sharedClient.stopStreaming { () -> Void in
        }
    }
    //------------------------------------------------
}
