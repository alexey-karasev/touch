//
//  PhoneConfirmationController.swift
//  touch
//
//  Created by Алексей Карасев on 05/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class PhoneConfirmationController: UIViewController, UITextFieldDelegate {
    
    let codeFieldLength = 4
    
    @IBOutlet weak var codeField: UITextField!
    @IBAction func backClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeField.delegate = self
    }
    
    @IBAction func nextClicked(sender: AnyObject) {
        if (codeField.text == nil) || (codeField.text == "")  {
            Utils.Text.alertError("VERIFICATION_FIELD_REQUIRED")
            return
        }
        LoginModel.shared.confirm(codeField.text!) { [weak self] result in
            var token: String?
            do {
                token = try result()
            } catch let error as LoginModel.Error {
                switch error {
                case .EmptyField(let field):
                    Utils.Text.alertError("\(field.uppercaseString)_IS_EMPTY")
                case .NotUniqueField(let field):
                    Utils.Text.alertError("\(field.uppercaseString)_IS_NOT_UNIQUE")
                case .Unauthorized:
                    Utils.Text.alertError("SESSION_EXPIRED")
                    self?.navigationController?.popViewControllerAnimated(true)
                case .InvalidPassword:
                    Utils.Text.alertError("INVALID_CONFIRMATION_CODE")
                case .APIError:
                    return
                case .Internal(let data):
                    Utils.Text.log("Error: Phone Verification Controller: Login Model: Internal Error, payload: \(data)")
                    return Utils.Text.alertError("UNKNOWN_ERROR")
                }
                return
            } catch {
                Utils.Text.log("Error: Phone Verification Controller: Unexpected error: \(error)")
                return Utils.Text.alertError("UNKNOWN_ERROR")
            }
            
            do {
                try AppUser.update(token!)
            }
            catch {
                Utils.Text.alertError("INVALID_TOKEN")
                Utils.Text.log("Error: Phone Verification Controller: Invalid token")
                return
            }
            self?.performSegueWithIdentifier("connectContacts", sender: self!)

        }
    }
    
    // Code text view delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= codeFieldLength
    }
    
}
