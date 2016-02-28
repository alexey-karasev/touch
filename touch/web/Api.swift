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
}
