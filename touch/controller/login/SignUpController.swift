//
//  SignUpController.swift
//  touch
//
//  Created by Алексей Карасев on 26/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class SignUpController: UIViewController {
    
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user = AppUser.shared else {return}
        if let confirmed = user.confirmed where confirmed == true { return }
        performSegueWithIdentifier("phoneVerification", sender: self)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func nextClicked(sender: AnyObject) {
        if let validation = validate() {
            return Utils.Text.alert(header: NSLocalizedString("ERROR", comment: "Error"), message: validation)
        }
        LoginModel.shared.signup(nameField.text!, login: loginField.text!, email: emailField.text!, password: passwordField.text!) { [weak self]result in
            var token: String?
            do {
                token = try result()
            } catch let error as LoginModel.Error {
                switch error {
                case .EmptyField(let field):
                    return Utils.Text.alertError("\(field.uppercaseString)_IS_EMPTY")
                case .NotUniqueField(let field):
                    return Utils.Text.alertError("\(field.uppercaseString)_IS_NOT_UNIQUE")
                case .Unauthorized:
                    Utils.Text.log("Error: Sign Up Controller: On sign up server returned unauthorized")
                    return Utils.Text.alertError("UNKNOWN_SERVER_ERROR")
                case .APIError:
                    return
                case .Internal(let data):
                    Utils.Text.alertError("UNKNOWN_ERROR")
                    return Utils.Text.log("Error: Sign Up Controller: Login Model: Internal Error, payload: \(data)")
                default:
                    Utils.Text.log("Error: Sign Up Controller: Unexpected error: \(error)")
                    return Utils.Text.alertError("UNKNOWN_ERROR")
                }
            } catch {
                Utils.Text.log("Error: Sign Up Controller: Unexpected error: \(error)")
                return Utils.Text.alertError("UNKNOWN_ERROR")
            }
            
            do {
                try AppUser.update(token!)
            }
            catch {
                Utils.Text.alertError("INVALID_TOKEN")
                Utils.Text.log("Error: Sign Up Controller: Invalid token")
                return
            }
            self?.performSegueWithIdentifier("phoneVerification", sender: self!)
        }
        
    }
    
    @IBAction func backClicked() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func validate() -> String? {
        if nameField.text == nil || nameField.text!.isEmpty  {
            return NSLocalizedString("NAME_FIELD_REQUIRED", comment: "Name field is required")
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let result=NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(emailField.text)
        if !result {
            return NSLocalizedString("INVALID_EMAIL", comment: "Invalid email format")
        }
        if loginField.text == nil || loginField.text!.isEmpty  {
            return NSLocalizedString("LOGIN_FIELD_REQUIRED", comment: "Login field is required")
        }
        if passwordField.text == nil || passwordField.text!.isEmpty  {
            return NSLocalizedString("PASSWORD_FIELD_REQUIRED", comment: "Password field is required")
        }
        return nil
    }
    
}
