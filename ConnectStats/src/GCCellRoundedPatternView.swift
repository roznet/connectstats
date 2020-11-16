//  MIT License
//
//  Created on 16/10/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



import UIKit

class GCCellRoundedPatternView: UIView {

    var cornerRadii : CGFloat = 15.0;
    var lineWidth : CGFloat = 2.0;
    
    var borderColor : UIColor = UIColor.white
    var insideColor : UIColor = UIColor.clear
    
/*    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }*/
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath()
        
        let halfWidth = lineWidth/2.0
        
        let inrect = rect.inset(by: UIEdgeInsets(top: halfWidth, left: 0, bottom: halfWidth, right: halfWidth))
        path.move(to: inrect.origin)
        path.addLine(to:  CGPoint( x: inrect.origin.x + inrect.width - cornerRadii,
                                   y: inrect.origin.y) )
        path.addCurve(to: CGPoint( x: inrect.origin.x + inrect.width,
                                   y: inrect.origin.y + cornerRadii),
                      controlPoint1: CGPoint( x: inrect.origin.x+inrect.width,
                                              y: inrect.origin.y  ),
                      controlPoint2: CGPoint( x: inrect.origin.x+inrect.width,
                                              y: inrect.origin.y  ) )
        path.addLine(to: CGPoint(x: inrect.origin.x + inrect.width,
                                 y: inrect.origin.y + inrect.size.height - cornerRadii) )
        path.addCurve(to: CGPoint( x: inrect.origin.x + inrect.width - cornerRadii,
                                   y: inrect.origin.y + inrect.size.height),
                      controlPoint1: CGPoint( x: inrect.origin.x+inrect.width, y: inrect.origin.y + inrect.size.height ),
                      controlPoint2: CGPoint( x: inrect.origin.x+inrect.width, y: inrect.origin.y + inrect.size.height ))
        path.addLine(to: CGPoint(x: inrect.origin.x,
                                 y: inrect.origin.y + inrect.height))
        self.borderColor.setStroke()
        self.insideColor.setFill()
        path.lineWidth = lineWidth;
        path.stroke()
        path.fill()
    }
}
