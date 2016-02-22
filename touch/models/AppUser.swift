//
//  AppUser.swift
//  touch
//
//  Created by Алексей Карасев on 21/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import JWTDecode
import Lockbox

enum AppUserError: ErrorType {
    case InvalidToken
    case MissingFieldsInToken
    case MissingToken
}

class AppUser {
    static var shared = try? AppUser()
    static func update(token:String) throws {
        shared = try AppUser(token: token)
    }
    static let lockboxKey="user:token"
    let token:String
    let email:String
    let login:String
    let phone:String
    let name:String
    
    init(token:String, email:String, login:String, phone:String, name:String) {
        self.token = token
        self.email = email
        self.login = login
        self.phone = phone
        self.name = name
    }
    
    convenience init() throws {
        let token = Lockbox.unarchiveObjectForKey(AppUser.lockboxKey) as? String
        if token == nil {throw AppUserError.MissingToken}
        try self.init(token:token!)
    }
    
    convenience init(token:String) throws {
        let jwt = try? decode(token)
        if jwt == nil {
            throw AppUserError.InvalidToken
        } else {
            let body = jwt!.body
            if (body["email"] == nil) || (body["login"] == nil)
                || (body["phone"] == nil) || (body["name"] == nil) || (body["exp"] == nil) {
                    throw AppUserError.MissingFieldsInToken
            }
            self.init(token:token, email:body["email"] as! String, login:body["login"] as! String,
                phone:body["phone"] as! String, name:body["name"] as! String)
        }
        Lockbox.archiveObject(self.token, forKey: AppUser.lockboxKey)
    }
}
