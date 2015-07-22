//
//  InterfaceController.swift
//  HallonWatch Extension
//
//  Created by Paul Griffin on 19/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import WatchKit
import Foundation
import ClockKit
import CoreGraphics

class InterfaceController: WKInterfaceController {

    @IBOutlet var daysLeftLabel: WKInterfaceLabel!
    @IBOutlet var arcImageView: WKInterfaceImage!
    var scraper: HallonScraper!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let autoLoginScraper = HallonScraper(){
            scraper = autoLoginScraper
            if let usage = scraper.getHallonUsageFromCache(){
                arcImageView.setImage(drawCustomArcs(usage))
                if usage.lastUpdated.timeIntervalSinceNow < -60*60{
                    self.update()
                }
            } else {
                self.update()
            }
        }else{
            //logout(animated)
        }
        
    }
    func update(){
        scraper.getDataUsage{
            switch $0{
            case .Success(let usage):
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.arcImageView.setImage(self.drawCustomArcs(usage))
                }
            case .Error(let error):
                print(error)

            }
        }
    }


    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func drawCustomArcs(usage: HallonScraper.HallonUsage) -> UIImage{
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let daysInMonth = calendar.rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: now).length
        let startOfMonth = calendar.dateFromComponents(calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month], fromDate: now))!
        let secondsSinceStartOfMonth = now.timeIntervalSinceDate(startOfMonth)
        let daysLeft = daysInMonth - calendar.component(NSCalendarUnit.Day, fromDate: now) + 1
        daysLeftLabel.setText("\(daysLeft) dagar kvar")
        
        
        let size = CGSize(width: 250.0, height: 250.0)
        let center = CGPoint(x: size.width/2.0, y: size.height/2.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        
        drawArcWithDiameter(230, center: center, width: 20, context: context, angle: usage.dataUsed / usage.dataMax, backColor: UIColor(hex: 0x656565).CGColor, frontColor: UIColor(hex: 0x95002F).CGColor)
        
        drawArcWithDiameter(250, center: center, width: 10, context: context, angle: secondsSinceStartOfMonth / Double(daysInMonth*24*60*60), backColor: UIColor.blackColor().CGColor, frontColor: UIColor(hex: 0x97B414).CGColor)
        
        drawCustomText(center, dataLeft: usage.dataLeft, dataMax: usage.dataMax)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func drawArcWithDiameter(diameter: CGFloat, center: CGPoint, width: CGFloat, context: CGContext, angle: Double, backColor:CGColor, frontColor:CGColor){
        CGContextSetLineWidth(context, CGFloat(width))
        CGContextSetStrokeColorWithColor(context, backColor)
        CGContextMoveToPoint(context, center.x, center.y - diameter/2)
        CGContextAddArc(context, center.x , center.y, diameter/2 - width/2, -CGFloat(M_PI / 2),-CGFloat(M_PI / 2) + CGFloat(angle*2*M_PI), 0)
        CGContextStrokePath(context)
        CGContextSetStrokeColorWithColor(context, frontColor)
        CGContextAddArc(context, center.x , center.y, diameter/2 - width/2, -CGFloat(M_PI / 2), -CGFloat(M_PI / 2) + CGFloat(angle*2*M_PI), 1)
        CGContextStrokePath(context)
    }
    func drawCustomText(center: CGPoint, dataLeft: Double, dataMax: Double){
        let l1 = String(format: "%.1f", dataLeft) as NSString
        let l2 = String(format: "av %.1f GB", dataMax) as NSString
        
        let font1 = UIFont.systemFontOfSize(64, weight: UIFontWeightHeavy)//UIFont(name: "Helvetica Neue Bold", size: 64.0)!
        let attributes1:[String: AnyObject] = [
            NSFontAttributeName: font1,
            
            NSForegroundColorAttributeName:UIColor(hex: 0x95002F),
        ]
        let font2 = UIFont.systemFontOfSize(28)
        let attributes2:[String: AnyObject] = [
            NSFontAttributeName: font2,
            NSForegroundColorAttributeName:UIColor(hex: 0x656565),
        ]
        
        let size1 = l1.sizeWithAttributes(attributes1)
        let size2 = l2.sizeWithAttributes(attributes2)
        let margin:CGFloat = -3
        let offset: CGFloat = -10
        let position1 = CGPoint(x: center.x-size1.width/2, y: center.y-size1.height/2 - size2.height/2-margin/2+offset)
        let position2 = CGPoint(x: center.x-size2.width/2, y: position1.y + size1.height + margin)
        
        l1.drawAtPoint(position1, withAttributes: attributes1)
        l2.drawAtPoint(position2, withAttributes: attributes2)
        
    }
    
    
    
    

    func debugComplications(){
        if let server = CLKComplicationServer.sharedInstance(){
            if let complications = server.activeComplications{
                complications.map{
                    //print("Relading complication \($0)")
                    server.reloadTimelineForComplication($0)
                }
                if complications.isEmpty{
                    print("There are no complications")
                }else {
                    print("There complications are \(complications)")
                }
            } else {
                print("The complication list is null!")
            }
        } else {
            print("The complicationserver is not available :O")
        }
    }
}
