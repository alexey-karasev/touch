//
//  LoginLoginController.swift
//  touch
//
//  Created by Алексей Карасев on 19/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class LoginLoginController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var next: UIButton!
    @IBOutlet weak var back: UIButton!

    @IBAction func backClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {

        super.viewDidLoad()
        emailField.becomeFirstResponder()
    }
}
