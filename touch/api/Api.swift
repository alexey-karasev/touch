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
        case Unauthorized
        case InternalServer(Json)
        case WebApi(WebAPI.Error)
        case Internal(String)
    }

    typealias Result = () throws -> Json?
    typealias Callback = (result:Result) -> Void
    
    static var shared = API()
    var delegate:RemoteJsonAPI = WebAPI()
    
    func get(url url:String, callback:Callback) {
        delegate.get(url: url) { [weak self](result) -> Void in
            if self != nil {
                self!.extractResult(result, callback: callback)
            }
        }
    }
    
    func post(url url:String, payload:Json?, callback:Callback) {
        delegate.post(url: url, payload: payload) { [weak self] result in
            if self != nil {
                self!.extractResult(result, callback: callback)
            }
        }
    }
    
    private func extractResult(result: RemoteJsonAPI.Result, callback: Callback) {
        do {
            let res = try result()
            callback(result: {
                return res
            })
        } catch let error as RemoteJsonAPI.Error {
            switch error {
            case .Unauthorized:
                return callback(result: {
                    throw Error.Unauthorized
                })
            case .InternalServer(let json):
                return callback(result: {
                    throw Error.InternalServer(json)
                })
            case .IphoneNotConnected:
                alertError("IPHONE_NOT_CONNECTED", payload: nil)
                return callback(result: {
                    throw Error.WebApi(error)
                })
            case .ServerTimeout:
                alertError("REQUEST_TO_SERVER_TIMED_OUT", payload: nil)
                return callback(result: {
                    throw Error.WebApi(error)
                })
            case .ServerUnreachable:
                alertError("CANNOT_NOT_CONNECT_TO_SERVER", payload: nil)
                return callback(result: {
                    throw Error.WebApi(error)
                })
            case .InvalidServerResponse(let data):
                alertError("UNEXPECTED_SERVER_RESPONSE", payload: data)
                return callback(result: {
                    throw Error.WebApi(error)
                })
            case .Internal(let data):
                alertError("UNKNOWN_ERROR", payload: data)
                return callback(result: {
                    throw Error.WebApi(error)
                })
            }
        } catch {
            return callback(result: {
                throw Error.Internal("Unexpected Remote Json API error: \(error)")
            })
        }
    }
    
    private func alertError(messageID:String, payload:String?) {
        Utils.Text.alertError(messageID)
        if payload == nil  {
            Utils.Text.log("Error: API: \(messageID)")
        } else {
            Utils.Text.log("Error: API: \(messageID), payload: \(payload)")
        }
    }
}
