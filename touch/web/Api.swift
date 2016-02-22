//
//  api.swift
//  touch
//
//  Created by Алексей Карасев on 22/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

enum WebApiError: ErrorType {
    case InvalidResponse
}

typealias RequestCallback = (status: Int, data:[String:AnyObject]?, error:String?) -> Void

class WebApi:NSObject, NSURLSessionDelegate {
    static let shared = WebApi()
    var session: NSURLSession?
    var task: NSURLSessionTask?
    
    let url:String
    
    override init() {

        let path = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject]
        self.url = dict!["Web API URL"] as! String
        super.init()
        
        let conf = NSURLSessionConfiguration.ephemeralSessionConfiguration()
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
        let uri = NSURL(string: url)
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "GET"
        send(request: request, callback: callback)
    }

    
    func post(url url:String, payload:[String:String], callback:RequestCallback){
        let uri = NSURL(string: url)
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
        session!.dataTaskWithRequest(request) { data, response, error in
            let httpResp = response as? NSHTTPURLResponse
            if httpResp == nil {
                callback(status: 500, data: nil, error: "Failed to cast URLResponse to HTTPURLRespone: \(httpResp)")
                return
            }
            var dict:[String:AnyObject]?
            if data != nil {
                let obj = try? NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if obj == nil {
                    callback(status: 500, data: nil, error: "Failed to cast data from reponse to JSON: \(data!)")
                    return
                }
                dict = obj! as? [String:AnyObject]
                if dict == nil {
                    callback(status: 500, data: nil, error: "Failed to cast data from reponse to JSON: \(dict!)")
                    return
                }
            }
            callback(status: httpResp!.statusCode, data: dict!, error: nil)
        }
    }
}
