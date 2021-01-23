//  MIT License
//
//  Created on 25/12/2018 for ConnectStats
//
//  Copyright (c) 2018 Brice Rosenzweig
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
import RZUtilsSwift
import FitFileParser



extension FitFile {
    
    func preferredMessageType() -> FitMessageType {
        let preferred = [  FitMessageType.record, FitMessageType.session, FitMessageType.file_id]
        
        for one in preferred {
            if self.messageTypes.contains(one) {
                return one
            }
        }
        return FitMessageType.file_id
    }
    
    func orderedMessageTypes() -> [FitMessageType] {
        return self.messageTypes
        /*
        let count = self.countByMessageType()
        let fields = Array( self.messageTypes)
        
        return fields.sorted {
            if let l = count[$0], let r = count[$1] {
                return l < r
            }
            return false
        }*/
    }
    
    private func orderKeysFromSample(samples : [FitFieldKey:Sample]) -> [FitFieldKey] {
        var typeOrder : [ [String ] ] = [  [], //0 FitValue.time,
                                           [], //1 FitValue.coordinate,
                                           [], //2 FitValue.name,
                                           [], //3 FitValue.valueUnit,
                                           [], //4 FitValue.value,
                                           [], //5 FitValue.invalid
        ]
        
        
        for (key,value) in samples {
            switch value.one.fitValue {
            case .time:
                typeOrder[0].append(key)
            case .coordinate:
                typeOrder[1].append(key)
            case .name:
                typeOrder[2].append(key)
            case .valueUnit:
                typeOrder[3].append(key)
            case .value:
                typeOrder[4].append(key)
            case .invalid:
                typeOrder[5].append(key)
            }
        }
        
        var rv : [FitFieldKey] = []
        for type in typeOrder {
            rv.append(contentsOf: type)
        }
        
        return rv
        
    }
    
    func orderedFieldKeys(messageType: FitMessageType) -> [FitFieldKey] {
        let samples = self.sampleValues(messageType: messageType)
        return self.orderKeysFromSample(samples: samples)
    }
    
    static func csv(messageType:FitMessageType, fitFiles:[FitFile]) -> [String] {
        var cols : [String] = ["filename"]
        var sample : [FitFieldKey:Sample] = [:]
        var rv :[String] = []
        var line : [String] = ["filename"]
        for fitFile in fitFiles {
            let oneSample = fitFile.sampleValues(messageType: messageType)
            for one in oneSample {
                sample[one.key] = one.value
            }
            let oneCols = fitFile.orderKeysFromSample(samples: oneSample)
            for col in oneCols{
                if !cols.contains(col) {
                    if let thisSample = oneSample[col]?.one {
                        cols.append(col)
                        line.append(contentsOf: thisSample.csvColumns(col: col))
                    }
                }
            }
        }
        
        rv.append( line.joined(separator: ",") )
        
        for fitFile in fitFiles {
            for message in fitFile.messages(forMessageType: messageType) {
                line = []
                let vals = message.interpretedFields()
                for col in cols {
                    if col == "filename" {
                        let filename = fitFile.sourceURL?.pathComponents.last ?? ""
                        line.append(filename)
                    }else{
                        if let val = vals[col] {
                            line.append( contentsOf: val.csvValues(ref: sample[col]?.one))
                        } else {
                            if let sampleCols = sample[col]?.one {
                                let emptyVals : [String] = sampleCols.csvColumns(col: col).map { _ in "" }
                                line.append(contentsOf: emptyVals)
                            }else{
                                line.append(col)
                            }
                        }
                    }
                }
                rv.append(line.joined(separator: ","))
            }
        }
        
        return rv
    }
    
    
    func csv(messageType:FitMessageType) -> [String] {
        let sample = self.sampleValues(messageType: messageType)
        let cols = self.orderKeysFromSample(samples: sample)
        
        var csv : [String] = []
        var line : [String] = []
        for col in cols {
            if let sample = sample[col]?.one {
                line.append(contentsOf: sample.csvColumns(col: col))
            }
        }
        csv.append(line.joined(separator: ","))
        
        var size : Int? = nil
        for message in self.messages(forMessageType: messageType) {
            line = []
            let vals = message.interpretedFields()
            for col in cols {
                if let val = vals[col] {
                    line.append(contentsOf: val.csvValues(ref: sample[col]?.one))
                }else{
                    if let sampleCols = sample[col]?.one {
                        let emptyVals : [String] = sampleCols.csvColumns(col: col).map { _ in "" }
                        line.append(contentsOf: emptyVals)
                    }else{
                        line.append(col)
                    }
                }
            }
            if size == nil {
                size = line.count
            }else{
                if size != line.count {
                    RZSLog.warning("Inconsistent csv line size for msg:\(messageType) \(line.count) != \(size ?? 0)")
                }
            }
            csv.append(line.joined(separator: ","))
        }
        return csv
    }
}
