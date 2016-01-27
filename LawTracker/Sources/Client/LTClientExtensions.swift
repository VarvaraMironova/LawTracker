//
//  LTClientExtensions.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import Foundation

extension LTClient {
    
    func downloadConvocations(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/council/<Verkhovna Rada's id>/convocation/api/
        let urlVars = [kVTParameters.baseURL, kLTAPINames.council, kVTParameters.radaID, kLTMethodNames.convocation, kVTParameters.extras]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        if let convocationsDictionary = result as? [[String: AnyObject]] {
                            CoreDataStackManager.sharedInstance().storeConvocations(convocationsDictionary){finished in
                                if finished {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func downloadLaws(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill/api/
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.bill, kVTParameters.extras]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        if let lawsDictionary = result as? [[String: AnyObject]] {
                            CoreDataStackManager.sharedInstance().storeLaws(lawsDictionary, convocation: self.currentConvocation!.id){finished in
                                if finished {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func downloadCommittees(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/committees/api/
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.committees, kVTParameters.extras]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        if let committees = result as? [[String: AnyObject]] {
                            CoreDataStackManager.sharedInstance().storeCommittees(committees, convocation: self.currentConvocation!.id){finished in
                                if finished {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func downloadPersons(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/persons/json/deputies/<convocation's number>
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.persons, kVTParameters.format, kLTMethodNames.deputies, currentConvocation!.number]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        if let persons = result as? [[String: AnyObject]] {
                            CoreDataStackManager.sharedInstance().storePersons(persons){finished in
                                if finished {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func downloadInitiatorTypes(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/initiator-types/api/
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, kLTMethodNames.initiatorTypes, kVTParameters.extras]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        if let types = result as? [String: AnyObject] {
                            CoreDataStackManager.sharedInstance().storeInitiatorTypes(types){finished in
                                if finished {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func downloadChanges(date:NSDate, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill-statuses/<yyyy-MM-dd>/api/
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Не вдалося завантажити зміни. Спробуйте оновити дані")
            completionHandler(success: false, error: contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.billStatuses, date.string("yyyy-MM-dd"), kVTParameters.extras]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        if let changes = result as? [[String: AnyObject]] {
                            CoreDataStackManager.sharedInstance().storeChanges(changes){finished in
                                if finished {
                                    completionHandler(success: true, error: nil)
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func getLawWithId(id: String, completionHandler:(law: LTLawModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func getInitiatorWithId(id: String, completionHandler:(initiator: LTInitiatorModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func getInitiatorTypeWithId(id: String, completionHandler:(type:LTInitiatorTypeModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func getCommitteeWithId(id: String, completionHandler:(committee:LTCommitteeModel, success: Bool, error: NSError?) -> Void) {
        
    }
    
    func cancel() {
        if nil != downloadTask {
            downloadTask!.cancel()
        }
    }

}