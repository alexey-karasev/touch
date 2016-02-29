//
//  LoginApi.swift
//  touch
//
//  Created by Алексей Карасев on 28/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class LoginAPI {
    static var shared = LoginAPI()
    
    func signup(name: String, login: String, email: String, password: String, callback:(token:String?, success: Bool) -> Void) {
        let payload: Json = [
            "name": name,
            "login": login,
            "email": email,
            "password": password
        ]
        API.shared.post(url: "/users/register", payload: payload) { (data, error, errorPayload) -> Void in
            if let err = error {
                if !API.shared.alertGenericApiError(err, errorPayload: payload) {
                    switch err {
                    case .NotUniqueField:
                        let field = errorPayload!["field"] as? String
                        if field == nil {
                            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("UNKNOWN_SERVER_ERROR", comment: "UNKNOWN_SERVER_ERROR"))
                            callback(token: nil, success: false)
                            return
                        }
                        switch field! {
                        case "email":
                            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("EMAIL_IS_NOT_UNIQUE", comment: "EMAIL_NOT_UNIQUE"))
                        case "login":
                            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("LOGIN_IS_NOT_UNIQUE", comment: "LOGIN_NOT_UNIQUE"))
                        default:
                            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("UNKNOWN_SERVER_ERROR", comment: "UNKNOWN_SERVER_ERROR"))
                        }
                    default:
                        Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("UNKNOWN_SERVER_ERROR", comment: "UNKNOWN_SERVER_ERROR"))
                    }
                }
                callback(token: nil, success: false)
                return
            }
            if data == nil {
                Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("UNKNOWN_SERVER_ERROR", comment: "UNKNOWN_SERVER_ERROR"))
                callback(token: nil, success: false)
                return
            }
            let token = data!["token"] as? String
            if token == nil {
                Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "ERROR"), message: NSLocalizedString("UNKNOWN_SERVER_ERROR", comment: "UNKNOWN_SERVER_ERROR"))
                callback(token: nil, success: false)
                return
            }
            callback(token: token, success: true)
        }
    }
    
    func addPhone() {
        
    }
    
    func confirm() {
        
    }
    
    func login() {
        
    }
}
