//
//  MainViewController.swift
//  Hallon
//
//  Created by Paul Griffin on 21/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var dataLeftLabel: UILabel!
    @IBOutlet weak var dataTotalLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var callsUsedLabel: UILabel!
    @IBOutlet weak var textsUsedLabel: UILabel!
    
    @IBOutlet weak var timeProgressView: CircleProgressbarView!
    
    @IBOutlet weak var dataProgressView: CircleProgressbarView!
    
    var scraper:HallonScraper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        if let autoLoginScraper = HallonScraper(){
            scraper = autoLoginScraper
            if let usage = scraper.getHallonUsageFromCache(){
                self.updateUI(usage)
            }
            self.update()
        }else{
            logout(animated)
        }
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        logout(true)
    }
    
    func logout(animated: Bool){
        let loginViewController = storyboard!.instantiateViewControllerWithIdentifier("loginViewController")
        presentViewController(loginViewController, animated: animated, completion: { })
        scraper?.logout()
        scraper = nil
    }
    func update(){
        scraper.getDataUsage{
            switch $0{
            case .Success(let usage):
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.updateUI(usage);
                }
            case .Error(let error):
                print(error)
                let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("loginViewController")
                self.presentViewController(loginViewController, animated: true, completion: { })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI(usage: HallonScraper.HallonUsage){
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let daysInMonth = calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: now).length
        
        let startOfMonth = calendar.dateFromComponents(calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: now))!
        let secondsSinceStartOfMonth = now.timeIntervalSinceDate(startOfMonth)
        
        let daysLeft = daysInMonth - calendar.component(NSCalendarUnit.Day, fromDate: now) + 1
        
        self.dataProgressView.angle = usage.dataUsed / usage.dataMax
        self.timeProgressView.angle = secondsSinceStartOfMonth / Double(daysInMonth*24*60*60)
        self.dataTotalLabel.text = String(format: "av %.1f GB kvar", arguments: [usage.dataMax])
        self.dataLeftLabel.text = String(format: "%.1f", arguments: [usage.dataLeft])
        self.callsUsedLabel.text = String(format: "%.0f", arguments: [usage.callsUsed])
        self.textsUsedLabel.text = String(format: "%.0f", arguments: [usage.textsUsed])
        self.daysLeftLabel.text = String(format: "%d dagar kvar av månaden", arguments: [daysLeft])
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
