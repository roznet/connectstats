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

    let field : GCField?
    let numberWithUnit : GCNumberWithUnit
    let geometry : RZNumberWithUnitGeometry
    let primaryField : GCField?
    let icon : Bool
    
    var numberAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.value)
    var unitAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.unit)
    var fieldAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.field)
      
    init( numberWithUnit:GCNumberWithUnit,
          geometry: RZNumberWithUnitGeometry,
          field : GCField? = nil,
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
        

        // Drawing code
        //
        //     !----------!-----|-|-----!
        //      icon|field   23.2 km
        //      icon|field    169 km
        //      icon|field  15:05 min/km
      
        //     !----------!----|-|-!
        //      icon|field  23.2 km
        //      icon|field  2:12:05
        
        var numberRect = rect
        var fieldRect = rect
        // Align number to the right
        numberRect.origin.x += (rect.size.width - self.geometry.totalSize.width)
        numberRect.size.width -= (rect.size.width - self.geometry.totalSize.width)
        fieldRect.size.width = (rect.size.width - self.geometry.totalSize.width)
        
        var addUnit = true;
        
        if let primaryField = primaryField, let field = self.field {
            if field != primaryField && primaryField.unit() == field.unit() {
                addUnit = false;
            }
        }
        self.geometry.drawInRect(numberRect,
                                 numberWithUnit: self.numberWithUnit,
                                 numberAttribute: self.numberAttribute,
                                 unitAttribute: self.unitAttribute,
                                 addUnit: addUnit)
        
        if self.icon {
            if let field = self.field,
               let icon = field.icon(){
                let iconHeight = self.geometry.totalSize.height
                let iconRect = CGRect(x: fieldRect.origin.x, y: fieldRect.origin.y, width: iconHeight, height: iconHeight)
                fieldRect.origin.x += iconHeight
                fieldRect.size.width -= iconHeight
                icon.withTintColor(UIColor.white).draw(in: iconRect)
            }
        }
        if let fmtField = self.field?.displayName(withPrimary: self.primaryField) {
            (fmtField as NSString).draw(at: fieldRect.origin, withAttributes: self.fieldAttribute)
            /*(fmtField as NSString).draw(with: fieldRect,
                                        options: NSStringDrawingOptions(),
                                        attributes: self.fieldAttribute,
                                        context: nil)*/
        }
    }
}
