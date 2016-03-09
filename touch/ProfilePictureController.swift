//
//  ProfilePictureController.swift
//  touch
//
//  Created by Алексей Карасев on 09/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class ProfilePictureController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func selectProfileClicked(sender: AnyObject) {
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    @IBOutlet weak var selectProfileButton: UIButton!
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        AppUser.shared?.avatar = image
        selectProfileButton.setImage(AppUser.shared?.avatar, forState: .Normal)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        selectProfileButton.setImage(AppUser.shared?.avatar, forState: .Normal)
    }
}
