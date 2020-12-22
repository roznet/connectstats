//
//  FITGraphViewController.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 12/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Cocoa
import FitFileParser


class FITGraphViewController: NSViewController {

    @IBOutlet weak var graphCustomView: NSView!
    
    var selectionContextViewController : FITSelectionContextViewController?
    
    var graphView : GCSimpleGraphView?
    
    var selectionContext : FITSelectionContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.graphView = GCSimpleGraphView(frame: self.graphCustomView.frame)
        self.graphCustomView.addSubview(self.graphView!)
        
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        let newFrame = NSMakeRect(0.0, 0.0, self.graphCustomView.frame.width, self.graphCustomView.frame.height)
        self.graphView?.frame = newFrame
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedGraphContext"{
            if let scv = segue.destinationController as? FITSelectionContextViewController{
                self.selectionContextViewController = scv
                self.selectionContextViewController?.graphViewController = self
            }
        }
    }
    
    // Called from FITSPlitViewController.detailSelectionChanged upon notification of table change
    func updateDataSource( selectionContext :FITSelectionContext ){
        
        if let svc = self.selectionContextViewController {
            svc.update(selectionContext: selectionContext)
        }
        let interp = selectionContext.interp
        if let field = selectionContext.selectedYField {
            /*
            if selectionContext.messageType == FIT_MESG_NUM_RECORD {
                let equivalent = interp.mapFields(from: [field], to: selectionContext.fitFile.fieldKeys(messageType: FIT_MESG_NUM_LAP))
                RZSLog.info("Equivalent \(field)=\(equivalent)")
            }*/
            let ds = GCSimpleGraphCachedDataSource()
            if let serie = interp.statsDataSerie(messageType: selectionContext.messageType, fieldX: selectionContext.selectedXField, fieldY: field) {
                // Don't graph if less than 2 points, not meaningful
                if serie.count() > 2 {
                    var useSerie = serie.serie
                    if let selectionContext = self.selectionContext {
                        if serie.unit.canConvert(to: selectionContext.speedUnit){
                            serie.convert(to: selectionContext.speedUnit)
                            useSerie = serie.serie
                        }
                    }
                    
                    var type :gcGraphType =  gcGraphType.graphLine
                    if( !serie.isStrictlyIncreasingByX() ){
                        type = gcGraphType.scatterPlot
                    }else if( selectionContext.messageType == FitMessageType.lap && selectionContext.selectedXField == "start_time"){
                        type = gcGraphType.graphStep
                    }
                    let dh = GCSimpleGraphDataHolder(useSerie, type: type, color: NSColor.blue, andUnit: serie.unit)
                    ds.xUnit = serie.xUnit
                    
                    if( type == gcGraphType.scatterPlot){
                        // instead of timestamp should be line field
                        if let gradientSerie = interp.statsDataSerie(messageType: selectionContext.messageType, fieldX: "timestamp", fieldY: field) {
                            dh?.gradientDataSerie = gradientSerie.serie
                            if let gradientFunction = GCStatsScaledFunction(serie: gradientSerie.serie){
                                gradientFunction.scale_x = true
                                dh?.gradientFunction = gradientFunction
                                dh?.gradientColors = GCViewGradientColors.gradientColorsRainbow16()
                            }
                        }
                    }else if( type == gcGraphType.graphStep){
                        dh?.color = NSColor(deviceRed: 0.0, green: 0.0, blue: 0.9, alpha: 0.5)
                    }
                    
                    if let idx = self.selectionContext?.messageIndex,
                        let useSerie = useSerie {
                        let cnt = useSerie.count()
                        if idx < cnt {
                            dh?.highlightCurrent = true;
                            dh?.currentPoint = NSPointToCGPoint(NSMakePoint(CGFloat(useSerie.dataPoint(at: UInt(idx)).x_data), CGFloat(useSerie.dataPoint(at: UInt(idx)).y_data)))
                        }
                    }
                    
                    dh?.fillColorForSerie = NSColor(deviceRed: 0.0, green: 0.0, blue: 0.8, alpha: 0.2)
                    ds.title = "\(selectionContext.messageTypeDescription): \(field)"
                    ds.add(dh)
                    
                    if( type == gcGraphType.graphLine){
                        if let selectedY2 = selectionContext.selectedY2Field, selectionContext.enableY2 {
                            if let serie2 = interp.statsDataSerie(messageType: selectionContext.messageType, fieldX: selectionContext.selectedXField, fieldY: selectedY2) {
                                var useSerie2 = serie2.serie
                                if let selectionContext = self.selectionContext {
                                    if serie2.unit.canConvert(to: selectionContext.speedUnit){
                                        serie2.convert(to: selectionContext.speedUnit)
                                        useSerie2 = serie2.serie
                                    }
                                }
                                if( selectedY2 == field ){
                                    if let raw = useSerie2 {
                                        useSerie2 = raw.filledSerie(forUnit: 5.0)
                                    }
                                }
                                
                                let dh2 = GCSimpleGraphDataHolder(useSerie2, type: gcGraphType.graphLine, color: NSColor.red, andUnit: serie2.unit)
                                if( !serie2.unit.canConvert(to: serie.unit)){
                                    dh2?.axisForSerie = 1
                                }
                                dh2?.fillColorForSerie = NSColor(deviceRed: 0.5, green: 0.0, blue: 0.0, alpha: 0.2)
                                ds.add(dh2)
                            }
                        }
                    }
                    self.graphView?.dataSource = ds
                    self.graphView?.displayConfig = ds
                    self.graphView?.needsDisplay = true
                }
            }
        }
    }
    
    func updateWith(selectionContext : FITSelectionContext){
        self.selectionContext = selectionContext
        self.updateDataSource(selectionContext: selectionContext)
    }
    
}
