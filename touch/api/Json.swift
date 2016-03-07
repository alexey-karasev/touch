//
//  Json.swift
//  touch
//
//  Created by Алексей Карасев on 07/03/16.
//  Copyright © 2016 Алексей Карасев. All rights reserved.
//

import UIKit

struct Json {
    enum Error: ErrorType {
        case InvalidNSData(String)
    }
    
    private let storage: [String:AnyObject]
    
    var data: NSData {
        return try! NSJSONSerialization.dataWithJSONObject(storage, options: NSJSONWritingOptions.PrettyPrinted)
    }
    var string: String {
        return NSString(data: data,
            encoding: NSUTF8StringEncoding) as! String
    }
    
    subscript(index: String) -> AnyObject? {
        return storage[index]
    }
    
    init(dictionary: [String:AnyObject]) {
        self.storage = dictionary
    }
    
    init(data: NSData?) throws {
        guard let data = data else {
            self.storage = [:]
            return
        }
        guard data.length > 0 else {
            self.storage = [:]
            return
        }
        guard let NSDict = try? NSJSONSerialization.JSONObjectWithData(data, options: []) else {
            throw Error.InvalidNSData(NSString(data: data,
                encoding: NSUTF8StringEncoding) as! String)
        }
        guard let dict = NSDict as? [String:AnyObject] else {
            throw Error.InvalidNSData(NSString(data: data,
                encoding: NSUTF8StringEncoding) as! String)
        }
        self.storage = dict
    }
}
