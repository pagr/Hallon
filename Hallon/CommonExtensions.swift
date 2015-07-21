//
//  CommonExtensions.swift
//  Hallon
//
//  Created by Paul Griffin on 17/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import UIKit

extension String {
    func stringByAppendingUrlEncodedParam(param: String, value: String) -> String{
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("_.-")
        let urlEncodedParam = param.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
        let urlEncodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
        return self.stringByAppendingString(urlEncodedParam + "=" + urlEncodedValue)
    }
    
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        if let from = String.Index(self.utf16.startIndex + nsRange.location, within: self),
            let to = String.Index(self.utf16.startIndex + nsRange.location + nsRange.length, within: self) {
                return from ..< to
        }
        return nil
    }
    
    func matchesForRegexInText(regex: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex,
            options: [])
        let results = regex.matchesInString(self,
            options: [], range: NSMakeRange(0, self.utf16.count))
        return results.map {
            match in
            self.substringWithRange(self.rangeFromNSRange(match.rangeAtIndex(match.numberOfRanges-1))!)
        }
    }
    func matcheGroupsForRegexInText(regex: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex,
            options: [])
        let results = regex.matchesInString(self,
            options: [], range: NSMakeRange(0, self.utf16.count))
        
        
        if let match = results.first{
            return (1..<match.numberOfRanges).map{
                self.substringWithRange(self.rangeFromNSRange(match.rangeAtIndex($0))!)
            }
        }
        return [String]()
    }
    var doubleValue: Double{
        let value = (self as NSString).doubleValue
        if value == 0 {
            return (self.stringByReplacingOccurrencesOfString(",", withString: ".") as NSString).doubleValue
        }
        return value
    }
}

extension NSUserDefaults {
    subscript(key: String) -> AnyObject? {
        get {
            return objectForKey(key)
        }
        set {
            setObject(newValue, forKey: key)
        }
    }
}