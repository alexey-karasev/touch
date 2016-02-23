//
//  api.swift
//  touch
//
//  Created by Алексей Карасев on 22/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit


typealias RequestCallback = (data:[String:AnyObject]?, error:NSError?) -> Void

class WebApi:NSObject, NSURLSessionDelegate {
    static let shared = WebApi()
    var session: NSURLSession!
    
    let url:String
    
    override init() {
        let config = NSBundle.mainBundle().objectForInfoDictionaryKey("Config") as? NSDictionary
        self.url = config!["Web API URL"] as! String
        super.init()
        
        let conf = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        #if DEBUG
            conf.timeoutIntervalForRequest = 1.0;
            conf.timeoutIntervalForResource = 1.0;
        #endif
        self.session = NSURLSession(configuration: conf, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    
    private var token:String? {
        get{
            return AppUser.shared?.token
        }
        set(newToken){
            do {
                try AppUser.update(newToken!)
            } catch {}
        }
    }
    
    func get(url url:String, callback:RequestCallback){
        let uri = NSURL(string: self.url+url)
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "GET"
        send(request: request, callback: callback)
    }

    
    func post(url url:String, payload:[String:String], callback:RequestCallback){
        let uri = NSURL(string: self.url+url+"/")
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        if let data = try? NSJSONSerialization.dataWithJSONObject(payload, options: []) {
            request.HTTPBody = data
        }
        send(request: request, callback: callback)
    }
    
    private func send(request request:NSURLRequest, callback:RequestCallback) {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if (error != nil) {
                callback(data: nil, error:error)
                return
            }
            let httpResp = response as? NSHTTPURLResponse
            if httpResp == nil {
                callback(data: nil, error: NSError(domain: NSGenericException, code: -1, userInfo: ["message":"Failed to downcast URLResponse: \(httpResp)"]))
                return
            }
            if (httpResp!.statusCode == 401) {
                callback(data: nil, error: NSError(domain: NSURLErrorDomain, code: NSURLError.UserCancelledAuthentication.rawValue, userInfo: nil))
                return
            }
            var dict:[String:AnyObject]?
            if data != nil && data!.length > 0 {
                let obj = try? NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if obj == nil {
                    callback(data: nil, error: NSError(domain: NSParseErrorException, code: -1, userInfo: ["message":"Failed to cast data from reponse to JSON: \(data!)"]))
                    return
                }
                dict = obj! as? [String:AnyObject]
                if dict == nil {
                    callback(data: nil, error: NSError(domain: NSParseErrorException, code: -1, userInfo: ["message":"Failed to cast data from reponse to JSON: \(data!)"]))
                    return
                }
            }
            callback(data: dict, error: nil)
        }
        task.resume()
    }
}
