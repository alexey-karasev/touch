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
    
    func signup(name: String, login: String, email: String, password: String, callback:(token:String?, success: Bool, payload:Json?) -> Void) {
        let payload: Json = [
            "name": name,
            "login": login,
            "email": email,
            "password": password
        ]
        let url = "/users/register"
        API.shared.post(url: url, payload: payload) { [weak self] (data, success, payload) -> Void in
            self!.updateToken(data: data, success: success, payload: payload, url: url, callback: callback)
        }
    }
    
    func addPhone(phone:String, callback:(token:String?, success: Bool, payload:Json?) -> Void) {
        if let user = AppUser.shared {
            let payload: Json = [
                "phone": phone,
                "token": user.token
            ]
            let url = "/users/add_phone"
            API.shared.post(url: url, payload: payload) { [weak self] (data, success, payload) -> Void in
                self?.updateToken(data: data, success: success, payload: payload, url: url, callback: callback)
            }
        }
        callback(token: nil, success: false, payload: nil)
    }
    
    func confirm(confirm:String, callback:(token:String?, success: Bool, payload:Json?) -> Void) {
        if let user = AppUser.shared {
            let payload: Json = [
                "confirm": confirm,
                "token": user.token
            ]
            let url = "/users/confirm"
            API.shared.post(url: url, payload: payload) { [weak self] (data, success, payload) -> Void in
                self?.updateToken(data: data, success: success, payload: payload, url: url, callback: callback)
            }
        }
        callback(token: nil, success: false, payload: nil)
    }
    
    func login(username: String, password: String, callback:(token:String?, success: Bool, payload: Json?) -> Void) {
        let payload: Json = [
            "username": username,
            "password": password
        ]
        let url = "/users/login"
        API.shared.post(url: url, payload: payload) { [weak self] (data, success, payload) -> Void in
            self?.updateToken(data: data, success: success, payload: payload, url: url, callback: callback)
        }
    }
    
    private func updateToken(data data: Json?, success:Bool, payload:Json?, url:String, callback:(token:String?, success: Bool, payload: Json?) -> Void) {
        if success {
            if data == nil {
                API.shared.alertApiError(ApiError.UnknownServer, errorPayload: ["message": "nil data returned in \(url) on success"], UIMessage: "UNKNOWN_SERVER_ERROR")
                callback(token: nil, success: false, payload: payload)
                return
            }
            let token = data!["token"] as? String
            if token == nil {
                API.shared.alertApiError(ApiError.UnknownServer, errorPayload: ["message": "nil token returned in \(url) on success"], UIMessage: "UNKNOWN_SERVER_ERROR")
                callback(token: nil, success: false, payload: payload)
                return
            }
            callback(token: token!, success: true, payload: payload)
        } else {
            callback(token: nil, success: false, payload: payload)
        }
    }
}
