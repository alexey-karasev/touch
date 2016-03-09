//
//  LoginRootController.swift
//  touch
//
//  Created by Алексей Карасев on 09/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginRootController: UIViewController {
    
    var email: String?
    var name: String?
    
    @IBAction func facebookButtonClicked(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email"], fromViewController: self) { (result, error) -> Void in
            if error != nil {
                Utils.Text.log(error.localizedDescription)
                let alert = UIAlertView(title: NSLocalizedString("ERROR", comment: "ERROR"), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Ok"))
                alert.show()
                return
            }
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email"]).startWithCompletionHandler({ [weak self] (connection, result, error) -> Void in
                self?.email = result["email"] as? String
                self?.name = result["name"] as? String
                self?.performSegueWithIdentifier("signUp", sender: nil)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signUp" {
            let vc = segue.destinationViewController as! SignUpController
            vc.email = email
            vc.name = name
        }
    }
}
