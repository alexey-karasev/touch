//
//  api.swift
//  touch
//
//  Created by Алексей Карасев on 22/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

typealias Json = [String:AnyObject]



class WebApi:NSObject, NSURLSessionDelegate, WebApiProtocol {
    typealias Callback = (result:() throws -> Json?) -> Void
    enum Error : ErrorType {
        case Unauthorized
        case ServerTimeout
        case ServerUnreachable
        case IphoneNotConnected
        case UnexpectedResponseCode(Int)
        case UnknownServer(Json)
        case InvalidJSON(String)
        case Unknown(String)
    }
    
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
    
    func get(url url:String, callback:Callback){
        let uri = NSURL(string: self.url+url+"/")
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "GET"
        send(request: request, callback: callback)
    }

    
    func post(url url:String, payload:Json?, callback:Callback){
        let uri = NSURL(string: self.url+url+"/")
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        if payload == nil {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject([:], options: [])
        }
        else {
            let payload = payload!
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(payload, options: [])
                request.HTTPBody = data
            }
            catch {
                return callback(result: { () -> Json? in
                    throw Error.InvalidJSON(self.JSONToString(payload))
                })
            }
        }
        send(request: request, callback: callback)
    }
    
    private func send(request request:NSURLRequest, callback:Callback) {
        let task = session.dataTaskWithRequest(request) {[weak self] data, response, error in
            if self == nil {
                return callback(result: {
                    throw Error.Unknown("WebApi: send: Self unexpectedly ceased to exist")
                })
            }
            if let URLSessionError = error {
                let err = self!.handleNSURLSessionError(URLSessionError)
                return callback(result: { () -> Json? in
                    throw err
                })
            }
            guard let data = data else {
                return callback(result: {
                    return [:]
                })
            }
            guard data.length > 0 else {
                return callback(result: {
                    return [:]
                })
            }
            guard let nsJSON = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
                return callback(result: {
                    throw Error.InvalidJSON(self!.NSDataToString(data))
                })
            }
            guard let json = nsJSON as? Json else {
                return callback(result: {
                    throw Error.InvalidJSON(self!.NSDataToString(data))
                })
            }
            let httpResp = response as! NSHTTPURLResponse
            if (httpResp.statusCode != 200) {
                Utils.shared.alertError("UNEXPECTED_SERVER_REPONSE_CODE")
                return callback(result: {
                    throw Error.UnexpectedResponseCode(httpResp.statusCode)
                })
            }
            
            callback(result: {
                return json
            })
        }
        task.resume()
    }
    
    private func handleNSURLSessionError (error: NSError) -> Error {
        var result: Error
        switch error.domain {
        case NSURLErrorDomain:
            switch NSURLError(rawValue: error.code)! {
            case NSURLError.TimedOut:
                Utils.shared.alertError("REQUEST_TO_SERVER_TIMED_OUT")
                result = Error.ServerTimeout
            case NSURLError.CannotConnectToHost:
                Utils.shared.alertError("CANNOT_NOT_CONNECT_TO_SERVER")
                result = Error.ServerUnreachable
            case NSURLError.NotConnectedToInternet:
                Utils.shared.alertError("IPHONE_NOT_CONNECTED_TO_INTERNET")
                result = Error.IphoneNotConnected
            case NSURLError.UserCancelledAuthentication:
                //              Will handle it upper the hierarchy
                result = Error.Unauthorized
            default:
                Utils.shared.alertError("UNKNOWN_WEB_API_ERROR")
                result = Error.Unknown("Unknown URL Session Error: \(error.description)")
            }
        default:
            Utils.shared.alertError("UNKNOWN_WEB_API_ERROR")
            result = Error.Unknown("Unknown URL Session Error: \(error.description)")
        }
        return result
    }
    
    private func NSDataToString(data: NSData) -> String {
            let jsonText = NSString(data: data,
                encoding: NSUTF8StringEncoding)
            return jsonText as! String
    }
    
    private func JSONToString(json: Json) -> String {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
            let jsonText = NSString(data: jsonData,
                encoding: NSUTF8StringEncoding)
            return jsonText as! String
        } catch let error {
            print("WebApi: JSONToSting: \(error)")
        }
    }
}
