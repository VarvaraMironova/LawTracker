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
        
        requestWithParameters(urlVars) { [unowned self] (result, error) -> Void in
            if let request = result as NSURLRequest! {
                self.downloadTask = self.task(request){lastModified, data, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data) {(result, error) in
                            if nil != error {
                                completionHandler(success: false, error: error)
                            } else {
                                if let convocationsDictionary = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storeConvocations(convocationsDictionary){finished in
                                        if finished {
                                            //store current convocation
                                            if let convocationModel = LTConvocationModel.currentConvocation() as LTConvocationModel! {
                                                self.currentConvocation = convocationModel
                                                
                                                completionHandler(success: true, error: nil)
                                            } else {
                                                let currentConvocationError = LTClient.errorForMessage(LTClient.KLTMessages.noCurrentConvocation)
                                                completionHandler(success: false, error: currentConvocationError)
                                            }
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
        }
    }
    
    func downloadLaws(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill/api/
        if nil == currentConvocation {
            if let convocationModel = LTConvocationModel.currentConvocation() as LTConvocationModel! {
                self.currentConvocation = convocationModel
            } else {
                let currentConvocationError = LTClient.errorForMessage("Не вдалося завантажити законопроекти. ")
                completionHandler(success: false, error: currentConvocationError)
                
                return
            }
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.bill, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self, weak currentConvocation = currentConvocation!] (result, error) -> Void in
            if let request = result as NSURLRequest! {
                self.downloadTask = self.task(request){lastModified, data, error in
                    if nil != error {
                        //dirty hack!!
                        print("ErrorCode: ", error!.code)
                        if error!.code == -1017 {
                            self.downloadTask = self.task(request){lastModified, data, error in
                                if nil != error {
                                    completionHandler(success: false, error: error)
                                } else {
                                    LTClient.parseJSONWithCompletionHandler(data) {(result, error) in
                                        if nil != error {
                                            completionHandler(success: false, error: error)
                                        } else {
                                            if let lawsDictionary = result as? [[String: AnyObject]] {
                                                CoreDataStackManager.sharedInstance().storeLaws(lawsDictionary, convocation: currentConvocation!.id){finished in
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
                        } else {
                            completionHandler(success: false, error: error)
                        }
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data) {(result, error) in
                            if nil != error {
                                completionHandler(success: false, error: error)
                            } else {
                                if let lawsDictionary = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storeLaws(lawsDictionary, convocation: currentConvocation!.id){finished in
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
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    func downloadCommittees(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/committees/api/
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Не вдалося завантажити комітети. ")
            completionHandler(success: false, error: contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.committees, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self, weak currentConvocation = currentConvocation!] (result, error) -> Void in
            if let request = result as NSURLRequest! {
                self.downloadTask = self.task(request){lastModified, data, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data) {(result, error) in
                            if nil != error {
                                completionHandler(success: false, error: error)
                            } else {
                                if let committees = result as? [[String: AnyObject]] {
                                    CoreDataStackManager.sharedInstance().storeCommittees(committees, convocation: currentConvocation!.id){finished in
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
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    func downloadPersons(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/persons/json/deputies/<convocation's number>
        //or
        //http://www.chesno.org/persons/json/deputies/all
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Не вдалося завантажити ініціаторів. ")
            completionHandler(success: false, error: contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.persons, kVTParameters.format, kLTMethodNames.deputies, "all"]
        requestWithParameters(urlVars) {[unowned self] (result, error) -> Void in
            if let request = result as NSURLRequest! {
                self.downloadTask = self.task(request){lastModified, data, error in
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
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    func downloadInitiatorTypes(completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/initiator-types/api/
        
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Не вдалося завантажити ініціаторів. ")
            completionHandler(success: false, error: contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, kLTMethodNames.initiatorTypes, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self] (result, error) -> Void in
            if let request = result as NSURLRequest! {
                self.downloadTask = self.task(request){lastModified, data, error in
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
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    func downloadChanges(date:NSDate, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill-statuses/<yyyy-MM-dd>/api/
        
        if nil == currentConvocation {
            if let convocationModel = LTConvocationModel.currentConvocation() as LTConvocationModel! {
                self.currentConvocation = convocationModel
            } else {
                let currentConvocationError = LTClient.errorForMessage("Не вдалося завантажити останні зміни статусів законопроектів. ")
                completionHandler(success: false, error: currentConvocationError)
                
                return
            }
        }
        
        let dateString = date.string("yyyy-MM-dd", timeZone: nil)
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.billStatuses, dateString, kVTParameters.extras]
        let coreDataStackManager = CoreDataStackManager.sharedInstance()
        
        coreDataStackManager.getLastDownloadTime(dateString) {[unowned self] (time, finished) in
            if nil == time {
                coreDataStackManager.stroreLastDownloadTime(dateString, time: date)
            }
            
            let lastDownloadTime = nil == time ? kLTConstants.startDate.httpDateToNSDate() : time
            let headers = ["If-Modified-Since":lastDownloadTime!.string("EEE, dd MMM yyyy HH:mm:ss z", timeZone: "GMT")]
            
            self.requestWithParametersHeaders(urlVars, headers: headers) { (result, error) -> Void in
                if let request = result as NSURLRequest! {
                    self.downloadTask = self.task(request){lastModified, data, error in
                        print(lastModified)
                        if nil != error {
                            completionHandler(success: false, error: error)
                        } else {
                            if nil == data {
                                completionHandler(success: true, error: error)
                                
                                return
                            }
                            
                            //convert lastModified to nsdate
                            let modifiedDate = lastModified?.httpDateToNSDate()
                            //if it is impossible to get nsdate from lastModified -> use currentDate
                            let lastModifiedDate = nil == modifiedDate ? NSDate() : modifiedDate
                            LTClient.parseJSONWithCompletionHandler(data) {result, error in
                                if nil != error {
                                    completionHandler(success: false, error: error)
                                } else {
                                    if let changes = result as? [[String: AnyObject]] {
                                        coreDataStackManager.storeChanges(date, changes: changes){finished in
                                            if finished {
                                                coreDataStackManager.stroreLastDownloadTime(dateString, time:lastModifiedDate!)
                                                
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
                } else {
                    completionHandler(success: false, error: error)
                }
            }
        }
    }
    
    func getLawWithId(id: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/<convocation's id>/bill/<номер законопроекту>/api/
        if nil == currentConvocation {
            let contentError = LTClient.errorForMessage("Не вдалося завантажити деякі законопроекти. ")
            completionHandler(success: false, error: contentError)
            
            return
        }
        
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, currentConvocation!.id, kLTMethodNames.bill, id, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self, weak currentConvocation = currentConvocation!] (result, error) -> Void in
            if let request = result as NSURLRequest! {
                self.downloadTask = self.task(request){lastModified, data, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data) {result, error in
                            if nil != error {
                                completionHandler(success: false, error: error)
                            } else {
                                if var lawDictionary = result as? [String: AnyObject] {
                                    lawDictionary["number"] = id
                                    var lawArray = [NSDictionary]()
                                    lawArray.append(lawDictionary)
                                    
                                    CoreDataStackManager.sharedInstance().storeLaws(lawArray, convocation: currentConvocation!.id){finished in
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
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    func getInitiatorWithId(id: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //http://www.chesno.org/legislation/initiators/<person_id>/api/
        let urlVars = [kVTParameters.baseURL, kLTAPINames.legislation, kLTMethodNames.initiators, id, kVTParameters.extras]
        requestWithParameters(urlVars) {[unowned self] (result, error) -> Void in
            if let request = result as NSURLRequest! {
                self.downloadTask = self.task(request){lastModified, data, error in
                    if nil != error {
                        completionHandler(success: false, error: error)
                    } else {
                        LTClient.parseJSONWithCompletionHandler(data) {result, error in
                            if nil != error {
                                completionHandler(success: false, error: error)
                            } else {
                                if let person = result as? [String: AnyObject] {
                                    var personArray = [NSDictionary]()
                                    personArray.append(person)
                                    CoreDataStackManager.sharedInstance().storePersons(personArray){finished in
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
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    func getCommitteeWithId(id: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //There is no method to get committee with ID in API. So, dowload full committees list
        downloadCommittees { (success, error) -> Void in
            if success {
                completionHandler(success: success, error: nil)
            } else {
                completionHandler(success: success, error: error)
            }
        }
    }
    
    func getInitiatorTypeWithId(id: String, completionHandler:(success: Bool, error: NSError?) -> Void) {
        //There is no method to get initiator type with ID in API. So, dowload full initiatorType list
        downloadInitiatorTypes { (success, error) -> Void in
            if success {
                completionHandler(success: success, error: nil)
            } else {
                completionHandler(success: success, error: error)
            }
        }
    }
    
    func cancel() {
        if nil != downloadTask {
            downloadTask!.cancel()
        }
    }

}