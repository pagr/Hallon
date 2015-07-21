//
//  hallonScraper.swift
//  Hallon
//
//  Created by Paul Griffin on 17/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import UIKit

enum Result<T,R>{
    case Success(value: T)
    case Error(error: R)
}

class HallonScraper {
    let d = NSUserDefaults.standardUserDefaults()
    struct HallonUsage {
        let dataUsed:Double
        let dataMax:Double
        var dataLeft: Double {
            get {
                return dataMax-dataUsed
            }
        }
        let callsUsed:Double
        let textsUsed:Double
        let lastUpdated: NSDate
    }
    let username: String
    let password: String
    
    init?(){
        if let username = d["username"] as? String,
            let password = d["password"] as? String{
                self.username = username
                self.password = password
        }else{
            self.username = "ZEBRA"
            self.password = "zebra"
            return nil
        }
    }
    
    init(username: String, password: String){
        self.username = username
        self.password = password

        d["username"] = username
        d["password"] = password
    }
    func getHallonUsageFromCache() -> HallonUsage? {
        if let dataUsed = d["dataUsed"] as? Double,
            let dataMax = d["dataMax"] as? Double,
            let callsUsed = d["callsUsed"] as? Double,
            let textsUsed = d["textsUsed"] as? Double,
            let lastUpdated = d["lastUpdated"] as? NSDate{
            return HallonUsage(dataUsed: dataUsed, dataMax: dataMax, callsUsed: callsUsed, textsUsed: textsUsed, lastUpdated: lastUpdated)
        }
        return nil
    }
    private func saveHallonUsageToCache(usage: HallonUsage){
        d["dataUsed"] = usage.dataUsed
        d["dataMax"] = usage.dataMax
        d["callsUsed"] = usage.callsUsed
        d["textsUsed"] = usage.textsUsed
        d["lastUpdated"] = usage.lastUpdated
        d.synchronize()
    }
    
    private func getLoginParams(callback: [String:String] -> ()){
        let url = NSURL(string: "https://www.hallon.se/logga-in")!
        //let webpage = NSString(data: NSData(contentsOfURL: url)!, encoding: NSUTF8StringEncoding)! as String
        let urlSession = NSURLSession.sharedSession()
        urlSession.dataTaskWithURL(url){
            data, response, error in
            
            if let response = response as? NSHTTPURLResponse{
                let tmp = NSHTTPCookie.cookiesWithResponseHeaderFields(response.allHeaderFields as! [String:String], forURL: response.URL!)
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(tmp, forURL: response.URL, mainDocumentURL: nil)
            }
            if let data = data,
                let webpage = NSString(data: data, encoding: NSUTF8StringEncoding) as? String{
                let matches = webpage.matchesForRegexInText("<input [^/]+\\/>")
                var params = [String:String]()
                for match in matches {
                    if let parameter = match.matchesForRegexInText("name=\"([^\"]+)\"").first,
                        let value = match.matchesForRegexInText("value=\"([^\"]+)\"").first{
                            params[parameter] = value
                    }
                }
                return callback(params)
            }
            callback([String:String]())
        }?.resume()
    }
    
    func getDataUsage(retryCount:Int  = 3, callback: Result<HallonUsage, NSError> -> Void){
        let  urlString = "https://www.hallon.se/logga-in"
        getLoginParams{
            paramz in
            var params = paramz
            params["Password"] = self.password
            params["UserName"] = self.username
            params["ReturnUrl"] = "https://www.hallon.se/mina-sidor"
            
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = "&".join(params.map{ "".stringByAppendingUrlEncodedParam($0.0, value: $0.1) }).dataUsingEncoding(NSUTF8StringEncoding)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let urlSession = NSURLSession.sharedSession()
            urlSession.dataTaskWithRequest(request){
                data, response, error in
                if let error = error{
                    return callback(.Error(error: error))
                }
                if let data = data,
                    let webPage = NSString(data: data, encoding: NSUTF8StringEncoding) as? String{
                        //print(webPage)
                        let dataResults = webPage.matcheGroupsForRegexInText("class=\"amountused\">(\\d,?\\d*)</span> av (\\d,?\\d*) GB")
                        if dataResults.count == 2,
                            let usedCalls = webPage.matcheGroupsForRegexInText("class=\"amountused\">(\\d,?\\d*)</span> Av obegr&#228;nsade samtal").first?.doubleValue,
                            let usedTexts = webPage.matcheGroupsForRegexInText("class=\"amountused\">(\\d,?\\d*)</span> Av obegr&#228;nsade SMS/MMS").first?.doubleValue
                        {
                            let totalData = dataResults[1].doubleValue
                            let usedData = totalData - dataResults[0].doubleValue
                            let usage = HallonUsage(dataUsed: usedData, dataMax: totalData, callsUsed: usedCalls, textsUsed: usedTexts, lastUpdated: NSDate())
                            self.saveHallonUsageToCache(usage)
                            return callback(.Success(value: usage))
                        } else {
                            print("Probably failed to log in")
                            if retryCount == 0{
                                return callback(.Error(error: NSError(domain: "Failed to log in", code: 1, userInfo: nil)))
                            }
                            NSThread.sleepForTimeInterval(1)
                            return self.getDataUsage(retryCount-1, callback: callback)
                        }
                }
                if let response = response as? NSHTTPURLResponse{
                    return callback(.Error(error: NSError(domain: "Server error", code: response.statusCode, userInfo: nil)))
                }
                return callback(.Error(error: NSError(domain: "Server error", code: 1337, userInfo: nil)))
                }?.resume()
        }
    }
}
