//  MIT License
//
//  Created on 16/02/2021 for ConnectStats
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

//
// aggregate by [ dynamic Date Buckets ] x [ fixed fields ]
// aggregate by [ fixed buckets All, 1w, 1m, 1y ] x [ dynamic all fields ]
// aggregate by [ dynamic activity type, fixed [ all, 1w, 1m ] ] x [ dynamic all fields ]
// aggregate by [ dynamic cluster ] x [ all fields ]
// aggregate by [ dynamic cluster, dynamic date buckets  ] x [ all fields ]
//
//   AggregatedDataHolder: fixed field or dynamic
//        collect info: Activity Type? array of activities?
//        diff over last: wow, mom, yoy
//   GroupBy: [fixed or dynamic element]
//        date bucket
//        number range
//        string(activity|other meta)/location/cluster
//   Queries:
//        indexed by date list of holders x [ fields ] (statistic list page)
//        indexed by date series of number(field) : graphs
//        indexed by field list of holder x [ bucket ] (field summary for 1w, 1m )
//        indexed by field list of holder x [ buckets ] (field summary for wow, mom )
//        indexed by cluster serie of date x field (graphs or total by location, cluster)


// GroupBy
// GroupByElement
// StatisticsElement

import Foundation

// Not yet included in connectstats only in tests
extension Array : Comparable where Element : Comparable {
    public static func < (lhs : [Element], rhs : [Element]) -> Bool {
        for (lhe, rhe) in zip(lhs, rhs) {
            if lhe < rhe {
                return true
            }else if lhe > rhe {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}

class SummaryStatistics {
    enum Stat {
        case sum
        case avg
        case cnt
        case max
        case min
        //case std
        case wavg
    }
    
    var unit : GCUnit
    
    var cnt : Int
    var sum : Double
    var max : Double
    var min : Double
    var ssq : Double

    var std : Double {
        let cnt = Double( self.cnt )
        return ((cnt*self.ssq-self.sum*self.sum)/(cnt*(cnt-1))).squareRoot()
    }
    var avg : Double? {
        guard self.cnt != 0 else { return nil }
        let cnt = Double( self.cnt )
        return self.sum / cnt
    }
    
    var timeweight : Double
    var distweight : Double
    
    var timeweightsum : Double
    var distweightsum : Double

    var wavg : Double? {
        switch self.unit.sumWeightBy {
        case .distance:
            guard self.distweight != 0.0 else { return nil }
            return self.distweightsum / self.distweight
        case .time:
            guard self.timeweight != 0.0 else { return nil }
            return self.timeweightsum / self.timeweight
        default: // cover case .count
            guard self.cnt != 0 else { return nil }
            return self.sum / Double( self.cnt)
        }
    }
    
    var timeweightavg : Double { return self.timeweightsum / self.timeweight }
    var distweightavg : Double { return self.distweightsum / self.distweight }
    
    init(numberWithUnit : GCNumberWithUnit, timeweight : Double, distweight : Double) {
        self.unit = numberWithUnit.unit.reference ?? numberWithUnit.unit
        let val =  self.unit.convert( numberWithUnit.value, from: numberWithUnit.unit )
        self.cnt = 1
        self.sum = val
        self.ssq = val * val
        
        self.max = val
        self.min = val
        
        self.timeweight = timeweight
        self.distweight = distweight
        
        self.timeweightsum = timeweight * val
        self.distweightsum = distweight * val
    }
    
    func add(numberWithUnit : GCNumberWithUnit, timeweight : Double, distweight : Double){
        let val = (self.unit == numberWithUnit.unit) ? numberWithUnit.value : numberWithUnit.convert(to: self.unit).value
        guard val.isFinite else { return }
        
        self.cnt += 1
        self.sum += val
        if val > self.max {
            self.max = val
        }
        if val < self.min {
            self.min = val
        }
        self.ssq += val * val
        self.timeweight += timeweight
        self.distweight += distweight
        self.timeweightsum += timeweight * val
        self.distweightsum += distweight * val
    }
    
    static private let mps = GCUnit.mps()
    static private let dimensionless = GCUnit.dimensionless()
    
    func numberWithUnit(stats : Stat) -> GCNumberWithUnit? {
        switch stats {
        case .avg:
            guard let avg = self.avg else { return nil }
            return GCNumberWithUnit(unit: self.unit, andValue: avg)
        case .max:
            return GCNumberWithUnit(unit: self.unit, andValue: self.max)
        case .min:
            return GCNumberWithUnit(unit: self.unit, andValue: self.min)
        case .cnt:
            return GCNumberWithUnit(unit: SummaryStatistics.dimensionless, andValue: Double(self.cnt))
        case .sum:
            return GCNumberWithUnit(unit: self.unit, andValue: self.sum)
        case .wavg:
            if self.unit.canConvert(to: SummaryStatistics.mps) {
                guard self.timeweight != 0.0 else { return nil }
                return GCNumberWithUnit(unit: SummaryStatistics.mps, andValue: self.distweight/self.timeweight).convert(to: self.unit)
            }else{
                guard let wavg = self.wavg else { return nil }
                return GCNumberWithUnit(unit: self.unit, andValue: wavg)
            }
        }
    }
}

extension SummaryStatistics : CustomStringConvertible {
    var description: String {
        let avg = self.avg != nil ? "\(self.avg!)" : "nil"
        return "Statistics(\(self.unit.abbr) cnt: \(self.cnt), sum: \(self.sum), avg: \(avg), max: \(self.max))"
    }
}

class DateBucket  {
    let interval : DateInterval
    let unit : Calendar.Component
    
    init?(date: Date,
         unit : Calendar.Component,
         calendar : Calendar,
         referenceDate : Date? = nil ) {
        self.unit = unit
        
        if let referenceDate = referenceDate {
            let components = calendar.dateComponents([unit], from: referenceDate, to: date)
            guard let diff = components.value(for: unit) else { return nil }
            guard let start = calendar.date(byAdding: unit, value: diff, to: referenceDate) else { return nil }
            if start > date {
                guard let other = calendar.date(byAdding: unit, value: -1, to: start) else { return nil }
                self.interval = DateInterval(start: other, end: start)
            }else{
                guard let other = calendar.date(byAdding: unit, value: 1, to: start) else { return nil }
                self.interval = DateInterval(start: start, end: other)
            }
        }else{
            guard let interval =  calendar.dateInterval(of: unit, for: date) else { return nil }
            self.interval = interval
        }
    }
    
    func contains( _ date : Date) -> Bool {
        return self.interval.contains(date)
    }
}

extension DateBucket : Equatable,Hashable {
    static func ==(lhs:DateBucket, rhs:DateBucket) -> Bool {
        return lhs.interval == rhs.interval && lhs.unit == rhs.unit
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(interval)
        hasher.combine(unit)
    }

}

extension DateBucket : CustomStringConvertible {
    var description: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return "DateInterval(\(self.unit): [\(formatter.string(from: self.interval.start)),\(formatter.string(from: self.interval.end))])"
    }
}

class IndexData {
    var data : [GCField:SummaryStatistics] = [:]
    let fields : [GCField]?
    
    init(fields : [GCField]?) {
        self.fields = fields
    }

    func update(activity : GCActivity){
        let fields = self.fields ?? activity.allFields()
        
        let distance = activity.numberWithUnitForField(inStoreUnit: GCField(for: .sumDistance, andActivityType: activity.activityType))?.value ?? 1.0
        let duration = activity.numberWithUnitForField(inStoreUnit: GCField(for: .sumDuration, andActivityType: activity.activityType))?.value ?? 1.0
        
        for field in fields {
            if let nu = activity.numberWithUnit(for: field) {
                guard nu.value != 0.0 || field.isZeroValid else { continue }
                
                if let stats = self.data[field] {
                    stats.add(numberWithUnit: nu, timeweight: duration, distweight: distance)
                }else{
                    self.data[field] = SummaryStatistics(numberWithUnit: nu, timeweight: duration, distweight: distance)
                }
            }
        }
    }
}

extension IndexData : CustomStringConvertible{
    var description : String {
        return "\(self.data)"
    }
    
}

enum IndexValue : Equatable,Hashable,Comparable,CustomStringConvertible  {
    case dateBucket(DateBucket)
    case string(String)
    
    var description: String {
        switch self {
        case .dateBucket(let bucket):
            return "\(bucket)"
        case .string(let string):
            return string
        }
    }
    
    static func < (lhs: IndexValue, rhs: IndexValue) -> Bool {
        switch (lhs,rhs) {
        case (.dateBucket(let lhe), .dateBucket(let rhe)):
            return lhe.interval.start < rhe.interval.start
        case (.string(let lhe), .string(let rhe)):
            return lhe < rhe
        default:
            return false
        }
    }
}



class Index  {
    let indexValues : [IndexValue]
    
    init(indexValues: [IndexValue]) {
        self.indexValues = indexValues
    }
    
    init(indexValue: IndexValue){
        self.indexValues = [ indexValue ]
    }
    
    init(dateBucket: DateBucket){
        self.indexValues = [ .dateBucket(dateBucket) ]
    }
}

extension Index : CustomStringConvertible {
    var description: String {
        return "Index(\(self.indexValues))"
    }
}

extension Index : Equatable,Hashable,Comparable {
    static func ==(lhs:Index, rhs:Index) -> Bool {
        return lhs.indexValues == rhs.indexValues
    }
    
    static func <(lhs:Index, rhs:Index) -> Bool {
        return lhs.indexValues < rhs.indexValues
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(indexValues)
    }
}

@objc class HistoryAggregator : NSObject {
    
    let activities : [GCActivity]
    let indexes : Set<Index>
    let fields : [GCField]?
    
    var groupedBy : [Index:IndexData] = [:]
    
    
    typealias GroupBy = (_: GCActivity) -> Index
    typealias IncludedIn = (_: GCActivity, _: Index) -> Bool
    let groupBy : GroupBy?
    let includedIn : IncludedIn?
    
    init(activities: [GCActivity], fields : [GCField]? = nil, groupBy: @escaping GroupBy) {
        self.activities = activities
        self.groupBy = groupBy
        self.indexes = []
        self.fields = fields
        self.includedIn = nil
    }
    
    init(activities: [GCActivity], indexes: Set<Index>, fields : [GCField]? = nil, includedIn: @escaping IncludedIn) {
        self.activities = activities
        self.fields = fields
        self.groupBy = nil
        self.includedIn = includedIn
        self.indexes = indexes
    }
    
    private func aggregateOne(activity:GCActivity,index:Index) {
        if let data = self.groupedBy[index] {
            data.update(activity: activity)
        }else{
            let data = IndexData(fields: self.fields)
            data.update(activity: activity)
            self.groupedBy[index] = data
        }
    }
    
    func aggregate() {
        if let groupBy = self.groupBy  {
            for activity in self.activities {
                let index = groupBy(activity)
                self.aggregateOne(activity: activity, index: index)
            }
        }else if let includedIn = self.includedIn {
            for activity in self.activities {
                for index in self.indexes {
                    if includedIn(activity,index) {
                        self.aggregateOne(activity: activity, index: index)
                    }
                }
            }
        }
    }
    
    func index(sortedBy: (Index,Index) -> Bool) -> [Index] {
        return [Index](self.groupedBy.keys).sorted(by: sortedBy)
    }
    
    func data(sortedBy: (Index,Index) -> Bool) -> [(Index,IndexData)] {
        var rv : [(Index,IndexData)] = []
        for index in self.index(sortedBy: sortedBy){
            if let data = self.groupedBy[index] {
                rv.append((index,data))
            }
        }
        return rv
    }
}

