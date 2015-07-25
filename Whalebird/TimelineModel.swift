//
//  TimelineModel.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/07/25.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class TimelineModel: NSObject {
    //=============================================
    //  instance variables
    //=============================================
    let tweetCount = Int(50)
    var newTimeline: Array<AnyObject> = []
    var currentTimeline: Array<AnyObject> = []
    
    var sinceId: String?
    var userstreamApiClient: UserstreamAPIClient?
    
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
            if var moreID = self.currentTimeline.last?.objectForKey("id_str") as? String {
                var readMoreDictionary = NSMutableDictionary(dictionary: [
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
    
    func getTeetAtIndex(index: Int)-> NSDictionary? {
        return self.currentTimeline[index] as? NSDictionary
    }
    
    func updateTimeline(APIPath: String, aSinceID: String?, aMoreIndex: Int?, completed: (Int, Int?)-> Void, noUpdated: ()-> Void, failed: ()-> Void) {
        var params: Dictionary<String, String> = [
            "count" : String(self.tweetCount)
        ]
        if (aSinceID != nil) {
            params["since_id"] = aSinceID as String!
        }
        if (aMoreIndex != nil) {
            if var strMoreID = (self.currentTimeline[aMoreIndex!] as! NSDictionary).objectForKey("moreID") as? String {
                // max_idは「以下」という判定になるので自身を含めない
                // iPhone5以下は32bitなので，Intで扱える範囲を超える
                params["max_id"] = BigInteger(string: strMoreID).decrement()
            }
        }
        let cParameter: Dictionary<String, AnyObject> = [
            "settings" : params
        ]
        WhalebirdAPIClient.sharedClient.getArrayAPI(APIPath, displayError: true, params: cParameter,
            completed: {aNewTimeline in
                var q_main = dispatch_get_main_queue()
                dispatch_async(q_main, {()->Void in
                    self.newTimeline = []
                    for timeline in aNewTimeline {
                        if var mutableTimeline = timeline.mutableCopy() as? NSMutableDictionary {
                            self.newTimeline.append(mutableTimeline)
                        }
                    }
                    var currentRowIndex: Int?
                    if (self.newTimeline.count > 0) {
                        if (aMoreIndex == nil) {
                            // refreshによる更新
                            // index位置固定は保留
                            if (self.newTimeline.count >= self.tweetCount) {
                                var moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                                var readMoreDictionary = NSMutableDictionary()
                                if (self.currentTimeline.count > 0) {
                                    var sinceID = self.currentTimeline.first?.objectForKey("id_str") as! String
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
                                self.currentTimeline.insert(newTweet, atIndex: 0)
                                self.sinceId = (newTweet as! NSDictionary).objectForKey("id_str") as? String
                            }
                        } else {
                            // readMoreを押した場合
                            // tableの途中なのかbottomなのかの判定
                            if (aMoreIndex == self.currentTimeline.count - 1) {
                                // bottom
                                var moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                                var readMoreDictionary = NSMutableDictionary(dictionary: [
                                    "moreID" : moreID,
                                    "sinceID" : "sinceID"
                                    ])
                                self.newTimeline.insert(readMoreDictionary, atIndex: 0)
                                self.currentTimeline.removeLast()
                                self.currentTimeline += self.newTimeline.reverse()
                            } else {
                                // 途中
                                if (self.newTimeline.count >= self.tweetCount) {
                                    var moreID = self.newTimeline.first?.objectForKey("id_str") as! String
                                    var sinceID = (self.currentTimeline[aMoreIndex! + 1] as! NSDictionary).objectForKey("id_str") as! String
                                    var readMoreDictionary = NSMutableDictionary(dictionary: [
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
    
    func clearData() {
        self.currentTimeline = []
        self.newTimeline = []
        self.sinceId = nil
    }
    
    func saveCurrentTimeline(timelineKey: String, sinceIdKey: String) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var cleanTimelineArray: Array<NSMutableDictionary> = []
        let cTimelineMin = min(self.currentTimeline.count, self.tweetCount)
        if (cTimelineMin < 1) {
            return
        }
        for timeline in self.currentTimeline[0...(cTimelineMin - 1)] {
            var dic = WhalebirdAPIClient.sharedClient.cleanDictionary(timeline as! NSDictionary)
            cleanTimelineArray.append(dic)
        }
        userDefaults.setObject(cleanTimelineArray.reverse(), forKey: timelineKey)
        userDefaults.setObject(self.sinceId, forKey: sinceIdKey)
    }
    
    //----------------------------------------------
    // userstream用
    //----------------------------------------------
    func prepareUserstream() {
        var userDefault = NSUserDefaults.standardUserDefaults()
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
        // TODO: これなんとかしないと
        // できればオブジェクトを介したやりとりをしたくない，せめてブロックでなんとかならないかなぁ
        //self.timelineTable?.tableView.reloadData(
    }
    
    func stopUserstream() {
        UserstreamAPIClient.sharedClient.stopStreaming { () -> Void in
        }
    }
    //------------------------------------------------
}
