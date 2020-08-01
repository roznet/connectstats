//  MIT License
//
//  Created on 26/07/2020 for ConnectStats
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

class GCStatsMultiFieldConfigViewController: UIViewController {
    @IBOutlet var viewChoiceSegment: UISegmentedControl!
    @IBOutlet var calendarAggregationSegment: UISegmentedControl!
    @IBOutlet var viewConfigSegment: UISegmentedControl!
    @IBOutlet var periodSegment: UISegmentedControl!
    @IBOutlet var graphTypeSegment: UISegmentedControl!
    
    
    @IBOutlet var previewTableView: UITableView!
    
    @objc var multiFieldViewController : GCStatsMultiFieldViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.previewTableView.dataSource = self.multiFieldViewController
        self.previewTableView.delegate = self.multiFieldViewController
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.multiFieldViewController?.updateCallback = {
            self.previewTableView.reloadData()
        }
        self.synchronizeConfigToView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.multiFieldViewController?.updateCallback = nil
    }
    @IBAction func done(_ sender: Any) {
        self.multiFieldViewController?.updateCallback = nil
        self.multiFieldViewController?.notifyCallBack(self, info: RZDependencyInfo())
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        self.synchronizeViewToConfig(segment: sender)
    }
    
    func synchronizeConfigToView() {
        if let multiFieldConfig : GCStatsMultiFieldConfig = self.multiFieldViewController?.multiFieldConfig {
            switch multiFieldConfig.viewChoice {
            case gcViewChoice.summary:
                viewChoiceSegment.selectedSegmentIndex = 0
                viewConfigSegment.isEnabled = false
                calendarAggregationSegment.isEnabled = false
            case gcViewChoice.calendar:
                viewChoiceSegment.selectedSegmentIndex = 1
                viewConfigSegment.isEnabled = true
                calendarAggregationSegment.isEnabled = true
            case gcViewChoice.fields:
                viewChoiceSegment.selectedSegmentIndex = 2
                viewConfigSegment.isEnabled = true
                calendarAggregationSegment.isEnabled = true
            @unknown default:
                viewChoiceSegment.selectedSegmentIndex = 0
            }
            switch multiFieldConfig.viewConfig {
            case gcStatsViewConfig.all:
                viewConfigSegment.selectedSegmentIndex = 0
            case gcStatsViewConfig.last3M:
                viewConfigSegment.selectedSegmentIndex = 1
            case gcStatsViewConfig.last6M:
                viewConfigSegment.selectedSegmentIndex = 2
            case gcStatsViewConfig.last1Y:
                viewConfigSegment.selectedSegmentIndex = 3
            default:
                viewConfigSegment.isEnabled = false
            }
            
            switch  multiFieldConfig.calendarConfig.calendarUnit {
            case NSCalendar.Unit.weekOfYear:
                calendarAggregationSegment.selectedSegmentIndex = 0
                viewConfigSegment.setEnabled(true, forSegmentAt: 1)
                viewConfigSegment.setEnabled(true, forSegmentAt: 2)
                viewConfigSegment.setEnabled(true, forSegmentAt: 3)
            case NSCalendar.Unit.month:
                calendarAggregationSegment.selectedSegmentIndex = 1
                viewConfigSegment.setEnabled(false, forSegmentAt: 1)
                viewConfigSegment.setEnabled(true, forSegmentAt: 2)
                viewConfigSegment.setEnabled(true, forSegmentAt: 3)
            case NSCalendar.Unit.year:
                calendarAggregationSegment.selectedSegmentIndex = 2
                viewConfigSegment.setEnabled(false, forSegmentAt: 1)
                viewConfigSegment.setEnabled(false, forSegmentAt: 2)
                viewConfigSegment.setEnabled(false, forSegmentAt: 3)
            default:
                if multiFieldConfig.calendarConfig.calendarUnit == kCalendarUnitNone {
                    calendarAggregationSegment.selectedSegmentIndex = 3
                }else{
                    calendarAggregationSegment.selectedSegmentIndex = 0
                }
            }
            switch multiFieldConfig.calendarConfig.periodType {
            case gcPeriodType.calendar:
                periodSegment.selectedSegmentIndex = 0;
            case gcPeriodType.rolling:
                periodSegment.selectedSegmentIndex = 1;
            case gcPeriodType.toDate:
                periodSegment.selectedSegmentIndex = 2;
            default:
                periodSegment.selectedSegmentIndex = 0;
            }
            
            switch multiFieldConfig.graphChoice {
            case gcGraphChoice.cumulative:
                graphTypeSegment.selectedSegmentIndex = 0;
            default:
                graphTypeSegment.selectedSegmentIndex = 1;
            }
        }
    }
    
    func synchronizeViewToConfig(segment : UISegmentedControl) {
        if let currentMultiFieldConfig : GCStatsMultiFieldConfig = self.multiFieldViewController?.multiFieldConfig,
            let multiFieldConfig = GCStatsMultiFieldConfig.fieldListConfig(from: currentMultiFieldConfig) {
            let viewIndex = self.viewChoiceSegment.selectedSegmentIndex
            if viewIndex == 0 {
                multiFieldConfig.viewChoice = gcViewChoice.summary
            }else if viewIndex == 1{
                multiFieldConfig.viewChoice = gcViewChoice.calendar
                if( multiFieldConfig.calendarConfig.calendarUnit == kCalendarUnitNone){
                    multiFieldConfig.calendarConfig.calendarUnit = NSCalendar.Unit.weekOfYear
                }
                if( multiFieldConfig.viewConfig == gcStatsViewConfig.unused){
                    multiFieldConfig.viewConfig = gcStatsViewConfig.all;
                }
            }else if viewIndex == 2{
                multiFieldConfig.viewChoice = gcViewChoice.fields
                if( multiFieldConfig.viewConfig == gcStatsViewConfig.unused){
                    multiFieldConfig.viewConfig = gcStatsViewConfig.all;
                }
            }
            let filterIndex = self.viewConfigSegment.selectedSegmentIndex
            if filterIndex == 0 {
                multiFieldConfig.viewConfig = gcStatsViewConfig.all
            }else if filterIndex == 1{
                multiFieldConfig.viewConfig = gcStatsViewConfig.last3M
            }else if filterIndex == 2{
                multiFieldConfig.viewConfig = gcStatsViewConfig.last6M
            }else if filterIndex == 3{
                multiFieldConfig.viewConfig = gcStatsViewConfig.last1Y
            }
            let calendarIndex = calendarAggregationSegment.selectedSegmentIndex
            if calendarIndex == 0{
                multiFieldConfig.calendarConfig.calendarUnit = NSCalendar.Unit.weekOfYear
            }else if calendarIndex == 1{
                multiFieldConfig.calendarConfig.calendarUnit = NSCalendar.Unit.month
            }else if calendarIndex == 2{
                multiFieldConfig.calendarConfig.calendarUnit = NSCalendar.Unit.year
            }else if calendarIndex == 3{
                if( multiFieldConfig.viewChoice == gcViewChoice.fields){
                    multiFieldConfig.calendarConfig.calendarUnit = kCalendarUnitNone
                }
            }
            let periodIndex = periodSegment.selectedSegmentIndex
            if periodIndex == 0{
                multiFieldConfig.calendarConfig.periodType = gcPeriodType.calendar
            }else if periodIndex == 1{
                multiFieldConfig.calendarConfig.periodType = gcPeriodType.rolling
            }else if periodIndex == 2{
                multiFieldConfig.calendarConfig.periodType = gcPeriodType.toDate
            }
            let graphIndex = graphTypeSegment.selectedSegmentIndex
            if graphIndex == 0{
                multiFieldConfig.graphChoice = gcGraphChoice.cumulative
            }else{
                multiFieldConfig.graphChoice = gcGraphChoice.barGraph
            }
            self.multiFieldViewController?.setup(forFieldListConfig: multiFieldConfig)
            self.synchronizeConfigToView()
        }
    }
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
