//  MIT License
//
//  Created on 14/11/2020 for ConnectStats
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

class GCCellFieldValueColumnView: UIView {

    var fields : [GCField] = []
    var numberWithUnits : [GCNumberWithUnit] = []
    var valueAttribute : [NSAttributedString.Key:Any] = [:]
    var unitAttribute : [NSAttributedString.Key:Any] = [:]
    var displayIcons : GCCellFieldValueView.DisplayIcon = .hide;
    var displayUnit = true;
    var defaultVerticalSpacing :CGFloat = 5.0
    var defaultHorizontalSpacing :CGFloat = 5.0
    var iconColor : UIColor = UIColor.white
    var distributeVertically = true
    var geometry : RZNumberWithUnitGeometry = RZNumberWithUnitGeometry()
    
    func add(field:GCField, numberWithUnit:GCNumberWithUnit){
        fields.append(field)
        numberWithUnits.append(numberWithUnit)
        self.geometry.adjust(for: numberWithUnit,numberAttribute: self.valueAttribute, unitAttribute: self.unitAttribute)
        self.setNeedsDisplay()
    }
    
    func clearFieldAndNumbers(){
        self.geometry.reset()
        self.fields = []
        self.numberWithUnits = []
        self.setNeedsDisplay()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        var spacing = self.defaultVerticalSpacing
        let totalHeight = self.geometry.accumulatedTotalSize.height
        let oneHeight = self.geometry.totalSize.height
        
        // does height fit allowing for top and bottom defaultSpacing?
        if( totalHeight < rect.size.height - (2.0 * self.defaultVerticalSpacing)) {
            spacing = (rect.size.height - totalHeight - 2.0 * self.defaultVerticalSpacing) / CGFloat(self.numberWithUnits.count)
        }
        if( distributeVertically == false){
            spacing = min( self.defaultVerticalSpacing, spacing)
        }
        
        var current = CGPoint(x: rect.origin.x, y: rect.origin.y + self.defaultVerticalSpacing)
        //
        //     !-----!-----||------!
        //      icon   23.2 km
        //      icon    169 km
        //      ico   15:05 min/km
        
        //     !-----!----||------!
        //      icon  23.2 km
        //      icon  2:12:05
        
        for (field,numberWithUnit) in zip(self.fields, self.numberWithUnits){
            
            var currentRect = CGRect(origin: current, size: CGSize(width: rect.size.width, height: oneHeight) )
            if self.displayIcons != .hide {
                // shift all text to the right by size of the icon
                currentRect.origin.x += oneHeight + self.defaultHorizontalSpacing
                currentRect.size.width -= oneHeight + self.defaultHorizontalSpacing
            }
            
            let drawnRect = self.geometry.drawInRect(currentRect,
                                     numberWithUnit: numberWithUnit,
                                     numberAttribute: self.valueAttribute,
                                     unitAttribute: self.unitAttribute,
                                     addUnit: self.displayUnit)
            
            if self.displayIcons != .hide {
                if let icon = field.icon(){
                    var iconRect = CGRect(x: current.x, y: current.y, width: oneHeight, height: oneHeight)
                    let insetValue : CGFloat = 2.0
                    if case .right = self.displayIcons {
                        iconRect.origin.x = drawnRect.origin.x - (oneHeight + self.defaultHorizontalSpacing);
                    }
                    
                    icon.withTintColor(self.iconColor).draw(in: iconRect.insetBy(dx: insetValue, dy: insetValue))
                }
            }

            current.y += (oneHeight + spacing)
        }
    }
    

}
