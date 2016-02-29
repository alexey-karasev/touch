//
//  Utils.swift
//  touch
//
//  Created by Алексей Карасев on 23/02/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class Utils {
    static let shared = Utils()
    var overlay:UIView?
    
    func alert(header header:String, message: String) {
        let alert = UIAlertView(title: NSLocalizedString(header, comment: header), message: NSLocalizedString(message, comment: message), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Ok"))
        alert.show()
    }
    
    func addOverlayToView(parent:UIView, withHUD:Bool = false, blockActivity:Bool = false, opacity: Float = 0.6) {
        let screenRect = UIScreen.mainScreen().bounds
        let coverView = UIView(frame: screenRect)
        coverView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(CGFloat(opacity))
        if withHUD {
            let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            activity.center = coverView.center
            coverView.addSubview(activity)
            activity.startAnimating()
        }
        parent.addSubview(coverView)
        
        if blockActivity {
            parent.userInteractionEnabled = false
        }
        self.overlay = coverView
    }
    
    func dismissOverlay() {
        if let overlay = self.overlay {
            overlay.superview!.userInteractionEnabled = true
            overlay.removeFromSuperview()
            self.overlay = nil
        }
    }

}
