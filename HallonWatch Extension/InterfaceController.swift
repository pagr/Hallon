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

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
               // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //debugComplications()
        

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
