//
//  api.swift
//  touch
//
//  Created by Алексей Карасев on 22/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

typealias WebApiCallback = (data:Json?, error:ApiError?, errorPayload:Json?) -> Void


class WebApi:NSObject, NSURLSessionDelegate, WebApiProtocol {
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
    
    func get(url url:String, callback:WebApiCallback){
        let uri = NSURL(string: self.url+url)
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "GET"
        send(request: request, callback: callback)
    }

    
    func post(url url:String, payload:Json?, callback:WebApiCallback){
        let uri = NSURL(string: self.url+url+"/")
        let request = NSMutableURLRequest(URL: uri!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = "POST"
        if payload != nil {
            if let data = try? NSJSONSerialization.dataWithJSONObject(payload!, options: []) {
                request.HTTPBody = data
            }
        }
        send(request: request, callback: callback)
    }
    
    private func send(request request:NSURLRequest, callback:WebApiCallback) {
        let task = session.dataTaskWithRequest(request) {[weak self] data, response, error in
            if self == nil {
                return
            }
            if (error != nil) {
                let apiError = self!.errorToApiError(error!)
                callback(data: nil, error:apiError.error, errorPayload:apiError.payload)
                return
            }
            let httpResp = response as? NSHTTPURLResponse
            if httpResp == nil {
                callback(data: nil, error: ApiError.Unknown, errorPayload: ["description":"Failed to downcast URLResponse: \(httpResp)"])
                return
            }
            var dict:Json?
            if data != nil && data!.length > 0 {
                let obj = try? NSJSONSerialization.JSONObjectWithData(data!, options: [])
                if obj == nil {
                    callback(data: nil, error: ApiError.InvalidJSON, errorPayload: ["description":"Failed to cast data from reponse to JSON: \(data!)"])
                    return
                }
                dict = obj! as? Json
                if dict == nil {
                    callback(data: nil, error: ApiError.InvalidJSON, errorPayload: ["description":"Failed to cast data from reponse to JSON: \(data!)"])
                    return
                }
                if (httpResp!.statusCode != 200) {
                    let apiError = self!.reponseToApiError(dict!)
                    callback(data: nil, error:apiError.error, errorPayload:apiError.payload)
                    return
                }
            }
            callback(data: dict, error: nil, errorPayload: nil)
        }
        task.resume()
    }
    
    private func errorToApiError(err: NSError) -> (error: ApiError, payload: Json?) {
        switch err.domain {
        case NSURLErrorDomain:
            switch NSURLError(rawValue: err.code)! {
            case NSURLError.TimedOut:
                return (ApiError.ServerTimeout, nil)
            case NSURLError.CannotConnectToHost:
                return (ApiError.ServerUnreachable, nil)
            case NSURLError.NotConnectedToInternet:
                return (ApiError.IphoneNotConnected, nil)
            case NSURLError.UserCancelledAuthentication:
                return (ApiError.Unauthorized, nil)
            default: break
            }
        default:
            return (ApiError.Unknown, ["error":err])
        }
        return (ApiError.Unknown, ["error":err])
    }
    
    private func reponseToApiError(data: Json?) -> (error: ApiError, payload: Json?) {
        if let json = data {
            let error = json["error"] as? Json
            if error == nil {
                return (ApiError.InvalidJSON, json)
            }
            let id = error!["id"]
            if id == nil {
                return (ApiError.InvalidJSON, json)
            }
            let strId = id as? String
            if strId == nil {
                return (ApiError.InvalidJSON, json)
            }
            let payload = error!["payload"]
            if payload == nil {
                return (ApiError.InvalidJSON, json)
            }
            let jsonPayload = payload! as? Json
            if jsonPayload == nil {
                return (ApiError.InvalidJSON, json)
            }
            
            switch strId! {
            case "NOT_UNIQUE_FIELD":
                return (ApiError.NotUniqueField, jsonPayload)
            case "EMPTY_FIELD":
                return (ApiError.EmptyField, jsonPayload)
            case "NOT_FOUND":
                return (ApiError.NotFound, jsonPayload)
            case "INVALID_USER_CREDENTIALS":
                return (ApiError.InvalidUserCredentials, jsonPayload)
            case "USER_NOT_CONFIRMED":
                return (ApiError.UserNotConfirmed, jsonPayload)
            case "INVALID_CONFIRMATION_CODE":
                return (ApiError.InvalidConfirmationCode, jsonPayload)
            case "UNKNOWN":
                return (ApiError.UnknownServer, jsonPayload)
            default:
                return (ApiError.UnknownServer, jsonPayload)
            }
        }
        return (ApiError.UnknownServer, nil)
    }
}
