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
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        //check, if it is a first launch -> show helpViewController, else -> newsFeedViewController
        let window = UIWindow()
        
        let settings = VTSettingModel()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsFeedController = storyboard.instantiateViewControllerWithIdentifier("LTNewsFeedViewController") as! LTNewsFeedViewController
        let helpViewController = storyboard.instantiateViewControllerWithIdentifier("LTHelpController") as! LTHelpController
        let rootController = settings.firstLaunch != true ? helpViewController : newsFeedController
        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.navigationBarHidden = true
        
        window.rootViewController = navigationController
        self.window = window
        
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}

