//
//  AppDelegate.swift
//  LawTracker
//
//  Created by Varvara Mironova on 11/30/15.
//  Copyright © 2015 VarvaraMironova. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        //check, if it is a first launch -> show helpViewController, else -> newsFeedViewController
        let window = UIWindow()
        
        let settings = VTSettingModel()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsFeedController = storyboard.instantiateViewControllerWithIdentifier("LTNewsFeedViewController") as! LTNewsFeedViewController
        let helpViewController = storyboard.instantiateViewControllerWithIdentifier("LTHelpViewController") as! LTHelpViewController
        let rootController = settings.firstLaunch != true ? helpViewController : newsFeedController
        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.navigationBarHidden = true
        
        window.rootViewController = navigationController
        self.window = window
        
        return true
    }

//    func applicationWillResignActive(application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    }
//
//    func applicationDidEnterBackground(application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//
//    func applicationWillEnterForeground(application: UIApplication) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    }
//
//    func applicationDidBecomeActive(application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }
//
    func applicationWillTerminate(application: UIApplication) {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}

