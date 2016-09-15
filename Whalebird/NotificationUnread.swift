//
//  NotificationUnread.swift
//  Whalebird
//
//  Created by akirafukushima on 2015/06/20.
//  Copyright (c) 2015年 AkiraFukushima. All rights reserved.
//

import UIKit

class NotificationUnread: NSObject {
    class func decrementUnreadBadge() {
        UIApplication.shared.applicationIconBadgeNumber -= 1
        let params: Dictionary<String, AnyObject> = [:]
        WhalebirdAPIClient.sharedClient.postAnyObjectAPI("/users/apis/read.json", params: params) { (response) -> Void in
        }
    }
    
    class func clearUnreadBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
