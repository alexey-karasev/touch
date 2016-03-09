//
//  LoginLoginController.swift
//  touch
//
//  Created by Алексей Карасев on 19/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var next: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var back: UIButton!

    @IBAction func backClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func nextClicked() {
        let username = usernameField.text!
        let password = passwordField.text!
        if username.characters.count == 0 {
            Utils.Text.alertError("USERNAME_FIELD_REQUIRED")
            return
        }
        if password.characters.count == 0 {
            Utils.Text.alertError("PASSWORD_FIELD_REQUIRED")
            return
        }
        LoginModel.shared.login(username, password: password) {[weak self] result in
            var token: String?
            do {
                token = try result()
            } catch let error as LoginModel.Error {
                switch error {
                case .Unauthorized:
                    return Utils.Text.alertError("INVALID_USERNAME_OR_PASSWORD")
                case .APIError:
                    return
                case .Internal(let data):
                    Utils.Text.log("Error: Login Controller: Login Model: Internal Error, payload: \(data)")
                    return Utils.Text.alertError("UNKNOWN_ERROR")
                default:
                    Utils.Text.log("Error: Login Controller: Unexpected error: \(error)")
                    return Utils.Text.alertError("UNKNOWN_ERROR")
                }
            } catch {
                Utils.Text.log("Error: Login Controller: Unexpected error: \(error)")
                return Utils.Text.alertError("UNKNOWN_ERROR")
            }
            
            do {
                try AppUser.update(token!)
            }
            catch {
                Utils.Text.alertError("INVALID_TOKEN")
                Utils.Text.log("Error: Login Controller: Invalid token")
                return
            }
            self?.performSegueWithIdentifier("toMain", sender: self!)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.becomeFirstResponder()
    }
}
