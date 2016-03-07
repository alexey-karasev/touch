//
//  AbstractWebAPI.swift
//  touch
//
//  Created by Алексей Карасев on 06/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

// This is an abstract class for any json-based remote API
class RemoteJsonAPI {
    
    // These are closure types for handling of async exceptions. 
    // If the exception occurs, then it will be thrown by the result closure, i.e.
    // get (url: 'http://example.com') { result in
    //      let res = try result()
    // }
    // 
    // Either result() will throw or res will hold the actual result of the API callback
    typealias Result = () throws -> Json?
    typealias Callback = (result: Result) -> Void
    
    // These are typical errors for communicating with remote JSON API
    enum Error : ErrorType {
        case Unauthorized
        case InternalServer(Json)
        case InvalidServerResponse(String)
        case ServerTimeout
        case ServerUnreachable
        case IphoneNotConnected
        case Internal(String)
    }
    
    // Get request
    func get(url url:String, callback:Callback) {
        
    }
    
    // Post request
    func post(url url:String, payload:Json?, callback:Callback) {
        
    }
    
}