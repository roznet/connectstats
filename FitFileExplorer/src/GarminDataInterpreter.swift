//  MIT License
//
//  Created on 06/01/2019 for FitFileExplorer
//
//  Copyright (c) 2019 Brice Rosenzweig
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
import GenericJSON
import RZUtilsCore

class GarminDataInterpreter {
    let json : [String:JSON]
    private var unkown : [String:JSON] = [:]
    
    let dateRegexp : NSRegularExpression
    
    enum Style {
        case dto, nonDto
    }
    
    
    init?(json:[String:JSON]){
        let reg = try? NSRegularExpression(pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}", options: NSRegularExpression.Options.caseInsensitive)
        if let reg = reg {
            var keep : [String:JSON] = [:]
            for (key,val) in json {
                if !val.isNull {
                    keep[key] = val
                }
            }
            self.json = keep
            self.dateRegexp = reg
            
        }else{
            return nil
        }
    }

    private func summary() -> (summary:[String:JSON], dto:Bool) {
        var rv : (summary:[String:JSON], dto:Bool) = ( self.json, false)
        
        if let dto = self.json["summaryDTO"],
            let dtoInfo = dto.objectValue{
            rv.summary = dtoInfo
            rv.dto = true;
        }

        return rv
    }
    
    func activityType(types:GCActivityTypes? = nil) -> GCActivityType {
        var rv = GCActivityType.other()
        let activityTypes = types ?? FITAppGlobal.shared.activityTypes
        var info = self.json["activityType"]?.objectValue
        
        if info == nil {
            info = self.json["activityTypeDTO"]?.objectValue
        }
        
        if let typedata = info {
            if let foundkey = typedata["typeKey"]?.stringValue{
                rv = activityTypes.activityType(forKey: foundkey)
            }else if let foundkey = typedata["type"]?.stringValue{
                rv = activityTypes.activityType(forKey: foundkey)
            }
        }
        return rv
    }
    
    func numbers() -> [String:GCNumberWithUnit] {
        var rv : [String:GCNumberWithUnit]  = [:]

        let summary = self.summary()
        
        let input = summary.summary
        let definitions = summary.dto ? GarminDataFieldDefinitions.dtoDefinition : GarminDataFieldDefinitions.nonDtoDefinition
        
        for (key,val) in input {
            if let num = val.doubleValue {
                if let def = definitions[key] {
                    rv[def.field] = GCNumberWithUnit(name: def.unit, andValue: num)
                }else{
                    // keep sample of what is not known
                    self.unkown[ key ] = val
                }
            }
        }
        return rv
    }
    
    func dates() -> [String:Date] {
        var rv : [String:Date] = [:]
        
        let input = self.summary().summary
        
        for (key,val) in input {
            if let str = val.stringValue {
                if self.dateRegexp.firstMatch(in: str, options: [], range: NSMakeRange(0, str.count)) != nil {
                    if let date = NSDate(forGarminModernString: str) {
                        rv[key] = date as Date
                    }
                }
            }
        }
        
        return rv
    }
    
    func labels() -> [String:String] {
        var rv : [String:String] = [:]
        
        var lookat = [self.json]
        if let meta = self.json["metadataDTO"]?.objectValue {
            lookat.append(meta)
        }
        
        for info in lookat {
            for (key,val) in info {
                if let str = val.stringValue {
                    if self.dateRegexp.firstMatch(in: str, options: [], range: NSMakeRange(0, str.count)) == nil{
                        rv[key] = str
                    }
                }
            }
        }
        
        // Special handling of eventType
        var ev = self.json["eventType"]?.objectValue
        if ev == nil{
            ev = self.json["eventTypeDTO"]?.objectValue
        }
        if let ev = ev, let typekey = ev["typeKey"]?.stringValue {
            rv["eventType"] = typekey
        }
        
        return rv
    }
    
    func coordinates() -> [String:CLLocationCoordinate2D] {
        var rv : [String:CLLocationCoordinate2D] = [:]
        
        let input = self.summary().summary
        
        for (key,val) in input {
            if key.hasSuffix("Latitude"),
                let lat = val.doubleValue{
                let longkey = key.replacingOccurrences(of: "Latitude", with: "Longitude")
                if let lonval = input[longkey]?.doubleValue {
                    let coorkey = key.replacingOccurrences(of: "Latitude", with: "")
                    rv[coorkey] = CLLocationCoordinate2DMake(lat, lonval)
                }
            }
        }
        return rv
    }
    
}
