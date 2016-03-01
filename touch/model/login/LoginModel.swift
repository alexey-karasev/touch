//
//  LoginApi.swift
//  touch
//
//  Created by Алексей Карасев on 28/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class LoginModel {
    static var shared = LoginModel()
    
    func signup(name: String, login: String, email: String, password: String, callback:(token:String?, success: Bool) -> Void) {
        let payload: Json = [
            "name": name,
            "login": login,
            "email": email,
            "password": password
        ]
        API.shared.post(url: "/users/register", payload: payload) { (data, success, payload) -> Void in
            if success {
                if data == nil {
                    API.shared.alertApiError(ApiError.UnknownServer, errorPayload: ["message": "nil data returned in /users/register on success"], UIMessage: "UNKNOWN_SERVER_ERROR")
                    callback(token: nil, success: false)
                    return
                }
                let token = data!["token"] as? String
                if token == nil {
                    API.shared.alertApiError(ApiError.UnknownServer, errorPayload: ["message": "nil token returned in /users/register on success"], UIMessage: "UNKNOWN_SERVER_ERROR")
                    callback(token: nil, success: false)
                    return
                }
                callback(token: token!, success: true)
            } else {
                callback(token: nil, success: false)
            }
        }
    }
    
    func addPhone() {
        
    }
    
    func confirm() {
        
    }
    
    func login() {
        
    }
}
