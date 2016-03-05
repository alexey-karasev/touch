//
//  PhoneVerificationController.swift
//  touch
//
//  Created by Алексей Карасев on 24/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class PhoneVerificationController: UIViewController, CountryPickerDelegate {
    
    typealias Country = CountryPickerController.Country
    
    @IBAction func nextButtonClicked() {
        if (phoneTextField.text == nil) || (phoneTextField.text == "") {
            Utils.shared.alertError("PHONE_FIELD_REQUIRED")
            return
        }
        LoginModel.shared.addPhone(phoneTextField.text!) { [weak self] (token, success) -> Void in
            if success && (token != nil) && (self != nil) {
                do {
                    try AppUser.update(token!)
                    self!.performSegueWithIdentifier("phoneConfirmation", sender: self!)
                }
                catch {
                    Utils.shared.alert(header: NSLocalizedString("ERROR", comment: "Error"), message: NSLocalizedString("INVALID_TOKEN", comment: "INVALID_TOKEN"))
                }
            }
        }
    }
    
    
    @IBAction func backClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var currentCountry: Country? {
        willSet {
            if (countryButton != nil) && (newValue != nil) {
                countryButton.setTitle(newValue!.code, forState: UIControlState.Normal)
                countryButton.setImage(newValue!.flag, forState: UIControlState.Normal)
            }
        }
    }
    
    lazy var countries : [Country] = {
        var result: [Country] = []
        result.append(Country(imageName: "US", title: NSLocalizedString("US", comment: "United States"), code: "+1"))
        result.append(Country(imageName: "RU", title: NSLocalizedString("Russia", comment: "Russia"), code: "+7"))
        return result
        }()
    
    lazy var countryPicker:CountryPickerController = CountryPickerController.instantiate(delegate: self, countries: self.countries)
    
    func countryPickerDismissed(country:Country?) {
        if let c = country {
            currentCountry = c
        }
    }
    
    @IBAction func countryButtonClicked() {
        view.endEditing(true)
        countryPicker.present(self, top: nextButton.frame.maxY, currentCountry: currentCountry)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
