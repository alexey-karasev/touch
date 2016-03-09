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
            Utils.Text.alertError("PHONE_IS_EMPTY")
            return
        }
        LoginModel.shared.addPhone(currentCountry!.code+phoneTextField.text!) { [weak self] result in
            
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
                case .APIError:
                    return
                case .Internal(let data):
                    Utils.Text.log("Error: Phone Verification Controller: Login Model: Internal Error, payload: \(data)")
                    return Utils.Text.alertError("UNKNOWN_ERROR")
                default:
                    Utils.Text.log("Error: Phone Verification Controller: Unexpected error: \(error)")
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
            self?.performSegueWithIdentifier("phoneConfirmation", sender: self!)
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
        currentCountry = countries[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
