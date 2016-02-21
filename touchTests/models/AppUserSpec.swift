//
//  AppUserSpec.swift
//  touch
//
//  Created by Алексей Карасев on 21/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import Quick
import Nimble
import Lockbox

class AppUserSpec: QuickSpec {
    override func spec() {
        afterEach() {
            Lockbox.archiveObject(nil, forKey: AppUser.lockboxKey)
        }
        describe("init(token)") {
            context("valid token") {
                it("initializes app user") {
                    let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfaWQiOiI1NmNhMGUxNjE2NjNkYzRiMWIxMzRmZTIiLCJlbWFpbCI6Im55YXNoYUBnbWFpbC5jb20iLCJsb2dpbiI6Im55YXNoYSIsInBob25lIjoiKzcxIiwibmFtZSI6ImxhbXBvdmF5YSBueWFzaGEiLCJleHAiOjE0NTg3NjA4NTQsImlhdCI6MTQ1NjA4MjQ1NH0.Z9nT0bL4NfCm6sXWB8XTZe0FaSqljMDegFGwVmsEIOA"
                    let appUser = AppUser(token: token)
                    expect(appUser.email).to(equal("nyasha@gmail.com"))
                    expect(appUser.name).to(equal("lampovaya nyasha"))
                    expect(appUser.login).to(equal("nyasha"))
                    expect(appUser.phone).to(equal("+71"))
                }
            }
            context("invalid token") {
                it("initializes app user with nil parameters") {
                    let token = "123"
                    let appUser = AppUser(token: token)
                    expect(appUser.email).to(beNil())
                    expect(appUser.name).to(beNil())
                    expect(appUser.login).to(beNil())
                    expect(appUser.phone).to(beNil())
                }
            }
        }
        
        describe("init()") {
            it("loads AppUser token from lockbox") {
                let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJfaWQiOiI1NmNhMGUxNjE2NjNkYzRiMWIxMzRmZTIiLCJlbWFpbCI6Im55YXNoYUBnbWFpbC5jb20iLCJsb2dpbiI6Im55YXNoYSIsInBob25lIjoiKzcxIiwibmFtZSI6ImxhbXBvdmF5YSBueWFzaGEiLCJleHAiOjE0NTg3NjA4NTQsImlhdCI6MTQ1NjA4MjQ1NH0.Z9nT0bL4NfCm6sXWB8XTZe0FaSqljMDegFGwVmsEIOA"
                var appUser = AppUser(token: token) //adding token to Lockbox
                appUser = AppUser()
                expect(appUser.email).to(equal("nyasha@gmail.com"))
                expect(appUser.name).to(equal("lampovaya nyasha"))
                expect(appUser.login).to(equal("nyasha"))
                expect(appUser.phone).to(equal("+71"))
            }
        }
        
    }
}
