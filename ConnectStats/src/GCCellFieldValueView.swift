//  MIT License
//
//  Created on 07/11/2020 for ConnectStats
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

class GCCellFieldValueView: UIView {

    var field : GCField? = nil
    var value : GCNumberWithUnit? = nil
    var attribute : [NSAttributedString.Key:Any]? = nil
    
    convenience init(field : GCField, numberWithUnit:GCNumberWithUnit, attr : [NSAttributedString.Key:Any]) {
        self.init(frame: CGRect.zero)
        self.field = field
        self.value = numberWithUnit
        self.attribute = attr
        self.backgroundColor = UIColor.clear
    }

    override var intrinsicContentSize: CGSize {
        var size = CGSize.zero
        if let valueSize = self.value?.formatDouble().size(withAttributes: self.attribute){
            size = valueSize
            size.width += valueSize.height
        }
        return size
        
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if let value = self.value {
            let str = value.formatDouble() as NSString
            let attr = self.attribute
            let size = str.size(withAttributes: attr)
            if let field = self.field,
               let icon = field.icon(){
                //print( "\(field) \(value.formatDouble()) \(value.formatDoubleNoUnits())")
                let iconRect = CGRect(x: 0.0, y: 0.0, width: size.height, height: size.height)
                icon.withTintColor(UIColor.white).draw(in: iconRect)
            }
            
            str.draw(at: CGPoint(x:size.height,y:0.0),
                     withAttributes:attr
            )
        }
    }
}
