//
//  LoginLoginController.swift
//  touch
//
//  Created by Алексей Карасев on 19/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var next: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var back: UIButton!

    @IBAction func backClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func nextClicked() {
        let email = emailField.text
        let password = passwordField.text
        if !validateEmail(email!) {
            Utils.shared.alert(header: "ERROR", message: "INVALID_EMAIL")
            return
        }
        if (password == nil) || password!.characters.count == 0 {
            Utils.shared.alert(header: "ERROR", message: "PASSWORD_FIELD_REQUIRED")
            return
        }
        let payload = ["username":email!, "password":password!]
        Utils.shared.addOverlayToView(self.view)
        WebApi.shared.post(url: "/users/login", payload:payload) { data, error in
            Utils.shared.dismissOverlay()
            if error != nil {
                switch error!.domain {
                case NSURLErrorDomain:
                    switch NSURLError(rawValue: error!.code)! {
                    case NSURLError.TimedOut:
                        Utils.shared.alert(header: "ERROR", message: "REQUEST_TO_SERVER_TIMED_OUT")
                    case NSURLError.CannotConnectToHost:
                        Utils.shared.alert(header: "ERROR", message: "CANNOT_NOT_CONNECT_TO_SERVER")
                    case NSURLError.NotConnectedToInternet:
                        Utils.shared.alert(header: "ERROR", message: "IPHONE_NOT_CONNECTED_TO_INTERNET")
                    case NSURLError.UserCancelledAuthentication:
                        Utils.shared.alert(header: "ERROR", message: "INVALID_USERNAME_OR_PASSWORD")
                    default: break
                    }
                default:
                    Utils.shared.alert(header: "ERROR", message: "UNKNOWN_CONNECTION_ERROR")
                }
            }
            print("\(data), \(error)")
        }
    }
    override func viewDidLoad() {

        super.viewDidLoad()
        emailField.becomeFirstResponder()
    }
    
    private func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
}
