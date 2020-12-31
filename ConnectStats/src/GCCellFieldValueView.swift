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

    public enum DisplayIcon {
        case hide
        case left
        case right
    }
    
    public enum DisplayField {
        case hide
        case left
        case right
    }
    let field : GCField?
    let numberWithUnit : GCNumberWithUnit
    let geometry : RZNumberWithUnitGeometry
    let primaryField : GCField?
    
    let displayIcon : DisplayIcon
    
    var overrideFieldName : String?
    var displayField : DisplayField = .left
    var iconColor = UIColor.darkGray
    var iconInset : CGFloat = 2.0
    var numberAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.value)
    var unitAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.unit)
    var fieldAttribute : [NSAttributedString.Key:Any] = GCViewConfig.attribute(rzAttribute.field)
      
    init( numberWithUnit:GCNumberWithUnit,
          geometry: RZNumberWithUnitGeometry,
          field : GCField? = nil,
          primaryField: GCField? = nil,
          icon: DisplayIcon = .hide) {
        self.field = field
        self.numberWithUnit = numberWithUnit
        self.geometry = geometry
        self.primaryField = primaryField
        self.displayIcon = icon
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        self.field = GCField()
        self.numberWithUnit = GCNumberWithUnit()
        self.geometry = RZNumberWithUnitGeometry()
        self.primaryField = nil
        self.displayIcon = .hide
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: CGSize {
        return self.geometry.totalSize
        
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
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
        let drawnRect = self.geometry.drawInRect(numberRect,
                                                 numberWithUnit: self.numberWithUnit,
                                                 numberAttribute: self.numberAttribute,
                                                 unitAttribute: self.unitAttribute,
                                                 addUnit: addUnit)
        
        if self.displayIcon != .hide {
            if let field = self.field,
               let icon = field.icon(){
                let iconHeight = self.geometry.totalSize.height
                var iconRect = CGRect(x: fieldRect.origin.x, y: fieldRect.origin.y, width: iconHeight, height: iconHeight)
                //iconRect.origin.x = drawnRect.origin.x - iconHeight
                
                
                iconRect = iconRect.inset(by: UIEdgeInsets(top: iconInset, left: iconInset, bottom: iconInset, right: iconInset))
                
                fieldRect.origin.x += iconHeight
                fieldRect.size.width -= iconHeight
                if case DisplayIcon.right = self.displayIcon {
                    iconRect.origin.x = drawnRect.origin.x - iconHeight
                }
                // don't display if overlap with number
                if drawnRect.origin.x > iconRect.maxX {
                    icon.withTintColor(self.iconColor).draw(in: iconRect)
                }
            }
        }
        if self.displayField != .hide {
            if let fmtField = self.fieldDisplayName() {
                let fieldSize = (fmtField as NSString).size(withAttributes: self.fieldAttribute)
                // If too big enlarge to the left
                if fieldSize.width > fieldRect.size.width {
                    fieldRect.origin.x -= ( fieldSize.width - fieldRect.size.width)
                    fieldRect.size.width = fieldSize.width
                }else if case .right = self.displayField {
                    fieldRect.origin.x += (fieldRect.size.width - fieldSize.width)
                }
                /*let context = NSStringDrawingContext()
                context.minimumScaleFactor = 0.7
                (fmtField as NSString).draw(with: fieldRect, options: [], attributes: self.fieldAttribute, context: context)*/
                (fmtField as NSString).draw(at: fieldRect.origin, withAttributes: self.fieldAttribute)
            }
        }
    }
    
    func fieldDisplayName() -> String? {
        if self.overrideFieldName != nil {
            return self.overrideFieldName
        }
        return self.field?.displayName(withPrimary: self.primaryField)
    }
}
