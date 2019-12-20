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
import RZFitFile
import RZFitFileTypes

extension RZFitFile {
    
    convenience init(fitFile file: FITFitFile){
        var messages :[RZFitMessage] = []
        
        for one in file.allMessageFields() {
            if let field = RZFitMessage(with: one) {
                messages.append(field)
            }
        }
        
        self.init(messages: messages)
    }
    
    func preferredMessageType() -> RZFitMessageType {
        let preferred = [ FIT_MESG_NUM_SESSION, FIT_MESG_NUM_RECORD, FIT_MESG_NUM_FILE_ID]
        for one in preferred {
            if self.messageTypes.contains(one) {
                return one
            }
        }
        return FIT_MESG_NUM_FILE_ID
    }
    
    func orderedMessageTypes() -> [RZFitMessageType] {
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
    
    private func orderKeysFromSample(samples : [RZFitFieldKey:Sample]) -> [RZFitFieldKey] {
        let typeOrder = [  RZFitFieldValue.ValueType.time,
                           RZFitFieldValue.ValueType.coordinate,
                           RZFitFieldValue.ValueType.name,
                           RZFitFieldValue.ValueType.valueUnit,
                           RZFitFieldValue.ValueType.value,
                           RZFitFieldValue.ValueType.invalid
        ]
        
        var byType : [RZFitFieldValue.ValueType:[RZFitFieldKey]] = [:]
        for type in typeOrder{
            byType[type] = []
        }
        
        let all = Array(samples.keys)
        
        for key in all {
            if let val = samples[key] {
                byType[val.one.type]?.append(key)
            }else{
                byType[RZFitFieldValue.ValueType.invalid]?.append(key)
            }
        }
        
        var rv : [RZFitFieldKey] = []
        for type in typeOrder {
            if let keys = byType[type] {
                let orderedKeys = keys.sorted {
                    if let l = samples[$0], let r = samples[$1] {
                        return r.count < l.count
                    }
                    return false
                }
                rv.append(contentsOf: orderedKeys)
            }
        }
        
        return rv
        
    }
    
    func orderedFieldKeys(messageType: RZFitMessageType) -> [RZFitFieldKey] {
        let samples = self.sampleValues(messageType: messageType)
        return self.orderKeysFromSample(samples: samples)
    }
    
    static func csv(messageType:RZFitMessageType, fitFiles:[RZFitFile]) -> [String] {
        var cols : [String] = ["filename"]
        var sample : [RZFitFieldKey:Sample] = [:]
        var rv :[String] = []
        var line : [String] = []
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
    
    
    func csv(messageType:RZFitMessageType) -> [String] {
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
