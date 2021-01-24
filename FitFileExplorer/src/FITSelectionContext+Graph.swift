//  MIT License
//
//  Created on 24/01/2021 for FitFileExplorer
//
//  Copyright (c) 2021 Brice Rosenzweig
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



import Foundation
import FitFileParser

extension FITSelectionContext {
    
    func graphDataSource() -> GCSimpleGraphCachedDataSource? {
        guard let yfield = self.selectedYField else {
            return nil
        }
        let ds = GCSimpleGraphCachedDataSource()
        
        if let (dh,xUnit) = self.graphDataHolder(field: yfield, color: NSColor.systemBlue, fillColor: NSColor.systemBlue.withAlphaComponent(0.2)) {
            ds.xUnit = xUnit
            ds.title = "\(self.messageTypeDescription): \(yfield)"
            ds.add(dh)
            
            if dh.graphType == .graphLine,
               let selectedY2 = self.selectedY2Field,
               self.enableY2,
               let (dh2,_) = self.graphDataHolder(field: selectedY2, color: NSColor.systemRed, fillColor: NSColor.systemRed.withAlphaComponent(0.2)){
                if dh2.yUnit != dh.yUnit {
                    dh2.axisForSerie = 1
                }
                ds.add(dh2)
            }
        }
        return ds
    }

    func graphDataHolder( field : String, color : NSColor, fillColor : NSColor) -> (GCSimpleGraphDataHolder,GCUnit)? {
        let interp = self.interp
        
        // Don't graph if less than 2 points, not meaningful
        guard let serie = interp.statsDataSerie(messageType: self.messageType, fieldX: self.selectedXField, fieldY: field),
              var useSerie = serie.serie,
              serie.count() > 2
        else {
            return nil
        }
        
        if let displayUnit = self.displayUnit(field: field){
            if serie.unit.canConvert(to: displayUnit){
                serie.convert(to: displayUnit)
                useSerie = serie.serie
            }
        }
        
        var type: gcGraphType = .graphLine
        if( !serie.isStrictlyIncreasingByX() ){
            type = .scatterPlot
        }else if( self.messageType == .lap || self.messageType == .session){
            type = .graphStep
        }
        if let dh = GCSimpleGraphDataHolder(useSerie, type: type, color: color, andUnit: serie.unit) {
            if( type == gcGraphType.scatterPlot){
                // instead of timestamp should be line field
                if let gradientSerie = interp.statsDataSerie(messageType: self.messageType, fieldX: "timestamp", fieldY: field) {
                    dh.gradientDataSerie = gradientSerie.serie
                    if let gradientFunction = GCStatsScaledFunction(serie: gradientSerie.serie){
                        gradientFunction.scale_x = true
                        dh.gradientFunction = gradientFunction
                        dh.gradientColors = GCViewGradientColors.gradientColorsRainbow16()
                    }
                }
            }else if( type == gcGraphType.graphStep){
                dh.color = color.withAlphaComponent(0.5)
            }
            
            let idx = self.messageIndex
            let useSerie = useSerie
            let cnt = useSerie.count()
            if idx > 0 && idx < cnt,
               let point = useSerie[UInt(idx)]{
                dh.highlightCurrent = true;
                dh.currentPoint = NSPointToCGPoint(NSMakePoint(CGFloat(point.x_data),CGFloat(point.y_data)))
            }
            
            dh.fillColorForSerie = fillColor
            return (dh,serie.xUnit)
        }
        return nil
    }
}
