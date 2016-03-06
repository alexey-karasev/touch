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
    
    typealias Result = () throws -> String?
    typealias Callback = (result: Result) -> Void
    
    enum Error: ErrorType {
        // propagates up
        case EmptyField(String)
        case NotUniqueField(String)
        case Unauthorized
        
        // already handled by API
        case APIError(API.Error)

        // internal error
        case Unknown(String)
    }
    
    func signup(name: String, login: String, email: String, password: String, callback: Callback) {
        let payload: Json = [
            "name": name,
            "login": login,
            "email": email,
            "password": password
        ]
        let url = "/users/register"
        API.shared.post(url: url, payload: payload) { [weak self] result in
            self?.extractToken(result, callback: callback)
        }
    }
    
    func addPhone(phone:String, callback: Callback) {
        guard let user = AppUser.shared else {
            return callback(result: {
                throw Error.Unauthorized
            })
        }
        let payload: Json = [
            "phone": phone,
            "token": user.token
        ]
        let url = "/users/add_phone"
        API.shared.post(url: url, payload: payload) {[weak self] result in
            self?.extractToken(result, callback: callback)
        }
    }
    
    func confirm(confirm: String, callback:Callback) {
        guard let user = AppUser.shared else {
            return callback(result: {
                throw Error.Unauthorized
            })
        }
        let payload: Json = [
            "confirm": confirm,
            "token": user.token
        ]
        let url = "/users/confirm"
        API.shared.post(url: url, payload: payload) { [weak self] result in
            self?.extractToken(result, callback: callback)
        }
    }
    
    func login(username: String, password: String, callback:(token:String?, success: Bool, payload: Json?) -> Void) {
        let payload: Json = [
            "username": username,
            "password": password
        ]
        let url = "/users/login"
        API.shared.post(url: url, payload: payload) { [weak self] result in
            self?.extractToken(result, callback: callback)
        }
    }
    
    private func extractToken(result: API.Result, callback:Callback) {
        do {
            let data = try result()
            guard let token=data!["token"] as? String else {
                return callback(result: {
                    let message = "Login: Unexpected nil token"
                    print(message)
                    throw Error.Unknown(message)
                })
            }
            return callback(result: {
                return token
            })
        } catch let error as API.Error {
            switch error {
            case .Unauthorized:
                return callback(result: {
                    throw Error.Unauthorized
                })
            case .UnknownServer(let json as Json):
                guard let id = json["id"] as? String else {
                    return callback(result: {
                        let message = "Login: Unexpected error id"
                        print(message)
                        throw Error.Unknown(message)
                    })
                }
                guard let payload = json["payload"] as? String else {
                    return callback(result: {
                        let message = "Login: Unexpected error payload"
                        print(message)
                        throw Error.Unknown(message)
                    })
                }
                
                switch id {
                case "EMPTY_FIELD":
                    return callback(result: {
                        throw Error.EmptyField(payload)
                    })
                case "NOT_UNIQUE_FIELD":
                    return callback(result: {
                        throw Error.NotUniqueField(payload)
                    })
                default:
                    return callback(result: {
                        let message = "Login: Unexpected error id"
                        print(message)
                        throw Error.Unknown(message)
                    })
                }
            default:
                return callback(result: {
                    throw Error.APIError(error)
                })
            }
        } catch {
            return callback(result: {
                let message = "Login: Unexpected API Error: \(error)"
                print(message)
                throw Error.Unknown(message)
            })
        }
    }
    
}
