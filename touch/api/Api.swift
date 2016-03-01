//
//  Api.swift
//  touch
//
//  Created by Алексей Карасев on 28/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

enum ApiError : ErrorType {
    case NotUniqueField
    case EmptyField
    case NotFound
    case InvalidUserCredentials
    case UserNotConfirmed
    case InvalidConfirmationCode
    case UnexpectedServerResponse
    case UnknownServer
    case InvalidJSON
    case Unauthorized
    case ServerTimeout
    case ServerUnreachable
    case IphoneNotConnected
    case Unknown
}

typealias Json = [String:AnyObject]
typealias ApiCallback = (data:Json?, success: Bool, payload: Json?) -> Void


protocol WebApiProtocol: class {
    func get(url url:String, callback:WebApiCallback)
    func post(url url:String, payload:Json?, callback:WebApiCallback)
}

class API {
    static var shared = API()
    var delegate:WebApiProtocol = WebApi()
    
    func get(url url:String, callback:ApiCallback) {
        delegate.get(url: url) { (data, error, errorPayload) -> Void in
            if error != nil {
                API.shared.handleApiError(error!, errorPayload: errorPayload)
                callback(data: nil, success: false, payload: nil)
            } else {
                callback(data: data, success: true, payload: nil)
            }
        }
    }
    
    func post(url url:String, payload:Json?, callback:ApiCallback) {
        delegate.post(url: url, payload: payload) { (data, error, errorPayload) -> Void in
            if error != nil {
                API.shared.handleApiError(error!, errorPayload: errorPayload)
                callback(data: nil, success: false, payload: nil)
            } else {
                callback(data: data, success: true, payload: nil)
            }
        }
    }
    
    // Displays an alert and prints error into consolse
    func handleApiError(error: ApiError, errorPayload: Json?) {
        var UIMessage :String
        if errorPayload == nil {
            UIMessage  = "UNKNOWN_SERVER_ERROR"
        } else {
            switch error {
            case .ServerTimeout:
                UIMessage  = "REQUEST_TO_SERVER_TIMED_OUT"
            case .ServerUnreachable:
                UIMessage  = "CANNOT_NOT_CONNECT_TO_SERVER"
            case .IphoneNotConnected:
                UIMessage  = "IPHONE_NOT_CONNECTED_TO_INTERNET"
            case .UnknownServer:
                UIMessage  = "UNKNOWN_SERVER_ERROR"
            case .NotUniqueField:
                if errorPayload == nil {
                    UIMessage  = "UNEXPECTED_SERVER_RESPONSE"
                } else {
                    let field = errorPayload!["field"] as? String
                    if field == nil {
                        UIMessage  = "UNEXPECTED_SERVER_RESPONSE"
                    } else {
                        switch field! {
                        case "email":
                            UIMessage  = "EMAIL_IS_NOT_UNIQUE"
                        case "login":
                            UIMessage  = "LOGIN_IS_NOT_UNIQUE"
                        case "phone":
                            UIMessage  = "PHONE_IS_NOT_UNIQUE"
                        default:
                            UIMessage  = "UNEXPECTED_SERVER_RESPONSE"
                        }
                    }
                }
            default:
                UIMessage  = "UNKNOWN"
            }
        }
        alertApiError(error, errorPayload: errorPayload, UIMessage : UIMessage )
    }
    
    func alertApiError(error: ApiError, errorPayload: Json?, UIMessage: String) {
        Utils.shared.alertError(UIMessage )
        print("Error: \(error), payload: \(errorPayload), UIMessage :\(NSLocalizedString(UIMessage , comment: UIMessage ))")
    }
}
