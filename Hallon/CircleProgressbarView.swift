//
//  CircleProgressbarView.swift
//  Hallon
//
//  Created by Paul Griffin on 21/07/15.
//  Copyright © 2015 Monafide AB. All rights reserved.
//

import UIKit

@IBDesignable
class CircleProgressbarView: UIView {
    
    @IBInspectable var angle: Double = 0.34 { didSet{ setNeedsDisplay()} }
    @IBInspectable var width: CGFloat = 5 { didSet{ setNeedsDisplay()} }
    @IBInspectable var reversed: Bool = false { didSet{ setNeedsDisplay()} }
    @IBInspectable var backColor: UIColor = UIColor.lightGrayColor() { didSet{ setNeedsDisplay()} }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, width)
        CGContextSetStrokeColorWithColor(context, reversed ? tintColor.CGColor : backColor.CGColor)
        CGContextMoveToPoint(context, bounds.width/2,width/2)
        CGContextAddArc(context, bounds.width/2 , bounds.height/2, bounds.width/2 - width/2, -CGFloat(M_PI / 2),-CGFloat(M_PI / 2) + CGFloat(angle*2*M_PI), 0)
        CGContextStrokePath(context)
        CGContextSetStrokeColorWithColor(context, !reversed ? tintColor.CGColor : backColor.CGColor)
        CGContextAddArc(context, bounds.width/2 , bounds.height/2, bounds.width/2 - width/2, -CGFloat(M_PI / 2), -CGFloat(M_PI / 2) + CGFloat(angle*2*M_PI), 1)
        CGContextStrokePath(context)
    }



}
