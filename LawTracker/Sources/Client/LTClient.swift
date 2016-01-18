//
//  LTClient.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTClient: NSObject {
    var session         : NSURLSession
    var downloadTask    : NSURLSessionDataTask?
    var getImageDataTask: NSURLSessionTask?
    
    var methodArguments = [
        "method"        : kVTParameters.methodName,
        "api_key"       : kVTParameters.APIKey,
        "safe_search"   : kVTParameters.safeSearch,
        "extras"        : kVTParameters.extras,
        "format"        : kVTParameters.dataFormat,
        "nojsoncallback": kVTParameters.noJSONCallback,
        "per_page"      : "40"
    ]
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    override init() {
        session = NSURLSession.sharedSession()
        downloadTask = NSURLSessionDataTask()
        
        super.init()
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> LTClient {
        
        struct singleton {
            static var sharedInstance = LTClient()
        }
        
        return singleton.sharedInstance
    }
    
    // MARK: - Helpers
    class func errorForMessage(message: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : message]
        
        return NSError(domain: "Application Error", code: 1, userInfo: userInfo)
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    func escapedParameters(parameters: [String:AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: - All purpose tasks
    
    func task(request: NSURLRequest, completionHandler: (result: NSData!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func taskForImage(request: NSURLRequest, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask
    {
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(imageData: nil, error: error)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
}
