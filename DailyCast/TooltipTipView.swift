//
//  TooltipTipView.swift
//  DailyCast
//
//  Created by Mustafa on 2/20/16.
//  Copyright © 2016 MustafaSoft. All rights reserved.
//
import UIKit

class TooltipTipView : UIView {
    let _defaultWidth:CGFloat = 8
    let _defaultHeight:CGFloat = 5
    
    let _tooltipColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
    
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: _defaultWidth, height: _defaultHeight))
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        UIColor.clearColor().set()
        CGContextFillRect(context, rect)
        
        CGContextSaveGState(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect))
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect))
        CGContextClosePath(context)
        CGContextSetFillColorWithColor(context, _tooltipColor)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
    }
    
    
    
}