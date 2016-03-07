//
//  Logger.swift
//  touch
//
//  Created by Алексей Карасев on 07/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

class TextUtils {
    func alert(header header:String, message: String) {
        let alert = UIAlertView(title: NSLocalizedString(header, comment: header), message: NSLocalizedString(message, comment: message), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "Ok"))
        alert.show()
    }
    
    func alertError(name:String) {
        alert(header: localString("ERROR"), message: localString(name))
    }
    
    func log(message: String) {
        print(message)
    }
    
    func localString(name:String) -> String{
        return NSLocalizedString(name, comment: name)
    }

}
