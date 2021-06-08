//  MIT License
//
//  Created on 22/04/2021 for ConnectStats
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



import UIKit
import RZUtilsSwift

class GCActivityUpdateRecordTracker : NSObject, GCActivityUpdateRecordProtocol {
    let verbose = false
    
    var changes : Int = 0
    var additions : Int = 0
    
    func record(for act: GCActivity, newMeta value: GCActivityMetaValue) {
        if verbose {
            RZSLog.info("\(act.activityId) new \(value)")
        }
        changes+=1
    }
    
    func record(for act: GCActivity, changedMeta valuefrom: GCActivityMetaValue, to valueto: GCActivityMetaValue) {
        if verbose {
            RZSLog.info("\(act.activityId) changed \(valuefrom) to \(valueto)")
        }
        additions+=1
    }
    
    
    @objc func record(for act: GCActivity, newValue value: GCActivitySummaryValue) {
        if verbose {
            RZSLog.info("\(act.activityId) new \(value)")
        }
        additions+=1
    }
    
    @objc func record(for act: GCActivity, changedValue valuefrom: GCActivitySummaryValue, to valueto: GCActivitySummaryValue) {
        if verbose {
            RZSLog.info("\(act.activityId) changed \(valuefrom) to \(valueto)")
        }
        changes+=1
    }
    
    @objc func record(for act: GCActivity, changedAttribute attr: String, from: String, to: String) {
        if verbose {
            RZSLog.info("\(act.activityId) changed \(attr) from \(from) to \(to)")
        }
        changes+=1
    }
    
}
