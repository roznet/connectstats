//  MIT License
//
//  Created on 16/02/2021 for ConnectStatsXCTests
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



import XCTest
@testable import ConnectStats
import RZUtils


extension GCNumberWithUnit {
    func isAlmostEqual(to other : GCNumberWithUnit) -> Bool {
        if self.unit == other.unit {
            let scale = max(abs(value), abs(other.value), .leastNormalMagnitude)
            let tolerance = Double.ulpOfOne.squareRoot()
            return abs(value-other.value) < scale*tolerance
        }else{
            return self.isAlmostEqual(to: other.convert(to: self.unit))
        }
    }
    
    func assertEqual(to other : GCNumberWithUnit, message : String){
        if self.unit == other.unit {
            let scale = Swift.max(abs(value), abs(other.value), .leastNormalMagnitude)
            let tolerance = Double.ulpOfOne.squareRoot()
            XCTAssertEqual(value, other.value, accuracy: tolerance*scale, "unit: \(self.unit) \(message)")
            
        }else{
            self.assertEqual(to: other.convert(to: self.unit), message:message)
        }
    }
}

extension SummaryStatistics {
    func compare(field : GCField, dataHolder: GCHistoryAggregatedDataHolder, message : String) {
        XCTAssertTrue(dataHolder.hasField(field), message)
        
        guard let unit = field.unit() else { XCTAssertTrue(false); return }
        
        XCTAssertEqual( dataHolder.number(withUnit: field, statType: .cnt),
                        self.numberWithUnit(stats: .cnt),
                        "\(field) cnt \(message)" )
        for (newstat,oldstat) in [ (SummaryStatistics.Stat.sum, gcAggregatedType.sum),
                                   (SummaryStatistics.Stat.max, gcAggregatedType.max),
                                   (SummaryStatistics.Stat.avg, gcAggregatedType.avg),
                                   (SummaryStatistics.Stat.wavg , gcAggregatedType.wvg)
        ] {
            guard let newnu = self.numberWithUnit(stats: newstat)?.convert(to: unit) else { XCTAssertTrue(false); continue }
            guard var oldnu = dataHolder.number(withUnit: field, statType: oldstat)?.convert(to: unit) else { XCTAssertTrue(false); continue }

            // Special case weighted value for speed in old comes from preferred number
            if oldstat == .wvg && field.fieldFlag == .weightedMeanSpeed {
                guard let speednu = dataHolder.preferredNumber(withUnit: field) else { XCTAssertTrue(false); return }
                oldnu = speednu
            }else{
                // dont check weighted for other
                continue
            }
            
            newnu.assertEqual(to: oldnu, message: "\(field) \(newstat) \(message)")
        }
    }
    
    func compare(field : GCField, summaryHolder : GCHistoryFieldDataHolder, stat : gcHistoryStats, message : String){
        let cnt = Int(summaryHolder.count(withUnit: stat).value)
        XCTAssertEqual(self.cnt, cnt, "\(field) \(stat) \(message)")
        if field.canSum {
            guard let nu = self.numberWithUnit(stats: .sum) else { XCTAssertTrue(false); return }
            let oldnu = summaryHolder.sum(withUnit: stat)
            nu.assertEqual(to: oldnu, message: "\(field) \(stat) \(message)")
        }else{
            // build number manually with wavg other wise would speed would not match
            guard let wavg = self.wavg else { XCTAssertTrue(false); return }
            guard let oldnu = summaryHolder.weightedAverage(withUnit: stat) else { XCTAssertTrue(false); return }
            let nu = GCNumberWithUnit(unit: self.unit, andValue: wavg)
            nu.assertEqual(to: oldnu, message: "\(field) \(stat) \(message)")
            
        }
    }
}

