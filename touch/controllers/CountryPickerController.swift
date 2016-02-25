//
//  CountryPickerController.swift
//  touch
//
//  Created by Алексей Карасев on 24/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

protocol CountryPickerDelegate {
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

    var delegate: CountryPickerDelegate?
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
    
    static func instantiate(delegate delegate: CountryPickerDelegate, countries: [Country]) -> CountryPickerController {
        let sb = UIStoryboard(name: "Common", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("CountryPicker")
        let result = vc as! CountryPickerController
        result.delegate = delegate
        result.countries = countries
        return result
    }
    
    @IBAction func closeButtonClicked() {
        if let d = delegate {
            d.countryPickerDismissed(nil)
        }
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
        if let d = delegate {
            let country = countries[indexPath.item]
            d.countryPickerDismissed(country)
        }
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
