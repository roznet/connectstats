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
import RZUtilsSwift

class GCCellFieldValueView: UIView {

    let field : GCField
    let numberWithUnit : GCNumberWithUnit
    let geometry : RZNumberWithUnitGeometry
    let primaryField : GCField?
    let icon : Bool
    
    var valueAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.value)
    var unitAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.unit)
    var fieldAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.field)
      
    init(field : GCField,
         numberWithUnit:GCNumberWithUnit,
         geometry: RZNumberWithUnitGeometry,
         primaryField: GCField? = nil,
         icon: Bool = false) {
        self.field = field
        self.numberWithUnit = numberWithUnit
        self.geometry = geometry
        self.primaryField = primaryField
        self.icon = icon
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        self.field = GCField()
        self.numberWithUnit = GCNumberWithUnit()
        self.geometry = RZNumberWithUnitGeometry()
        self.primaryField = nil
        self.icon = false
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: CGSize {
        return self.geometry.totalSize
        
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        /*
        if let field = self.field,
           let icon = field.icon(){
            //print( "\(field) \(value.formatDouble()) \(value.formatDoubleNoUnits())")
            let iconRect = CGRect(x: 0.0, y: 0.0, width: size.height, height: size.height)
            icon.withTintColor(UIColor.white).draw(in: iconRect)
        }
        
        str.draw(at: CGPoint(x:size.height,y:0.0),
                 withAttributes:attr
        )*/
        
        let fmtNoUnit = self.numberWithUnit.formatDoubleNoUnits()
        let fmt = self.numberWithUnit.formatDouble()
        let fmtUnit = self.numberWithUnit.unit.abbr
        let fmtField = self.field.displayName(withPrimary: self.primaryField)
        
        let numberSize = (fmtNoUnit as NSString).size(withAttributes: self.valueAttribute)
        let unitSize = (fmtUnit as NSString).size(withAttributes: self.unitAttribute)
        let fieldSize = (fmtField as NSString?)?.size(withAttributes: self.fieldAttribute) ?? CGSize.zero

        // Drawing code
        //
        //     !----------!-----|-|-----!
        //      icon|field   23.2 km
        //      icon|field    169 km
        //      icon|field  15:05 min/km
      
        //     !----------!----|-|-!
        //      icon|field  23.2 km
        //      icon|field  2:12:05
            /*
        unitPoint.x += numberWidth + numberUnitSpacingSize.width
        if numberSize.width < numberWidth {
            // less than number line up to the right
            numberPoint.x += (numberWidth-numberSize.width)
        }// else line up to the left, so keep x
        // add icon
        if self.icon{
            if let icon = field.icon(){
                let iconRect = CGRect(x: current.x, y: current.y, width: numberSize.height, height: numberSize.height)
                let insetValue :CGFloat = 2.0
                icon.withTintColor(self.iconColor).draw(in: iconRect.insetBy(dx: insetValue, dy: insetValue))
            }
            // shift all text to the right by size of the icon
            numberPoint.x += numberSize.height
            unitPoint.x += numberSize.height
        }
        (fmtNoUnit as NSString).draw(at: numberPoint, withAttributes: self.valueAttribute)
        if( fmt != fmtNoUnit ){
            (fmtUnit as NSString).draw(at: unitPoint, withAttributes: self.unitAttribute)
        }
        
        current.y += (numberSize.height + spacing)
 */
    }
}
