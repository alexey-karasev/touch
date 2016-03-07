//
//  AppUser.swift
//  touch
//
//  Created by Алексей Карасев on 21/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import JWTDecode
import Lockbox

class AppUser {
    
    enum Error: ErrorType {
        case InvalidToken
    }
    
    static var shared = try? AppUser()
    static func update(token:String) throws {
        shared = try AppUser(token: token)
    }
    static let lockboxKey="user:token"
    let token:String
    let email:String?
    let login:String?
    let phone:String?
    let confirmed: Bool?
    
    init(token:String, email:String?, login:String?, phone:String?, confirmed:Bool?) {
        self.token = token
        self.email = email
        self.login = login
        self.phone = phone
        self.confirmed = confirmed
    }
    
    convenience init() throws {
        let token = Lockbox.unarchiveObjectForKey(AppUser.lockboxKey) as? String
        if token == nil {throw Error.InvalidToken}
        try self.init(token:token!)
    }
    
    convenience init(token:String) throws {
        let jwt = try? decode(token)
        if jwt == nil {
            throw Error.InvalidToken
        } else {
            let body = jwt!.body
            self.init(token:token, email:body["email"] as? String, login:body["login"] as? String,
                phone:body["phone"] as? String, confirmed:body["confirmed"] as? Bool)
        }
        Lockbox.archiveObject(self.token, forKey: AppUser.lockboxKey)
    }
}
