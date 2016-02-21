//
//  AppUser.swift
//  touch
//
//  Created by Алексей Карасев on 21/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import JWTDecode
import Lockbox

class AppUser: NSObject {
    static let lockboxKey="user:token"
    
    let token:String
    let email:String?
    let login:String?
    let phone:String?
    let name:String?
    
    init(token:String, email:String?, login:String?, phone:String?, name:String?) {
        self.token = token
        self.email = email
        self.login = login
        self.phone = phone
        self.name = name
    }
    
    convenience override init() {
        var token = Lockbox.unarchiveObjectForKey(AppUser.lockboxKey) as? String
        if token == nil {token = ""}
        self.init(token:token!)
    }
    
    convenience init(token:String){
        let jwt = try? decode(token)
        if jwt == nil {
            self.init(token:token, email:nil, login:nil, phone:nil, name:nil)
        } else {
            let body = jwt!.body
            self.init(token:token, email:body["email"] as? String, login:body["login"] as? String,
                phone:body["phone"] as? String, name:body["name"] as? String)
        }
        Lockbox.archiveObject(self.token, forKey: AppUser.lockboxKey)
    }
}
