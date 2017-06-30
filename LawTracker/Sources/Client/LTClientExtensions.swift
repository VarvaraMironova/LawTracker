//
//  LTClientExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension LTClient {
    func downloadConvocations(_ completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/council/<Verkhovna Rada's id>/convocation/api/
        let urlVars = [kVTParameters.baseURL, kLTAPINames.council, kVTParameters.radaID, kLTMethodNames.convocation, kVTParameters.extras]
        
        requestWithParameters(urlVars) { [unowned self] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {(result, error) in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if let convocationsDictionary = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storeConvocations(convocationsDictionary){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func downloadLaws(_ completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill/api/
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download initiators. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(false, contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.bill, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self, weak currentConvocation = currentConvocation!] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {(result, error) in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if let lawsDictionary = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storeLaws(lawsDictionary, convocation: currentConvocation!.id){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func downloadCommittees(_ completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/committees/api/
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download committees. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(false, contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.committees, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self, weak currentConvocation = currentConvocation!] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {(result, error) in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if let committees = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storeCommittees(committees, convocation: currentConvocation!.id){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func downloadPersons(_ completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/persons/json/deputies/<convocation's number>
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download initiators. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(false, contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.persons, kVTParameters.format, kLTMethodNames.deputies, currentConvocation!.number]
        requestWithParameters(urlVars) {[unowned self] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {result, error in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if let persons = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storePersons(persons){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func downloadInitiatorTypes(_ completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/initiator-types/api/
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download initiators. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(false, contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, kLTMethodNames.initiatorTypes, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {result, error in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if let types = result as? [String: AnyObject] {
                                    CoreDataStackManager.sharedInstance().storeInitiatorTypes(types){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func downloadChanges(_ date:Date, completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill-statuses/<yyyy-MM-dd>/api/
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download status changes. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(false, contentError)
            
            return
        }
        
        let dateString = date.string("yyyy-MM-dd")
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.billStatuses, dateString, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {result, error in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if let changes = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storeChanges(date, changes: changes){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func getLawWithId(_ id: String, completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill/<номер законопроекту>/api/
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download bills. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(false, contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.bill, id, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self, weak currentConvocation = currentConvocation!] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {result, error in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if var lawDictionary = result as? [String: AnyObject] {
                                    lawDictionary["number"] = id as AnyObject
                                    CoreDataStackManager.sharedInstance().storeLaws([lawDictionary], convocation: currentConvocation!.id){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func getInitiatorWithId(_ id: String, completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/initiators/<person_id>/api/
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, kLTMethodNames.initiators, id, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self] (result, error) -> Void in
            if let request = result as URLRequest! {
                self.downloadTask = self.task(request){data, error in
                    if nil == data {
                        completionHandler(false, error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data!) {result, error in
                            if nil != error {
                                completionHandler(false, error)
                            } else {
                                if let person = result as? [String: AnyObject] {
                                    CoreDataStackManager.sharedInstance().storePersons([person]){finished in
                                        if finished {
                                            completionHandler(true, nil)
                                        }
                                    }
                                } else {
                                    let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                                    completionHandler(false, contentError)
                                }
                            }
                        }
                    }
                }
            } else {
                completionHandler(false, error)
            }
        }
    }
    
    func getCommitteeWithId(_ id: String, completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        downloadCommittees { (success, error) -> Void in
            if success {
                completionHandler(success, nil)
            } else {
                completionHandler(success, error)
            }
        }
    }
    
    func getInitiatorTypeWithId(_ id: String, completionHandler:@escaping (_ success: Bool, _ error: NSError?) -> Void) {
        downloadInitiatorTypes { (success, error) -> Void in
            if success {
                completionHandler(success, nil)
            } else {
                completionHandler(success, error)
            }
        }
    }
    
    func cancel() {
        if nil != downloadTask {
            downloadTask!.cancel()
        }
    }

}
