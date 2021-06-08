//  MIT License
//
//  Created on 05/04/2021 for ConnectStats
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

class GCActivityTypeSelection : NSObject {
    @objc var activityTypeDetail : GCActivityType
    /// if true, will match on primary type only, else on the detail type
    @objc var matchPrimaryType : Bool
    
    @objc init(activityTypeDetail : GCActivityType, matchPrimaryType : Bool){
        self.activityTypeDetail = activityTypeDetail
        self.matchPrimaryType = matchPrimaryType
    }
    
    @objc init(selection : GCActivityTypeSelection){
        self.activityTypeDetail = selection.activityTypeDetail
        self.matchPrimaryType = selection.matchPrimaryType
    }
    
    @objc init(activityType: String){
        self.activityTypeDetail = GCActivityType(forKey: activityType)
        self.matchPrimaryType = true
    }
    
    @objc func selected(activities : [GCActivity]) -> [GCActivity] {
        guard let matchBlock = self.selectMatchBlock() else { return activities }
        
        return activities.filter( matchBlock )
    }
    
    @objc func selectMatchBlock() -> GCActivityMatchBlock? {
        if self.activityTypeDetail == GCActivityType.all(){
            return nil
        }
        if self.matchPrimaryType {
            return { $0.activityTypeDetail.hasSamePrimaryType(self.activityTypeDetail) }
        }else{
            return { $0.activityTypeDetail == self.activityTypeDetail }
        }
    }
 
    @objc func activityTypeList(in activities : [GCActivity] ) -> [GCActivityType] {
        var found : Set<GCActivityType> = [ GCActivityType.all() ]
        if self.matchPrimaryType {
            for activity in activities {
                found.insert(activity.activityTypeDetail.primary())
            }
        }else{
            for activity in activities {
                found.insert(activity.activityTypeDetail)
            }
        }
        return Array(found)
    }
    
    @objc override func isEqual(_ object: Any?) -> Bool {
        guard let selection = object as? GCActivityTypeSelection else { return false }
        
        return self.isEqualToSelection(selection)
    }
    
    @objc func isEqualToSelection(_ object: GCActivityTypeSelection) -> Bool {
        return self.activityTypeDetail.isEqual(to: object.activityTypeDetail) && self.matchPrimaryType == object.matchPrimaryType
    }
}
extension GCActivityTypeSelection  {
    override var description: String {
        let primaryText = self.matchPrimaryType ? "Primary" : "All"
        return "GCActivityTypeSelection(\(self.activityTypeDetail),\(primaryText))"
    }
}
