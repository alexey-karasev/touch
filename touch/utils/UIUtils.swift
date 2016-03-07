//
//  UIUtils.swift
//  touch
//
//  Created by Алексей Карасев on 07/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class UIUtils {
    var overlay:UIView?
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
