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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        //check, if it is a first launch -> show helpViewController, else -> newsFeedViewController
        let window = UIWindow()
        
        let settings = VTSettingModel()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newsFeedController = storyboard.instantiateViewController(withIdentifier: "LTNewsFeedViewController") as! LTNewsFeedViewController
        let helpViewController = storyboard.instantiateViewController(withIdentifier: "LTHelpController") as! LTHelpController
        let rootController = settings.firstLaunch != true ? helpViewController : newsFeedController
        let navigationController = UINavigationController(rootViewController: rootController)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        self.window = window
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}

