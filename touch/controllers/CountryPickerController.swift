//
//  CountryPickerController.swift
//  touch
//
//  Created by Алексей Карасев on 24/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class CountryPickerController: UIViewController {
    
    @IBAction func closeButtonClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    convenience init() {
        self.init(nibName: "CountryPickerView", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Ti")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