extension DateBucket {
    var historyStat : gcHistoryStats {
        switch self.unit {
        case .month:
            return .month
        case .weekOfYear:
            return .week
        case .year:
            return .year
        default:
            return .all
        }
    }
}
class GCTestAggregatedStats: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        
    }

    func testBucketTests() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let calendar = GCAppGlobal.calculationCalendar()
        
        let referenceDateComponents = DateComponents(year: 2021, month: 2, day: 16 )
        guard let referenceDate = calendar.date(from: referenceDateComponents) else { XCTAssertTrue(false); return }
        
        for period : Calendar.Component in [ .weekOfYear, .month, .year] {
            let oldbucketer = GCStatsDateBuckets()
            oldbucketer.calendar = calendar
            oldbucketer.refOrNil = nil
            let oldbucketerrel = GCStatsDateBuckets()
            oldbucketerrel.calendar = calendar
            oldbucketerrel.refOrNil = referenceDate
            switch period {
            case .weekOfYear:
                oldbucketer.calendarUnit = NSCalendar.Unit.weekOfYear
                oldbucketerrel.calendarUnit = NSCalendar.Unit.weekOfYear
            case .month:
                oldbucketer.calendarUnit = NSCalendar.Unit.month
                oldbucketerrel.calendarUnit = NSCalendar.Unit.month
            default:
                oldbucketer.calendarUnit = NSCalendar.Unit.year
                oldbucketerrel.calendarUnit = NSCalendar.Unit.year
            }

            let testDateComponents = DateComponents(year: 2021, month: 2, day: 12, hour: 11 )
            guard var runningDate = calendar.date(from: testDateComponents) else { XCTAssertTrue(false); return }

            for diff in 0..<365 {
                guard let testDate = calendar.date(byAdding: .day, value: -1*diff, to: runningDate) else { XCTAssertTrue(false); return }
                runningDate = testDate
                guard let bucket = DateBucket(date: testDate, unit: period, calendar: calendar, referenceDate: nil) else { XCTAssertTrue(false); return }
                oldbucketer.bucket(testDate)
                XCTAssertEqual(bucket.interval.start, oldbucketer.bucketStart)
                XCTAssertEqual(bucket.interval.end, oldbucketer.bucketEnd)
                
                guard let bucketref = DateBucket(date: testDate, unit: period, calendar: calendar, referenceDate: referenceDate) else { XCTAssertTrue(false); return }
                oldbucketerrel.bucket(testDate)
                XCTAssertEqual(bucketref.interval.start, oldbucketerrel.bucketStart)
                XCTAssertEqual(bucketref.interval.end, oldbucketerrel.bucketEnd)
            }
        }
    }
    
    
    func activitiesForStatsTest(n : Int = Int.max, activityType : String = GC_TYPE_ALL, focus : Bool = false) -> [GCActivity] {
        let calendar = GCAppGlobal.calculationCalendar()
        guard let db = GCTestsSamples.sampleActivityDatabase("activities_stats.db") else { XCTAssertTrue(false); return [] }
        let organizer = GCActivitiesOrganizer(testModeWithDb: db)
        
        let all = organizer.activities()
        
        var focusbucket : DateBucket? = nil
        
        if focus {
            let datecomponents = DateComponents(calendar: calendar, year: 2012, month: 2, day: 2)
            guard let date = calendar.date(from: datecomponents) else { XCTAssertTrue(false); return [] }
            focusbucket = DateBucket(date: date, unit: .month, calendar: Calendar.current)
        }
        
        var activities : [GCActivity] = []
        for activity in all {
            // Note activity with an invalid Infinite speed will be handled
            // differently between new code and old code
            //    new code: skip the activity for speed calculation as it is +inf, because the totaldistance/totalduration is kept with the speed stats.
            //    old code: include activity duration in the final speed calculation of "total distance" / "total duration" because it uses the distance/duration stats
            // example such activity: activity.activityId == "153769391"
            if activity.summaryFieldValue(inStoreUnit: .weightedMeanSpeed).isInfinite {
                continue
            }
            if let focusbucket = focusbucket {
                guard focusbucket.contains(activity.date) else { continue }
            }
            
            if activityType == GC_TYPE_ALL || activity.activityType == activityType {
                activities.append(activity)
            }
            if n != Int.max && activities.count == n{
                break
            }
        }
        
        return activities
    }
    
    func testFieldSummary() {
        let activityType = GC_TYPE_RUNNING
        let calendar = GCAppGlobal.calculationCalendar()
        let activities = self.activitiesForStatsTest(n:10,activityType: activityType)

        let performance = RZPerformance()
        performance.reset()

        let fieldsdata = GCHistoryFieldSummaryStats.fieldStats(withActivities: activities, matching: nil, referenceDate: nil, ignoreMode: gcIgnoreMode.activityFocus)
        
        if let basedate = activities.first?.date {
            let indexes : Set<Index> = [
                Index(dateBucket: DateBucket(date: basedate, unit: .weekOfYear, calendar: calendar)!),
                Index(dateBucket: DateBucket(date: basedate, unit: .month, calendar: calendar)!),
                Index(dateBucket: DateBucket(date: basedate, unit: .year, calendar: calendar)!)
            ]
            let aggfieldstats = HistoryAggregator(activities: activities, indexes:indexes) {
                act, index in
                guard let value = index.indexValues.first else { return false }
                if case let .dateBucket(bucket) = value {
                    return bucket.contains( act.date )
                }
                return false
            }
            aggfieldstats.aggregate()
            for (index,data) in aggfieldstats.data(sortedBy: >) {
                if case .dateBucket(let bucket) = index.indexValues.first {
                    let stat = bucket.historyStat
                    
                    for (k,v) in data.data {
                        let summary = fieldsdata.data(for: k)
                        v.compare(field: k, summaryHolder: summary, stat: stat, message: "\(bucket)")
                    }
                }else{
                    XCTAssertTrue(false)
                }
            }
        }
    }
    
    func testStatsBycountry(){
        let activityType = GC_TYPE_RUNNING
        let calendar = GCAppGlobal.calculationCalendar()
        let activities = self.activitiesForStatsTest(n:Int.max,activityType: activityType)
        let performance = RZPerformance()
        performance.reset()

        let aggtypestats = HistoryAggregator(activities: activities, fields: GCHistoryAggregatedActivityStats.defaultFields(forActivityType: activityType)) {
            act in
            let bucket = DateBucket(date: act.date, unit: .year, calendar: calendar)
            let rv = [ IndexValue.dateBucket(bucket!), IndexValue.string(act.country)]
            return Index(indexValues: rv )
        }
        aggtypestats.aggregate()

        var stats : [String:GCHistoryAggregatedActivityStats] = [:]
        
        for country in ["GB", "US", "FR"]{
            var activitiescountry : [GCActivity] = []
            
            for activity in activities {
                if activity.country == country {
                    activitiescountry.append(activity)
                }
            }
            let statscountry = GCHistoryAggregatedActivityStats(forActivityType: GC_TYPE_RUNNING)
            statscountry.activities = activitiescountry
            statscountry.aggregate(.year, referenceDate: nil, ignoreMode: gcIgnoreMode.activityFocus)
            
            stats[country] = statscountry
        }
        
        for (index,data) in aggtypestats.data(sortedBy: <){
            XCTAssertTrue(index.indexValues.count == 2)
            
            let countryvalue = index.indexValues[1]
            let bucketvalue = index.indexValues[0]
            
            if case let .dateBucket(indexBucket) = bucketvalue,
               case let .string(country) = countryvalue {
                if country == "GB" || country == "US" || stats[country] != nil {
                    guard let statscountry = stats[country] else { XCTAssertTrue(false); continue }
                    guard let old = statscountry.data(for: indexBucket.interval.start) else { XCTAssertTrue(false); continue }
                    var done = 0
                    for (k,v) in data.data {
                        let field = k
                        if old.hasField(field) && field.unit() != nil {
                            done += 1
                            v.compare(field: field, dataHolder: old, message: "\(country) \(indexBucket) year aggregate")
                        }
                    }
                    XCTAssertGreaterThan(done, 0, "Found some valid tests")
                }
            }
        }
    }
    
    func testMultiLevelAggregatedStats() {
        let activityType = GC_TYPE_ALL
        let calendar = GCAppGlobal.calculationCalendar()
        let activities = self.activitiesForStatsTest(n:10,activityType: activityType)
        let performance = RZPerformance()
        performance.reset()

        let aggtypestats = HistoryAggregator(activities: activities, fields: GCHistoryAggregatedActivityStats.defaultFields(forActivityType: activityType)) {
            act in
            let bucket = DateBucket(date: act.date, unit: .month, calendar: calendar)
            let rv = [IndexValue.string(act.activityType), IndexValue.dateBucket(bucket!)]
            return Index(indexValues: rv )
        }
        aggtypestats.aggregate()

        let statsrun = GCHistoryAggregatedActivityStats(forActivityType: GC_TYPE_RUNNING)
        statsrun.activities = activities
        statsrun.aggregate(.month, referenceDate: nil, ignoreMode: gcIgnoreMode.activityFocus)

        let statscycle = GCHistoryAggregatedActivityStats(forActivityType: GC_TYPE_CYCLING)
        statscycle.activities = activities
        statscycle.aggregate(.month, referenceDate: nil, ignoreMode: gcIgnoreMode.activityFocus)

        for (index,data) in aggtypestats.data(sortedBy: <){
            XCTAssertTrue(index.indexValues.count == 2)
            
            let atypevalue = index.indexValues[0]
            let bucketvalue = index.indexValues[1]
            
            if case let .dateBucket(indexBucket) = bucketvalue,
               case let .string(indexActivityType) = atypevalue {
                guard indexActivityType == GC_TYPE_CYCLING || indexActivityType == GC_TYPE_RUNNING else { continue }
                let stats = GC_TYPE_RUNNING == indexActivityType ? statsrun : statscycle
                
                guard let old = stats.data(for: indexBucket.interval.start) else { XCTAssertTrue(false); continue }
                var done = 0
                for (k,v) in data.data {
                    let field = k.correspondingField(forActivityType: indexActivityType)
                    if let field = field, old.hasField(field) && field.unit() != nil {
                        done += 1
                        v.compare(field: field, dataHolder: old, message: "\(indexBucket) monthly aggregate")
                    }
                }
                XCTAssertGreaterThan(done, 0, "Found some valid tests")

            }
        }
    }
    
    func testAggregatedStats() {
        let activityType = GC_TYPE_RUNNING
        let calendar = GCAppGlobal.calculationCalendar()
        let activities = self.activitiesForStatsTest(n:Int.max,activityType: activityType)

        let performance = RZPerformance()
        performance.reset()
        let stats = GCHistoryAggregatedActivityStats(forActivityType: activityType)
        stats.activities = activities
        
        stats.aggregate(.month, referenceDate: nil, ignoreMode: gcIgnoreMode.activityFocus)
                        
        let aggstats = HistoryAggregator(activities: activities, fields: GCHistoryAggregatedActivityStats.defaultFields(forActivityType: activityType)) {
            act in
            let bucket = DateBucket(date: act.date, unit: .month, calendar: calendar)
            let rv = IndexValue.dateBucket(bucket!)
            return Index(indexValues: [rv] )
        }
        performance.reset()
        aggstats.aggregate()
        
        for (index,data) in aggstats.data(sortedBy: >) {
            guard let value = index.indexValues.first else { XCTAssertTrue(false); continue }
            if case let .dateBucket(bucket) = value {
                guard let old = stats.data(for: bucket.interval.start) else { XCTAssertTrue(false); continue }
                if let speed = GCField(for: .weightedMeanSpeed, andActivityType: activityType) {
                    data.data[speed]?.compare(field: speed, dataHolder: old, message: "\(bucket) monthly aggregate")
                }
                
                for (k,v) in data.data {
                    v.compare(field: k, dataHolder: old, message: "\(bucket) monthly aggregate")
                }
            }else{
                XCTAssertTrue(false)
            }
        }
    }
}
