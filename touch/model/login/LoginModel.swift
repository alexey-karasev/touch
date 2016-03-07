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
        case EmptyField(String)
        case NotUniqueField(String)
        case Unauthorized
        case APIError(API.Error)
        case Internal(String)
    }
    
    func signup(name: String, login: String, email: String, password: String, callback: Callback) {
        let payload = Json(dictionary: [
            "name": name,
            "login": login,
            "email": email,
            "password": password
        ])
        let url = "/users/register"
        API.shared.post(url: url, payload: payload) { [weak self] result in
            self?.extractResult(result, callback: callback)
        }
    }
    
    func addPhone(phone:String, callback: Callback) {
        guard let user = AppUser.shared else {
            return callback(result: {
                throw Error.Unauthorized
            })
        }
        let payload = Json(dictionary: [
            "phone": phone,
            "token": user.token
        ])
        let url = "/users/add_phone"
        API.shared.post(url: url, payload: payload) {[weak self] result in
            self?.extractResult(result, callback: callback)
        }
    }
    
    func confirm(confirm: String, callback:Callback) {
        guard let user = AppUser.shared else {
            return callback(result: {
                throw Error.Unauthorized
            })
        }
        let payload = Json(dictionary: [
            "confirm": confirm,
            "token": user.token
        ])
        let url = "/users/confirm"
        API.shared.post(url: url, payload: payload) { [weak self] result in
            self?.extractResult(result, callback: callback)
        }
    }
    
    func login(username: String, password: String, callback:Callback) {
        let payload = Json(dictionary: [
            "username": username,
            "password": password
        ])
        let url = "/users/login"
        API.shared.post(url: url, payload: payload) { [weak self] result in
            self?.extractResult(result, callback: callback)
        }
    }
    
    private func extractResult(result: API.Result, callback:Callback) {
        do {
            let data = try result()
            guard let token=data!["token"] as? String else {
                return callback(result: {
                    throw Error.Internal("Unexpected nil token")
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
            case .InternalServer(let json):
                guard let id = json["id"] as? String else {
                    return callback(result: {
                        throw Error.Internal("Invalid error id")
                    })
                }
                guard let payload = json["payload"] as? String else {
                    return callback(result: {
                        throw Error.Internal("Invalid error payload")
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
                        throw Error.Internal("Unexpected error id")
                    })
                }
            case .WebApi:
                return callback(result: {
                    throw Error.APIError(error)
                })
            case .Internal(let data):
                Utils.Text.log("Internal API Error, payload: \(data)")
                return callback(result: {
                    throw Error.APIError(error)
                })
            }
        } catch {
            return callback(result: {
                throw Error.Internal("Unexpected API Error: \(error)")
            })
        }
    }
    
}
