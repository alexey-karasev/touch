//
//  Api.swift
//  touch
//
//  Created by Алексей Карасев on 28/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit


// This is the basic API interface, can be easily switched to use any RemoteJsonAPI implementation
class API {
    enum Error: ErrorType {
        // propagates up
        case Unauthorized
        case UnknownServer(Json)
        
        // already handled by Web API
        case WebApi(WebAPI.Error)
        
        // Unexpected internal error
        case Unknown(String)
    }

    typealias Result = () throws -> Json?
    typealias Callback = (result:Result) -> Void
    
    static var shared = API()
    var delegate:RemoteJsonAPI = WebAPI()
    var currentCallback: Callback?
    
    func get(url url:String, callback:Callback) {
        delegate.get(url: url) { [weak self](result) -> Void in
            if self != nil {
                self!.processCallback(result, callback: callback)
            }
        }
    }
    
    func post(url url:String, payload:Json?, callback:Callback) {
        delegate.post(url: url, payload: payload) { [weak self] result in
            if self != nil {
                self!.processCallback(result, callback: callback)
            }
        }
    }
    
    private func processCallback(result: RemoteJsonAPI.Result, callback: Callback) {
        do {
            let res = try result()
            callback(result: {
                return res
            })
        } catch let error as RemoteJsonAPI.Error {
            switch error {
            case .Unauthorized:
                return callback(result: { () -> Json? in
                    throw Error.Unauthorized
                })
            case .UnknownServer(let json):
                return callback(result: { () -> Json? in
                    throw Error.UnknownServer(json)
                })
            default:
                return callback(result: { () -> Json? in
                    throw Error.WebApi(error)
                })
                
            }
        } catch {
            return callback(result: { () -> Json? in
                throw Error.Unknown("API: \(error)")
            })
        }
    }
}
