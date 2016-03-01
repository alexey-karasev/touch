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
    case UnknownServer
    case InvalidJSON
    case Unauthorized
    case ServerTimeout
    case ServerUnreachable
    case IphoneNotConnected
    case Unknown
}

typealias Json = [String:AnyObject]
typealias ApiCallback = (data:Json?, error:ApiError?, errorPayload:Json?) -> Void

protocol ApiProtocol: class {
    func get(url url:String, callback:ApiCallback)
    func post(url url:String, payload:Json?, callback:ApiCallback)
}

class API: ApiProtocol {
    static var shared = API()
    var delegate:ApiProtocol = WebApi()
    
    func get(url url:String, callback:ApiCallback) {
        delegate.get(url: url, callback: callback)
    }
    
    func post(url url:String, payload:Json?, callback:ApiCallback) {
        delegate.post(url: url, payload: payload, callback: callback)
    }
    
    
    // Displays an alert, prints into consolse and returns true if the error is generic, returns false o/w
    func alertGenericApiError(error: ApiError, errorPayload: Json?) -> Bool {
        if errorPayload == nil {
            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("UNKNOWN_SERVER_ERROR", comment: "UNKNOWN_SERVER_ERROR"))
            return false
        }
        switch error {
        case .ServerTimeout:
            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("REQUEST_TO_SERVER_TIMED_OUT", comment: "REQUEST_TO_SERVER_TIMED_OUT"))
        case .ServerUnreachable:
            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("CANNOT_NOT_CONNECT_TO_SERVER", comment: "CANNOT_NOT_CONNECT_TO_SERVER"))
        case .IphoneNotConnected:
            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("IPHONE_NOT_CONNECTED_TO_INTERNET", comment: "IPHONE_NOT_CONNECTED_TO_INTERNET"))
        case .UnknownServer:
            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("UNKNOWN_SERVER_ERROR", comment: "UNKNOWN_SERVER_ERROR"))
        default:
            return false
        }
        print("Error: \(error), payload: \(errorPayload)")
        return true
    }
}
