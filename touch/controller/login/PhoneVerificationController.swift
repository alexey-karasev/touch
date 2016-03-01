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
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    
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
