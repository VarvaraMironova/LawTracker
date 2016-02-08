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
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download bills. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(success: false, error: contentError)
            
            return
        }
        
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
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download committees. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(success: false, error: contentError)
            
            return
        }
        
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
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download initiators. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(success: false, error: contentError)
            
            return
        }
        
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
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download initiators. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(success: false, error: contentError)
            
            return
        }
        
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
            let contentError = LTClient.errorForMessage("Cannot download status changes. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(success: false, error: contentError)
            
            return
        }
        
        let dateString = date.string("yyyy-MM-dd")
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.billStatuses, dateString, kVTParameters.extras]
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
                            CoreDataStackManager.sharedInstance().storeChanges(date, changes: changes){finished in
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
    
    func getLawWithId(id: String, completionHandler:(law: LTLawModel?, success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill/<номер законопроекту>/api/
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Cannot download bills. " + LTClient.KLTMessages.noCurrentConvocation)
            completionHandler(law: nil, success: false, error: contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.bill, id, kVTParameters.extras]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(law: nil, success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(law: nil, success: false, error: error)
                    } else {
                        if var lawDictionary = result as? [String: AnyObject] {
                            lawDictionary["number"] = id
                            var lawArray = [NSDictionary]()
                            lawArray.append(lawDictionary)
                            
                            CoreDataStackManager.sharedInstance().storeLaws(lawArray, convocation: self.currentConvocation!.id){finished in
                                if finished {
                                    if let lawModel = LTLawModel.lawWithNumber(id) as? LTLawModel {
                                        completionHandler(law: lawModel, success: true, error: nil)
                                    }
                                    
                                    completionHandler(law: nil, success: true, error: nil)
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(law: nil, success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func getInitiatorWithId(id: String, completionHandler:(initiator: LTInitiatorModel?, success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/initiators/<person_id>/api/
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, kLTMethodNames.initiators, id, kVTParameters.extras]
        let urlString = urlVars.joinWithSeparator("/")
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        downloadTask = task(request){data, error in
            if nil != error {
                completionHandler(initiator: nil, success: false, error: error)
            } else {
                LTClient.parseJSONWithCompletionHandler(data) {result, error in
                    if nil != error {
                        completionHandler(initiator: nil, success: false, error: error)
                    } else {
                        if let person = result as? [String: AnyObject] {
                            var personArray = [NSDictionary]()
                            personArray.append(person)
                            CoreDataStackManager.sharedInstance().storePersons(personArray){finished in
                                if finished {
                                    if let initiatorModel = LTInitiatorModel.modelWithID(id, entityName: "LTInitiatorModel") as? LTInitiatorModel {
                                        
                                        completionHandler(initiator: initiatorModel, success: true, error: nil)
                                    } else {
                                        completionHandler(initiator: nil, success: true, error: nil)
                                    }
                                }
                            }
                        } else {
                            let contentError = LTClient.errorForMessage(LTClient.KLTMessages.parseJSONError + "\(result)")
                            completionHandler(initiator: nil, success: false, error: contentError)
                        }
                    }
                }
            }
        }
    }
    
    func getCommitteeWithId(id: String, completionHandler:(committee:LTCommitteeModel?, success: Bool, error: NSError?) -> Void) {
        downloadCommittees { (success, error) -> Void in
            if success {
                if let committeeModel = LTCommitteeModel.modelWithID(id, entityName: "LTCommitteeModel") as? LTCommitteeModel {
                    completionHandler(committee: committeeModel, success: success, error: nil)
                } else {
                    completionHandler(committee: nil, success: success, error: nil)
                }
            } else {
                completionHandler(committee: nil, success: success, error: error)
            }
        }
    }
    
    func getInitiatorTypeWithId(id: String, completionHandler:(initiatorModel:LTInitiatorModel?, success: Bool, error: NSError?) -> Void) {
        downloadInitiatorTypes { (success, error) -> Void in
            if success {
                if let initiatorModel = LTInitiatorModel.modelWithID(id, entityName: "LTInitiatorModel") as? LTInitiatorModel {
                    completionHandler(initiatorModel:initiatorModel, success: success, error: nil)
                } else {
                    completionHandler(initiatorModel:nil, success: success, error: nil)
                }
            } else {
                completionHandler(initiatorModel:nil, success: success, error: error)
            }
        }
    }
    
    func cancel() {
        if nil != downloadTask {
            downloadTask!.cancel()
        }
    }

}