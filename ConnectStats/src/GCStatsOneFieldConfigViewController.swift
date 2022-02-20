//  MIT License
//
//  Created on 29/01/2022 for ConnectStats
//
//  Copyright (c) 2022 Brice Rosenzweig
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

class GCStatsOneFieldConfigViewController: UIViewController {
    @IBOutlet var calendarAggregationSegment: UISegmentedControl!
    @IBOutlet var viewConfigSegment: UISegmentedControl!
    @IBOutlet var periodSegment: UISegmentedControl!
    @IBOutlet var secondGraphSegment: UISegmentedControl!
    @IBOutlet var graphTypeSegment: UISegmentedControl!
    @IBOutlet var xFieldLabel: UILabel!
    
    
    @IBOutlet var previewTableView: UITableView!
    
    @objc var oneFieldViewController : GCStatsOneFieldViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.oneFieldViewController?.updateCallback = {
            self.previewTableView.reloadData()
        }
        self.synchronizeConfigToView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.viewWillAppear(animated)
        self.oneFieldViewController?.updateCallback = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.previewTableView.dataSource = self.oneFieldViewController
        self.previewTableView.delegate = self.oneFieldViewController

        // Do any additional setup after loading the view.
    }
    
    @IBAction func done(_ sender: Any) {
    
        self.oneFieldViewController?.notifyCallBack(self, info: RZDependencyInfo())
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        self.synchronizeViewToConfig(segment: sender)
    }
    
    func synchronizeConfigToView() {
        if let oneFieldConfig : GCStatsOneFieldConfig = self.oneFieldViewController?.oneFieldConfig {
            viewConfigSegment.isEnabled = true
            switch oneFieldConfig.multiFieldConfig.viewConfig {
            case gcStatsViewConfig.all:
                viewConfigSegment.selectedSegmentIndex = 0
            case gcStatsViewConfig.last3M:
                viewConfigSegment.selectedSegmentIndex = 1
            case gcStatsViewConfig.last6M:
                viewConfigSegment.selectedSegmentIndex = 2
            case gcStatsViewConfig.last1Y:
                viewConfigSegment.selectedSegmentIndex = 3
            default:
                viewConfigSegment.isEnabled = true
            }
            
            
            switch  oneFieldConfig.calendarConfig.calendarUnit {
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
                if oneFieldConfig.calendarConfig.calendarUnit == kCalendarUnitNone {
                    calendarAggregationSegment.selectedSegmentIndex = 3
                }else{
                    calendarAggregationSegment.selectedSegmentIndex = 0
                }
            }
            switch oneFieldConfig.calendarConfig.periodType {
            case gcPeriodType.calendar:
                periodSegment.selectedSegmentIndex = 0;
            case gcPeriodType.rolling:
                periodSegment.selectedSegmentIndex = 1;
            case gcPeriodType.toDate:
                periodSegment.selectedSegmentIndex = 2;
            default:
                periodSegment.selectedSegmentIndex = 0;
            }
            
            switch oneFieldConfig.secondGraphChoice {
            case gcOneFieldSecondGraph.history:
                secondGraphSegment.selectedSegmentIndex = 0
                graphTypeSegment.isEnabled = true
            case gcOneFieldSecondGraph.performance:
                secondGraphSegment.selectedSegmentIndex = 1
                graphTypeSegment.isEnabled = false
            case gcOneFieldSecondGraph.histogram:
                secondGraphSegment.selectedSegmentIndex = 2
                graphTypeSegment.isEnabled = false
            default:
                secondGraphSegment.selectedSegmentIndex = 0
                graphTypeSegment.isEnabled = true
            }
            
            switch oneFieldConfig.graphChoice {
            case gcGraphChoice.cumulative:
                graphTypeSegment.selectedSegmentIndex = 0;
            default:
                graphTypeSegment.selectedSegmentIndex = 1;
            }
            
            if let xlabel = oneFieldConfig.x_field.displayName() {
                self.xFieldLabel.text = "X: \(xlabel)"
            }else{
                self.xFieldLabel.text = ""
            }
        }
    }
    
    func synchronizeViewToConfig(segment : UISegmentedControl) {
        if let currentOneFieldConfig : GCStatsOneFieldConfig = self.oneFieldViewController?.oneFieldConfig,
            let oneFieldConfig = GCStatsOneFieldConfig.fieldListConfig(from: currentOneFieldConfig) {
            let filterIndex = self.viewConfigSegment.selectedSegmentIndex
            if filterIndex == 0 {
                oneFieldConfig.multiFieldConfig.viewConfig = gcStatsViewConfig.all
            }else if filterIndex == 1{
                oneFieldConfig.multiFieldConfig.viewConfig = gcStatsViewConfig.last3M
            }else if filterIndex == 2{
                oneFieldConfig.multiFieldConfig.viewConfig = gcStatsViewConfig.last6M
            }else if filterIndex == 3{
                oneFieldConfig.multiFieldConfig.viewConfig = gcStatsViewConfig.last1Y
            }
            let calendarIndex = calendarAggregationSegment.selectedSegmentIndex
            if calendarIndex == 0{
                oneFieldConfig.calendarConfig.calendarUnit = NSCalendar.Unit.weekOfYear
            }else if calendarIndex == 1{
                oneFieldConfig.calendarConfig.calendarUnit = NSCalendar.Unit.month
                if( oneFieldConfig.multiFieldConfig.viewConfig == gcStatsViewConfig.last3M ){
                    oneFieldConfig.multiFieldConfig.viewConfig = gcStatsViewConfig.last6M;
                }
            }else if calendarIndex == 2{
                oneFieldConfig.calendarConfig.calendarUnit = NSCalendar.Unit.year
                oneFieldConfig.multiFieldConfig.viewConfig = gcStatsViewConfig.all
            }
            
            let periodIndex = periodSegment.selectedSegmentIndex
            if periodIndex == 0{
                oneFieldConfig.calendarConfig.periodType = gcPeriodType.calendar
            }else if periodIndex == 1{
                oneFieldConfig.calendarConfig.periodType = gcPeriodType.rolling
            }else if periodIndex == 2{
                oneFieldConfig.calendarConfig.periodType = gcPeriodType.toDate
            }
            
            let secondGraph = secondGraphSegment.selectedSegmentIndex
            if secondGraph == 0{
                oneFieldConfig.secondGraphChoice = .history
            }else if secondGraph == 1{
                oneFieldConfig.secondGraphChoice = .performance
            }else if secondGraph == 2{
                oneFieldConfig.secondGraphChoice = .histogram
            }
            
            let graphIndex = graphTypeSegment.selectedSegmentIndex
            if graphIndex == 0{
                oneFieldConfig.graphChoice = gcGraphChoice.cumulative
            }else{
                oneFieldConfig.graphChoice = gcGraphChoice.barGraph
            }
            self.oneFieldViewController?.setup(forFieldListConfig: oneFieldConfig)
            self.synchronizeConfigToView()
        }
    }

}
