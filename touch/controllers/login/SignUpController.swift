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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let validation = validate()
        if validation != nil {
            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "Error"), message: validation!)
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }

    @IBAction func nextClicked(sender: AnyObject) {
        let validation = validate()
        if validation != nil {
            Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "Error"), message: validation!)
            return
        }
        
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
