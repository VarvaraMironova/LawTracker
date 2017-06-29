//
//  LTClient.swift
//  LawTracker
//
//  Created by Varvara Mironova on 1/4/16.
//  Copyright © 2016 VarvaraMironova. All rights reserved.
//

import UIKit

class LTClient: NSObject {
    var session         : URLSession
    var downloadTask    : URLSessionDataTask?
    
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
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    override init() {
        session = URLSession.shared
        
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
    class func errorForMessage(_ message: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : message]
        
        return NSError(domain: "Application Error", code: 1, userInfo: userInfo)
    }
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(nil, error)
        } else {
            completionHandler(parsedResult, nil)
        }
    }
    
    // MARK: - All purpose tasks
    func task(_ request: URLRequest, completionHandler: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            if let error = downloadError {
                completionHandler(nil, error as NSError)
            } else {
                completionHandler(data, nil)
            }
        }) 
        
        task.resume()
        
        return task
    }
    
    func taskWithURL(_ url: URL, completionHandler: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask
    {
        let task = session.dataTask(with: url, completionHandler: {data, response, downloadError in
            if let error = downloadError {
                completionHandler(nil, error as NSError)
            } else {
                completionHandler(data, nil)
            }
        }) 
        
        task.resume()
        
        return task
    }
    
    func requestWithParameters(_ params: [String], completionHandler: (_ result: URLRequest?, _ error: NSError?) -> Void) {
        urlWithParameters(params) { (result, error) in
            if let url = result as URL! {
                if let request = NSMutableURLRequest(url: url) as NSMutableURLRequest! {
                    request.httpMethod = "GET"
                    completionHandler(request as URLRequest, nil)
                } else {
                    let requestError = LTClient.errorForMessage(LTClient.KLTMessages.nsRequestError + "\(url.absoluteString)")
                    completionHandler(nil, requestError)
                }
            } else if let error = error as NSError! {
                completionHandler(nil, error)
            }
        }
    }
    
    func urlWithParameters(_ params: [String], completionHandler: (_ result: URL?, _ error: NSError?) -> Void) {
        let urlString = params.joined(separator: "/") + "/"
        if let unescapedURLString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            if let url = URL(string: unescapedURLString) as URL! {
                completionHandler(url, nil)
            } else {
                let requestError = LTClient.errorForMessage(LTClient.KLTMessages.nsURLError + "\( urlString)")
                completionHandler(nil, requestError)
            }
        } else {
            let requestError = LTClient.errorForMessage(LTClient.KLTMessages.nsURLError + "\( urlString)")
            completionHandler(nil, requestError)
        }
    }
}
