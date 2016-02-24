//
//  PhoneVerificationController.swift
//  touch
//
//  Created by Алексей Карасев on 24/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class PhoneVerificationController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    lazy var countryPicker:CountryPickerController = CountryPickerController()
    
    @IBAction func countryButtonClicked() {

//        self.modal = [self.storyboard instantiateViewControllerWithIdentifier:@"HalfModal"];
//        [self addChildViewController:self.modal];
//        self.modal.view.frame = CGRectMake(0, 568, 320, 284);
//        [self.view addSubview:self.modal.view];
//        [UIView animateWithDuration:1 animations:^{
//        self.modal.view.frame = CGRectMake(0, 284, 320, 284);;
//        } completion:^(BOOL finished) {
//        [self.modal didMoveToParentViewController:self];
//        }];
        addChildViewController(countryPicker)
        countryPicker.view.frame = CGRectMake(view.frame.origin.x, view.frame.height, view.frame.width, view.frame.height)
        view.addSubview(countryPicker.view)
        weak var weakSelf = self
        UIView.animateWithDuration(0.5, animations: {
            if let ws = weakSelf {
                ws.countryPicker.view.frame = CGRectMake(ws.view.frame.origin.x, ws.nextButton.frame.maxY, ws.view.frame.width, ws.view.frame.height)
            }
        })
//        countryPicker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
//        presentViewController(countryPicker, animated: true, completion: nil)
//        countryPicker.view.frame = CGRectMake(0, 500, 375, 300)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
