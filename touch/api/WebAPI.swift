//
//  api.swift
//  touch
//
//  Created by Алексей Карасев on 22/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit


// This is a concrete implementation for remote API, communicating with restful web service
class WebAPI:RemoteJsonAPI {

    // Empty class for session delegate. Can be used for advanced functionality.
    // Passing Web API as a delefate to NSURLSession is a bad idea, as the delegate must implement
    // NSObject and Swift doesn't allow for multiple inheritance
    class SessionDelegate: NSObject, NSURLSessionDelegate {
        
    }
    
    static let shared = WebAPI() // singleton instance
    let url:String //This is the URL of the web service
    let delegate: SessionDelegate
    var session: NSURLSession
    
    override init() {
        let config = NSBundle.mainBundle().objectForInfoDictionaryKey("Config") as? NSDictionary
        self.url = config!["Web API URL"] as! String
        self.delegate = SessionDelegate()
        let conf = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        #if DEBUG
            conf.timeoutIntervalForRequest = 1.0;
            conf.timeoutIntervalForResource = 1.0;
        #endif
        self.session = NSURLSession(configuration: conf, delegate: delegate, delegateQueue: NSOperationQueue.mainQueue())
        super.init()
    }
    
    override func get(url url:String, callback:Callback){
        let uri = NSURL(string: self.url+url+"/")
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "GET"
        send(request: request, callback: callback)
    }

    
    override func post(url url:String, payload:Json?, callback:Callback){
        let uri = NSURL(string: self.url+url+"/")
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        var params: Json = Json(dictionary: [:])
        if payload != nil {params = payload!}
        request.HTTPBody = params.data
        send(request: request, callback: callback)
    }
    
    private func send(request request:NSURLRequest, callback:Callback) {
        let task = session.dataTaskWithRequest(request) {[weak self] data, response, error in
            if self == nil {
                return callback(result: {
                    throw Error.Internal("WebApi: send: Self unexpectedly ceased to exist")
                })
            }
            if let URLSessionError = error {
                let err = self!.convertNSURLSessionError(URLSessionError)
                return callback(result: {
                    throw err
                })
            }
            
            // Invalid json format errors here
            var json: Json?
            do {
                json = try Json(data: data)
            } catch let error as Json.Error {
                switch error {
                case .InvalidNSData(let data):
                    return callback(result: {
                        throw Error.InvalidServerResponse(data)
                    })
                }
            } catch {
                return callback(result: {
                    throw Error.Internal("Unexpected JSON Error")
                })
            }
            
            let httpResp = response as! NSHTTPURLResponse
            if (httpResp.statusCode != 200) {
                return callback(result: {
                    throw Error.InternalServer(json!)
                })
            }
            callback(result: {
                return json!
            })
        }
        task.resume()
    }
    
    // Converts NSURLSession Error to Error
    private func convertNSURLSessionError (error: NSError) -> Error {
        switch error.domain {
        case NSURLErrorDomain:
            switch NSURLError(rawValue: error.code)! {
            case NSURLError.TimedOut:
                return Error.ServerTimeout
            case NSURLError.CannotConnectToHost:
                return Error.ServerUnreachable
            case NSURLError.NotConnectedToInternet:
                return Error.IphoneNotConnected
            case NSURLError.UserCancelledAuthentication:
                return Error.Unauthorized
            default:
                return Error.Internal("Unexpected URL Session Error: \(error.description)")
            }
        default:
            return Error.Internal("Unexpected URL Session Error: \(error.description)")
        }
    }
}
