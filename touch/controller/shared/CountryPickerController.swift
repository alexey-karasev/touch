//
//  CountryPickerController.swift
//  touch
//
//  Created by Алексей Карасев on 24/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

protocol CountryPickerDelegate: class {
    func countryPickerDismissed(country:CountryPickerController.Country?)
}

class CountryPickerController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    class Country {
        let imageName:String
        let flag:UIImage?
        let title:String
        let code:String
        
        init(imageName:String, title:String, code:String) {
            self.imageName = imageName
            self.title = title
            self.flag = UIImage(named: imageName)
            self.code = code
        }
        
    }
    
    @IBOutlet weak var table: UITableView!
    var overlayTap:UIGestureRecognizer!
    weak var target: UIViewController?
    weak var delegate: CountryPickerDelegate?
    
    var countries: [Country] = []
    var selected: Country? {
        willSet {
            if newValue != nil && table != nil {
                var number = 0;
                for (index, country) in countries.enumerate() {
                    if country === newValue! {
                        number = index
                        break
                    }
                }
                table.selectRowAtIndexPath(NSIndexPath(forRow: number, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
            }
        }
    }
    
    
    // Static constructor, used because initialization by Storyboard returns instantiated controller
    // Delegate is called with the selected country, countries is the list of countries
    static func instantiate(delegate delegate: CountryPickerDelegate, countries: [Country]) -> CountryPickerController {
        let sb = UIStoryboard(name: "Common", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("CountryPicker")
        let result = vc as! CountryPickerController
        result.delegate = delegate
        result.countries = countries
        return result
    }
    
    
    // Behavior of the controller
    
    
    // target - the controller where Country Picker will be presented
    // top - top of the Country picker (0 = fullscreen)
    // currentCountry - used to highlight selected country cell
    func present(target: UIViewController, top:CGFloat, currentCountry: Country?) {
        Utils.shared.addOverlayToView(target.view)
        overlayTap = UITapGestureRecognizer(target: self, action: Selector("overlayTapped:"))
        Utils.shared.overlay!.addGestureRecognizer(overlayTap)
        target.addChildViewController(self)
        view.frame = CGRectMake(target.view.frame.origin.x, target.view.frame.height, target.view.frame.width, target.view.frame.height)
        target.view.addSubview(view)
        selected = currentCountry
        self.target = target
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            if self != nil && self!.target != nil{
                self!.view.frame = CGRectMake(self!.target!.view.frame.origin.x, top,
                    self!.target!.view.frame.width, self!.target!.view.frame.height)
            }
        })
    }
    
    // dismisses the Country picker and calls back delegate with selected country
    private func dismiss(country: Country?) {
        if let d = delegate {
            d.countryPickerDismissed(country)
        }
        Utils.shared.dismissOverlay()
        UIView.animateWithDuration(0.5, animations: { [weak self] in
            if self != nil {
                self!.view.frame =  CGRectMake(self!.target!.view.frame.origin.x, self!.target!.view.frame.height, self!.target!.view.frame.width, self!.target!.view.frame.height)
            }
            }, completion: { [weak self] (value) in
                if self != nil {
                    self!.view.removeGestureRecognizer(self!.overlayTap!)
                    self!.overlayTap = nil
                    self!.view.removeFromSuperview()
                    self!.removeFromParentViewController()
                }
            })
    }

    func overlayTapped(recognizer: UITapGestureRecognizer) {
        dismiss(nil)
    }
    
    @IBAction func closeButtonClicked() {
        dismiss(nil)
    }
    
//    Table view controller
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = table.dequeueReusableCellWithIdentifier("default")
        let cell = c as! CountryPickerViewCell
        let country = countries[indexPath.item]
        cell.title.text = country.title
        cell.flag.image = country.flag
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let country = countries[indexPath.item]
        dismiss(country)
    }
    
//    Default methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        
        // update selected row if the table view didn't exist when selected was set
        let s = selected
        selected = nil
        selected = s
        
        //adding top and bottom separators
        let px = 1 / UIScreen.mainScreen().scale
        let frameTop = CGRectMake(0, 0, table.frame.size.width, px)
        let lineTop: UIView = UIView(frame: frameTop)
        lineTop.backgroundColor = table.separatorColor
        table.tableHeaderView = lineTop
        table.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
