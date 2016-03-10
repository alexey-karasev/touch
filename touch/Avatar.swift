//
//  Avatar.swift
//  touch
//
//  Created by Алексей Карасев on 09/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class Avatar {
    static let shared = Avatar()
    static let defaultsKey="avatar"
    static let targetSize = 91
    var image: UIImage {
        get {
            guard let data = NSUserDefaults.standardUserDefaults().objectForKey(Avatar.defaultsKey) as? NSData else {
                return scaleImage(UIImage(named: "Profile")!)
            }
            return UIImage(data: data)!
        }
        set {
            let image = scaleImage(newValue)
            NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(image), forKey: Avatar.defaultsKey)
        }
    }
    
    func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(Avatar.defaultsKey)
    }
    
    private func scaleImage(image: UIImage) -> UIImage {
        let size = CGSize(width: image.size.width, height: image.size.height)
        let squareSize = CGFloat(min(image.size.width, image.size.height))
        let scale = CGFloat(Avatar.targetSize) / squareSize
        let shift = Int(abs((size.width - size.height) / 2))
        var posX = 0, posY = 0
        if size.width > size.height {
            posX = shift
        } else {
            posY = shift
        }
        UIGraphicsBeginImageContextWithOptions(CGSize(width: squareSize, height: squareSize), false, scale);
        image.drawInRect(CGRect(x: -posX, y: -posY, width: Int(size.width), height: Int(size.height)))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return result
    }
}
