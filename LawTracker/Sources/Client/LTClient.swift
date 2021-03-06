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
    
    var methodArguments = [
        "api"           : String(),
        "format"        : String(),
        "rada"          : String(),
        "convocation"   : String(),
        "method"        : String(),
        "extras"        : String()
    ]
    
    lazy var currentConvocation: LTConvocationModel? = {
        if let convocationModel = LTConvocationModel.currentConvocation() as LTConvocationModel! {
            return convocationModel
        }
        
        return nil
    }()
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    override init() {
        session = NSURLSession.sharedSession()
        
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
    
    func taskWithURL(url: NSURL, completionHandler: (result: NSData!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
        let task = session.dataTaskWithURL(url) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    func requestWithParameters(params: [String], completionHandler: (result: NSURLRequest?, error: NSError?) -> Void) {
        urlWithParameters(params) { (result, error) in
            if let url = result as NSURL! {
                if let request = NSMutableURLRequest(URL: url) as NSMutableURLRequest! {
                    request.HTTPMethod = "GET"
                    completionHandler(result: request, error: nil)
                } else {
                    let requestError = LTClient.errorForMessage(LTClient.KLTMessages.nsRequestError + "\(url.absoluteString)")
                    completionHandler(result: nil, error: requestError)
                }
            } else if let error = error as NSError! {
                completionHandler(result: nil, error: error)
            }
        }
    }
    
    func urlWithParameters(params: [String], completionHandler: (result: NSURL?, error: NSError?) -> Void) {
        let urlString = params.joinWithSeparator("/") + "/"
        if let unescapedURLString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            if let url = NSURL(string: unescapedURLString) as NSURL! {
                completionHandler(result: url, error: nil)
            } else {
                let requestError = LTClient.errorForMessage(LTClient.KLTMessages.nsURLError + "\( urlString)")
                completionHandler(result: nil, error: requestError)
            }
        } else {
            let requestError = LTClient.errorForMessage(LTClient.KLTMessages.nsURLError + "\( urlString)")
            completionHandler(result: nil, error: requestError)
        }
    }
}
