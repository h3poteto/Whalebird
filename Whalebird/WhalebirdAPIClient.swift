//
//  WhalebirdAPIClient.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/10/30.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class WhalebirdAPIClient: NSObject {
    
    var sessionManager: AFHTTPRequestOperationManager!
    var whalebirdAPIURL: String = NSBundle.mainBundle().objectForInfoDictionaryKey("apiurl") as String
    
    // シングルトンにするよ
    class var sharedClient: WhalebirdAPIClient {
        struct sharedStruct {
            static let _sharedClient = WhalebirdAPIClient()
        }
        return sharedStruct._sharedClient
    }
    
    //===========================================
    //  class method
    //===========================================
    class func convertLocalTime(aUtctime: String) -> String {
        var utcDateFormatter = NSDateFormatter()
        utcDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        utcDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        utcDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        var utcDate = utcDateFormatter.dateFromString(aUtctime)
        
        var jstDateFormatter =  NSDateFormatter()
        jstDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        jstDateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        jstDateFormatter.dateFormat = "MM月dd日 HH:mm"
        var jstDate = String()
        var userDefault = NSUserDefaults.standardUserDefaults()
        if (userDefault.objectForKey("displayTimeType") != nil && userDefault.integerForKey("displayTimeType") == 2) {
            var current = NSDate(timeIntervalSinceNow: 0)
            var timeInterval = current.timeIntervalSinceDate(utcDate!)
            if (timeInterval < 60) {
                jstDate = "1分以内"
            } else if(timeInterval < 3600) {
                jstDate = String(Int(timeInterval / 60.0)) + "分前"
            } else if(timeInterval < 3600 * 24) {
                jstDate = String(Int(timeInterval / 3600.0)) + "時間前"
            } else {
                jstDate = String(Int(timeInterval / (3600.0 * 24.0))) + "日前"
            }
        } else {
            jstDate = jstDateFormatter.stringFromDate(utcDate!)
        }
        return jstDate
    }
    //===========================================
    //  instance method
    //===========================================
    
    func cleanDictionary(dict: NSMutableDictionary)->NSMutableDictionary {
        var mutableDict: NSMutableDictionary = dict.mutableCopy() as NSMutableDictionary
        mutableDict.enumerateKeysAndObjectsUsingBlock { (key, obj, stop) -> Void in
            if (obj.isKindOfClass(NSNull.classForCoder())) {
                mutableDict.setObject("", forKey: (key as NSString))
            } else if (obj.isKindOfClass(NSDictionary.classForCoder())) {
                mutableDict.setObject(self.cleanDictionary(obj as NSMutableDictionary), forKey: (key as NSString))
            }
        }
        return mutableDict
    }
    
    func initAPISession() {
        self.sessionManager = AFHTTPRequestOperationManager()
        var requestURL = self.whalebirdAPIURL + "users/apis.json"
        self.sessionManager.GET(requestURL, parameters: nil, success: { (operation, responseObject) -> Void in
            println(responseObject)
            self.saveCookie()
            var userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setObject(responseObject["screen_name"], forKey: "username")
        }) { (operation, error) -> Void in
            println(error)
            if (operation.response != nil) {
                var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Server Erro", message: ("Status Code:" + String(operation.response.statusCode)))
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
            }
            SVProgressHUD.dismiss()
        }
        
    }
    
    func getArrayAPI(path: String, params: Dictionary<String, AnyObject>, callback: (NSArray) ->Void) {
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.GET(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback((responseObject as NSArray).reverseObjectEnumerator().allObjects)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                if (operation.response != nil) {
                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Server Erro", message: ("Status Code:" + String(operation.response.statusCode)))
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                }
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func getDictionaryAPI(path: String, params: Dictionary<String, AnyObject>, callback: (NSDictionary) ->Void) {
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.GET(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    callback(responseObject as NSDictionary)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                if (operation.response != nil) {
                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Server Erro", message: ("Status Code:" + String(operation.response.statusCode)))
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                }
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func postAnyObjectAPI(path: String, params: Dictionary<String, AnyObject>, callback: (AnyObject) ->Void) {
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.POST(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    var jsonError: NSError?
                    callback(operation)
                } else {
                    println("blank response")
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                if (operation.response != nil) {
                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Post  Error", message: ("Status Code:" + String(operation.response.statusCode)))
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                }
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }
    
    func deleteSsessionAPI(path: String, params: Dictionary<String, AnyObject>,callback: (AnyObject) -> Void) {
        self.loadCookie()
        if (self.sessionManager != nil) {
            var requestURL = self.whalebirdAPIURL + path
            self.sessionManager.DELETE(requestURL, parameters: params, success: { (operation, responseObject) -> Void in
                if (responseObject != nil) {
                    var jsonError: NSError?
                    callback(operation)
                } else {
                    println("blank response")
                    callback(operation)
                }
            }, failure: { (operation, error) -> Void in
                println(error)
                if (operation.response != nil) {
                    var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Delete Error", message: ("Status Code:" + String(operation.response.statusCode)))
                    notice.alpha = 0.8
                    notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                    notice.show()
                }
                SVProgressHUD.dismiss()
            })
        } else {
            self.regenerateSession()
        }
    }

    func cancelRequest() {
        if (self.sessionManager != nil) {
            self.sessionManager.operationQueue.cancelAllOperations()
        }
    }
    
    func regenerateSession() {
        var notice = WBErrorNoticeView.errorNoticeInView(UIApplication.sharedApplication().delegate?.window!, title: "Account Error", message: "アカウントを設定してください")
        notice.alpha = 0.8
        notice.originY = UIApplication.sharedApplication().statusBarFrame.height
        notice.show()
        SVProgressHUD.dismiss()
    }
    
    func loadCookie() {
        var cookiesData = NSUserDefaults.standardUserDefaults().objectForKey("cookiesKey") as? NSData
        if (cookiesData != nil) {
            var cookies = NSKeyedUnarchiver.unarchiveObjectWithData(cookiesData!) as NSArray
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie as NSHTTPCookie)
            }
            self.sessionManager = AFHTTPRequestOperationManager()
        }
    }
    
    func saveCookie() {
        var cookiesData = NSKeyedArchiver.archivedDataWithRootObject(NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies!)
        NSUserDefaults.standardUserDefaults().setObject(cookiesData, forKey: "cookiesKey")
    }
    
    func removeSession() {
        self.sessionManager = nil
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "cookiesKey")
    }
}
