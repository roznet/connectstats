//  MIT License
//
//  Created on 15/10/2020 for ConnectStats
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

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}

class GCCellActivity: UITableViewCell {
    @IBOutlet var borderView: GCCellRoundedPatternView!
    @IBOutlet var leftBorderView: GCCellRoundedPatternView!
    @IBOutlet var iconView: UIImageView!

    @IBOutlet var leftFieldValues: GCCellFieldValueColumnView!
    @IBOutlet var rightFieldValues: GCCellFieldValueColumnView!
    
    @IBOutlet var today: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var year: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @objc func setup(for activity : GCActivity){
        self.backgroundColor = UIColor.black
        self.leftFieldValues.backgroundColor = UIColor.clear
        self.rightFieldValues.backgroundColor = UIColor.clear
        
        self.leftFieldValues.clearFieldAndNumbers()
        self.rightFieldValues.clearFieldAndNumbers()
        
        self.borderView.insideColor = GCViewConfig.cellBackgroundDarker(forActivity: activity)
        self.leftBorderView.insideColor = GCViewConfig.cellBackgroundLighter(forActivity: activity)
        self.borderView.borderColor = GCViewConfig.textColor(forActivity: activity)
        self.leftBorderView.borderColor = GCViewConfig.textColor(forActivity: activity)
        
        self.borderView.setNeedsDisplay()
        self.leftBorderView.setNeedsDisplay()
        
        if let icon = GCViewIcons.activityTypeDynamicIcon(for: activity.activityType){
            self.iconView.image = icon
        }else{
            self.iconView.image = nil;
        }
        
        if let distanceField = GCField(for: gcFieldFlag.sumDistance, andActivityType: activity.activityType),
           let distance = activity.numberWithUnit(for: distanceField ){
            self.leftFieldValues.add(field: distanceField, numberWithUnit: distance)
        }
        
        if let durationField = GCField(for: gcFieldFlag.sumDuration, andActivityType: activity.activityType),
           let duration = activity.numberWithUnit(for: durationField){
            self.leftFieldValues.add(field: durationField, numberWithUnit: duration)
        }
        self.leftFieldValues.valueAttribute = GCViewConfig.attributeBold16()
        self.leftFieldValues.unitAttribute = GCViewConfig.attribute16Gray()
        self.leftFieldValues.displayIcons = false
        self.rightFieldValues.displayIcons = false
        
        let rightFields : [GCField] = [
            GCField(for: gcFieldFlag.weightedMeanSpeed, andActivityType: activity.activityType),
            GCField(for: gcFieldFlag.weightedMeanHeartRate, andActivityType: activity.activityType),
            GCField(for: gcFieldFlag.power, andActivityType: activity.activityType),
            GCField(for: gcFieldFlag.altitudeMeters, andActivityType: activity.activityType),
        ]
        for field in rightFields {
            if let nu = activity.numberWithUnit(for: field) {
                self.rightFieldValues.add(field: field, numberWithUnit: nu)
            }
        }
        self.rightFieldValues.valueAttribute = GCViewConfig.attributeBold14()
        self.rightFieldValues.unitAttribute = GCViewConfig.attribute14Gray()
        self.leftFieldValues.distributeVertically = true;
        self.rightFieldValues.distributeVertically = false
        let useDate = (activity.date as NSDate)
        self.today.text = useDate.dayFormat()
        self.date.text = useDate.calendarUnitFormat(NSCalendar.Unit.day)
        self.time.text = useDate.timeShortFormat()
        self.year.text = String(useDate.calendarUnitFormat(NSCalendar.Unit.year).suffix(2))
        
        
    }
               
               
}
