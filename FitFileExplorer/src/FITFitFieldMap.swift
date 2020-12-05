//  MIT License
//
//  Created on 03/08/2019 for ConnectStats
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
import FitFileParser
import FitFileParserTypes
import RZUtilsSwift


class FITFitFieldMap: NSObject {
    private let map : JSON?
    private let devmap : JSON?
    
    private static var cacheMissing : [String:Int] = [:]
    
    override init() {
        let url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath("fit_map.json"))
        
        if let jsonData = try? Data(contentsOf: url),
            let json = try? JSONDecoder().decode(JSON.self, from: jsonData){
            map = json
        }else{
            map = nil
        }
        
        let devurl = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath("fit_developer.json"))
        
        if let jsonData = try? Data(contentsOf: devurl),
            let json = try? JSONDecoder().decode(JSON.self, from: jsonData){
            devmap = json
        }else{
            devmap = nil
        }
    }
    
    func messageTypeKey( messageType: FitMessageType) -> String {
        switch (messageType){
        case FIT_MESG_NUM_SESSION:
            return "FIT_MESG_NUM_SESSION"
        case FIT_MESG_NUM_LAP:
            return "FIT_MESG_NUM_LAP"
        case FIT_MESG_NUM_RECORD:
            return "FIT_MESG_NUM_RECORD"
        case FIT_MESG_NUM_LENGTH:
            return "FIT_MESG_NUM_LENGTH"
        default:
            return "FIT_MESG_NUM[\(messageType)]"
        }

    }
    
    func field( messageType : FitMessageType, fitField: String, activityType:String) -> GCField?{
        // Default unchanged
        var rv :GCField?
        let key = self.messageTypeKey(messageType: messageType)
        var mapped : String?
        
        if
            let json = self.map?[key]?.objectValue,
            let found = json[fitField]?.stringValue{
            mapped = found
        }else
        if
            let found = self.devmap?[fitField]?.stringValue{
            mapped = found
        }else
        if
            let json = self.map?[key]?.objectValue,
            let _ = json["\(fitField)_lat"]?.stringValue{
            // Field that are _lat, _lon should be ignored
            return nil;
        }
        
        if let mapped = mapped {
            // If the mapped field is unchanged, it's a known field to be ignored
            if( mapped != fitField){
                var fieldKey = mapped
                if fieldKey == "WeightedMeanCadence" {
                    switch activityType {
                    case GC_TYPE_RUNNING: fieldKey = "WeightedMeanRunCadence"
                    case GC_TYPE_WALKING: fieldKey = "WeightedMeanRunCadence"
                    case GC_TYPE_HIKING: fieldKey = "WeightedMeanRunCadence"
                    case GC_TYPE_CYCLING: fieldKey = "WeightedMeanBikeCadence"
                    case GC_TYPE_SWIMMING: fieldKey = "WeightedMeanSwimCadence"
                    default: fieldKey = mapped
                    }
                }
                if fieldKey == "MaxCadence" {
                    switch activityType {
                    case GC_TYPE_RUNNING: fieldKey = "MaxRunCadence"
                    case GC_TYPE_WALKING: fieldKey = "MaxRunCadence"
                    case GC_TYPE_HIKING: fieldKey = "MaxRunCadence"
                    case GC_TYPE_CYCLING: fieldKey = "MaxBikeCadence"
                    case GC_TYPE_SWIMMING: fieldKey = "MaxSwimCadence"
                    default: fieldKey = mapped
                    }
                    
                }
                if fieldKey == "WeightedMeanSpeed" && (activityType == GC_TYPE_SWIMMING || activityType == GC_TYPE_RUNNING) {
                    fieldKey = "WeightedMeanPace"
                }
                if fieldKey == "MaxSpeed" && (activityType == GC_TYPE_SWIMMING || activityType == GC_TYPE_RUNNING) {
                    fieldKey = "MaxPace"
                }
                rv = GCField(forKey: fieldKey, andActivityType: activityType)
            }
        }else{
            // This is a field that is not available in
            // the existing maps, update in fit_map.json or fit_developer.json via updatemap.py in sqlite/fields
            if FITFitFieldMap.cacheMissing["\(key).\(fitField)"] == nil{
                FITFitFieldMap.cacheMissing["\(key).\(fitField)"] = 1
                RZSLog.warning( "Unmapped fit field \(key).\(fitField) for \(activityType)" )
            }
        }
        
        return rv
    }
    
}
