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
    
    var overlayTap: UIGestureRecognizer?
    
    lazy var countries : [Country] = {
        var result: [Country] = []
        result.append(Country(imageName: "US", title: NSLocalizedString("US", comment: "United States"), code: "+1"))
        result.append(Country(imageName: "RU", title: NSLocalizedString("Russia", comment: "Russia"), code: "+7"))
        return result
    }()
    
    lazy var countryPicker:CountryPickerController = CountryPickerController.instantiate(delegate: self, countries: self.countries)
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    
    var tap: UIGestureRecognizer?
    
    var currentCountry: Country? {
        willSet {
            if (countryButton != nil) && (newValue != nil) {
                countryButton.setTitle(newValue!.code, forState: UIControlState.Normal)
                countryButton.setImage(newValue!.flag, forState: UIControlState.Normal)
            }
        }
    }

    
    func countryPickerDismissed(country:Country?) {
        weak var weakSelf = self
        Utils.shared.dismissOverlay()
        UIView.animateWithDuration(0.5, animations: {
            if let ws = weakSelf {
                ws.countryPicker.view.frame =  CGRectMake(self.view.frame.origin.x, self.view.frame.height, self.view.frame.width, self.view.frame.height)
            }
            }, completion: { value in
                if let ws = weakSelf {
                    ws.countryPicker.view.removeGestureRecognizer(ws.overlayTap!)
                    ws.countryPicker.view.removeFromSuperview()
                    ws.countryPicker.removeFromParentViewController()
                }
        })
        if let c = country {
            currentCountry = c
        }
    }
    
    @IBAction func countryButtonClicked() {
        view.endEditing(true)
        Utils.shared.addOverlayToView(view)
        overlayTap = UITapGestureRecognizer(target: self, action: Selector("overlayTapped:"))
        Utils.shared.overlay!.addGestureRecognizer(overlayTap!)
        addChildViewController(countryPicker)
        countryPicker.view.frame = CGRectMake(view.frame.origin.x, view.frame.height, view.frame.width, view.frame.height)
        view.addSubview(countryPicker.view)
        countryPicker.selected = currentCountry
        weak var weakSelf = self
        UIView.animateWithDuration(0.5, animations: {
            if let ws = weakSelf {
                ws.countryPicker.view.frame = CGRectMake(ws.view.frame.origin.x, ws.nextButton.frame.maxY, ws.view.frame.width, ws.view.frame.height)
            }
        })
    }
    
    func overlayTapped(recognizer: UITapGestureRecognizer) {
        countryPickerDismissed(nil)
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
