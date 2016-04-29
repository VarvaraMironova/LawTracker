//
//  LTContext.swift
//  LawTracker
//
//  Created by Varvara Mironova on 4/24/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTContext: NSObject {
    
    func loadData(firstLaunch: Bool, completionHandler:(success: Bool, error: NSError?) -> Void) {
        let client = LTClient.sharedInstance()
        if firstLaunch != true {
            client.downloadConvocations({ (success, error) -> Void in
                if success {
                    client.downloadInitiatorTypes({ (success, error) -> Void in
                        if success {
                            client.downloadPersons({ (success, error) -> Void in
                                if success {
                                    client.downloadCommittees({ (success, error) -> Void in
                                        if success {
                                            client.downloadLaws({ (success, error) -> Void in
                                                completionHandler(success: success, error: error)
                                            })
                                        } else {
                                            completionHandler(success: false, error: error)
                                        }
                                    })
                                } else {
                                    completionHandler(success: false, error: error)
                                }
                            })
                        } else {
                            completionHandler(success: false, error: error)
                        }
                    })
                } else {
                    completionHandler(success: false, error: error)
                }
            })
        } else {
            client.downloadLaws({ (success, error) -> Void in
                completionHandler(success: success, error: error)
            })
        }
    }
    
    func loadChanges(date: NSDate, choosenInPicker: Bool, completionHandler:(success: Bool, error: NSError?) -> Void) {
        let queue = CoreDataStackManager.coreDataQueue()
        checkConnection { (isConnection, error) in
            if !isConnection {
                dispatch_async(queue) {
                    if let changes = LTChangeModel.changesForDate(date) as [LTChangeModel]! {
                        if changes.count > 0 {
                            completionHandler(success: true, error: nil)
                            
                            return
                        }
                    }
                    
                    let userInfo = [NSLocalizedDescriptionKey : "Немає доступу до Інтернету."]
                    let error = NSError(domain: "ConnectionError", code: -1009, userInfo: userInfo)
                    
                    completionHandler(success: false, error: error)
                }
            } else {
                //get last download time for date
                dispatch_async(queue) {[weak client = LTClient.sharedInstance()] in
                    client!.downloadChanges(date) { (success, error) -> Void in
                        completionHandler(success: success, error: error)
                    }
                }
            }
        }
    }
    
    func checkConnection(completionHandler:(isConnection: Bool, error: NSError?) -> Void) {
        //check network connection
        let status = Reach().connectionStatus()
        
        switch status {
        case .Unknown, .Offline:
            let userInfo = [NSLocalizedDescriptionKey : "Немає доступу до Інтернету."]
            let error = NSError(domain: "ConnectionError", code: -1009, userInfo: userInfo)

            completionHandler(isConnection: false, error: error)
            break
            
        default:
            completionHandler(isConnection: true, error: nil)
            break
        }
    }
    
}
