//
//  ProfileButton.swift
//  touch
//
//  Created by Алексей Карасев on 09/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class ProfileButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView!.layer.cornerRadius = CGFloat(Avatar.targetSize / 2)
        imageView!.layer.borderWidth = 3.0;
        imageView!.layer.borderColor = UIColor(red: 43.0 / 255, green: 201.0 / 255, blue: 216.0 / 255, alpha: 1.0).CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageView!.layer.cornerRadius = CGFloat(Avatar.targetSize / 2)
        imageView!.layer.borderWidth = 3.0;
        imageView!.layer.borderColor = UIColor(red: 43.0 / 255, green: 201.0 / 255, blue: 216.0 / 255, alpha: 1.0).CGColor
    }

}
