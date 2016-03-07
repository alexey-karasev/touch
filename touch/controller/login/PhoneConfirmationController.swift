//
//  PhoneConfirmationController.swift
//  touch
//
//  Created by Алексей Карасев on 05/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class PhoneConfirmationController: UIViewController {
    
    @IBOutlet weak var codeField: UITextField!
    @IBAction func backClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func nextClicked(sender: AnyObject) {
//        if (codeField.text == nil) || (codeField.text == "")  {
//            Utils.Text.alertError("VERIFICATION_FIELD_REQUIRED")
//            return
//        }
//        LoginModel.shared.confirm(codeField.text!) { [weak self] (token, success, payload) -> Void in
//            if success && (token != nil) && (self != nil) {
//                do {
//                    try AppUser.update(token!)
//                    self!.performSegueWithIdentifier("connectContacts", sender: self!)
//                }
//                catch {
//                    Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "Error"), message: NSLocalizedString("INVALID_TOKEN", comment: "INVALID_TOKEN"))
//                }
//            }
//        }
    }
    
}
