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

class GCCellFieldValueColumnView: UIView {

    var fields : [GCField] = []
    var numberWithUnits : [GCNumberWithUnit] = []
    var valueAttribute : [NSAttributedString.Key:Any]? = nil
    var unitAttribute : [NSAttributedString.Key:Any]? = nil
    var displayIcons = true;
    var defaultSpacing :CGFloat = 0.0
    var iconColor : UIColor = UIColor.white
    var distributeVertically = true
    
    func add(field:GCField, numberWithUnit:GCNumberWithUnit){
        fields.append(field)
        numberWithUnits.append(numberWithUnit)
        self.setNeedsDisplay()
    }
    
    func clearFieldAndNumbers(){
        self.fields = []
        self.numberWithUnits = []
        self.setNeedsDisplay()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        var unitWidth :CGFloat = 0.0
        var numberWidth : CGFloat = 0.0
        
        var height : CGFloat = 0.0;
        
        for numberWithUnit in numberWithUnits {
            let fmtNoUnit = numberWithUnit.formatDoubleNoUnits()
            let fmt  = numberWithUnit.formatDouble()
            let fmtUnit = numberWithUnit.unit.abbr
            
            if( fmt != fmtNoUnit ){
                let numberSize = (fmtNoUnit as NSString).size(withAttributes: self.valueAttribute)
                let unitSize   = (fmtUnit as NSString).size(withAttributes: self.unitAttribute)
                if( numberSize.width > numberWidth ){
                    numberWidth = numberSize.width
                }
                if( unitSize.width > unitWidth){
                    unitWidth = unitSize.width
                }
                height += max(unitSize.height, numberSize.height)
            }else{
                let numberSize = (fmtNoUnit as NSString).size(withAttributes: self.valueAttribute)
                height += numberSize.height
            }
        }
        
        var spacing = self.defaultSpacing
        
        if( height < rect.size.height - (2.0 * self.defaultSpacing)) {
            spacing = (rect.size.height - height - 2.0 * self.defaultSpacing) / CGFloat(self.numberWithUnits.count)
        }
        if( distributeVertically == false){
            spacing = self.defaultSpacing
        }
        var current = CGPoint(x: rect.origin.x + (rect.width-(numberWidth+unitWidth))/2.0, y: rect.origin.y + self.defaultSpacing)
        //
        //     !-----!-----||------!
        //      icon   23.2 km
        //      icon    169 km
        //      ico   15:05 min/km
        
        //     !-----!----||------!
        //      icon  23.2 km
        //      icon  2:12:05

        
        
        let numberUnitSpacingSize = (" " as NSString).size(withAttributes: self.valueAttribute)
        
        for (field,numberWithUnit) in zip(self.fields, self.numberWithUnits){
            let fmtNoUnit = numberWithUnit.formatDoubleNoUnits()
            let fmt = numberWithUnit.formatDouble()
            let fmtUnit = numberWithUnit.unit.abbr
            
            var numberPoint : CGPoint = current
            var unitPoint : CGPoint = current
            
            let numberSize = (fmtNoUnit as NSString).size(withAttributes: self.valueAttribute)

            unitPoint.x += numberWidth + numberUnitSpacingSize.width
            if numberSize.width < numberWidth {
                // less than number line up to the right
                numberPoint.x += (numberWidth-numberSize.width)
            }// else line up to the left, so keep x
            // add icon
            if self.displayIcons{
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
        }
    }
    

}
