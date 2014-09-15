//
//  AppDelegate.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/08/09.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var rootController: UITabBarController!
    var window: UIWindow?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.whiteColor()
        
        self.rootController = UITabBarController()
        var timelineViewController = TimelineTableViewController()
        var timelineNavigationController = UINavigationController(rootViewController: timelineViewController)
        var replyViewController = ReplyTableViewController()
        var replyNavigationController = UINavigationController(rootViewController: replyViewController)
        var profileViewController = ProfileViewController()
        var profileNavigationController = UINavigationController(rootViewController: profileViewController)
        var settingsViewController = SettingsViewController()
        var settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        let controllers = NSArray(array: [timelineNavigationController, replyNavigationController, profileNavigationController, settingsNavigationController])
        self.rootController.setViewControllers(controllers, animated: true)
        self.window?.addSubview(self.rootController.view)
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    // 設定でカスタマイズさせよう
    // AlertControllerだと，そのまま開く．NoticeViewだとNoticeだけで
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if (application.applicationState == UIApplicationState.Active) {
            var tweetDetailData = notification.userInfo as NSDictionary!
            if (tweetDetailData != nil) {
                let title = (tweetDetailData.objectForKey("name") as String) + "からの返信"
                var notice = WBSuccessNoticeView.successNoticeInView(self.window, title: title)
                notice.alpha = 0.8
                notice.originY = UIApplication.sharedApplication().statusBarFrame.height
                notice.show()
                
                var alertController = UIAlertController(title: "Reply", message: tweetDetailData.objectForKey("text") as? String, preferredStyle: .Alert)
                let openAction = UIAlertAction(title: "開く", style: UIAlertActionStyle.Default, handler: {action in
                    var detailViewController = TweetDetailViewController(
                        TweetID: tweetDetailData.objectForKey("id") as String,
                        TweetBody: tweetDetailData.objectForKey("text") as String,
                        ScreenName: tweetDetailData.objectForKey("screen_name") as String,
                        UserName: tweetDetailData.objectForKey("name") as String,
                        ProfileImage: tweetDetailData.objectForKey("profile_image_url") as String,
                        PostDetail: tweetDetailData.objectForKey("created_at") as String)
                    
                    // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
                    (self.rootController.selectedViewController as UINavigationController).pushViewController(detailViewController, animated: true)

                })
                let okAction = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.Default, handler: {action in
                })
                alertController.addAction(openAction)
                alertController.addAction(okAction)
                self.rootController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        // ここでBackgroundから復帰したときの処理
        var tweetDetailData = notification.userInfo as NSDictionary!
        if (tweetDetailData != nil) {
            var detailViewController = TweetDetailViewController(
                TweetID: tweetDetailData.objectForKey("id") as String,
                TweetBody: tweetDetailData.objectForKey("text") as String,
                ScreenName: tweetDetailData.objectForKey("screen_name") as String,
                UserName: tweetDetailData.objectForKey("name") as String,
                ProfileImage: tweetDetailData.objectForKey("profile_image_url") as String,
                PostDetail: tweetDetailData.objectForKey("created_at") as String)
        
            // ここで遷移させる必要があるので，すべてのViewはnavigationControllerの上に実装する必要がある
            (self.rootController.selectedViewController as UINavigationController).pushViewController(detailViewController, animated: true)
        }
        UIApplication.sharedApplication().cancelLocalNotification(notification)
    }


}

