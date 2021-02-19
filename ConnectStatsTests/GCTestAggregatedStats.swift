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
            let newnu = self.numberWithUnit(stats: newstat).convert(to: unit)
            guard var oldnu = dataHolder.number(withUnit: field, statType: oldstat)?.convert(to: unit) else { XCTAssertTrue(false); continue }

            // Special case weighted value for speed in old comes from preferred number
            if oldstat == .wvg && field.fieldFlag == .weightedMeanSpeed {
                guard let speednu = dataHolder.preferredNumber(withUnit: field) else { XCTAssertTrue(false); return }
                oldnu = speednu
            }else{
                // dont check weighted for other
                continue
            }
            
            let scale = Swift.max(abs(newnu.value), abs(oldnu.value), .leastNormalMagnitude)
            let tolerance = Double.ulpOfOne.squareRoot()

            XCTAssertEqual(newnu.value, oldnu.value, accuracy: scale*tolerance,"\(field) \(newstat) \(message)")
            if( abs( newnu.value - oldnu.value ) > scale*tolerance){
                let newnu2 = self.numberWithUnit(stats: newstat).convert(to: unit)
                guard let oldnu2 = dataHolder.number(withUnit: field, statType: oldstat)?.convert(to: unit) else { XCTAssertTrue(false); continue }
                guard let speednu2 = dataHolder.preferredNumber(withUnit: field) else { XCTAssertTrue(false); return }
                print( "\(newnu2) \(oldnu2) \(speednu2)")
            }
        }
    }
}

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
        
        let calendar = Calendar.current
        
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
    
    
    func activitiesForStatsTest(n : Int = Int.max, activityType : String = GC_TYPE_ALL) -> [GCActivity] {
        guard let db = GCTestsSamples.sampleActivityDatabase("activities_stats.db") else { XCTAssertTrue(false); return [] }
        let organizer = GCActivitiesOrganizer(testModeWithDb: db)
        
        let all = organizer.activities()
        
        let activityType = GC_TYPE_RUNNING
        
        //guard let first = all.first else { XCTAssertTrue( false ); return }
        //let firstmonth = DateBucket(date: first, unit: .month, calendar: calendar)
        
        var activities : [GCActivity] = []
        for activity in all {
            if activity.activityType == activityType {
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
        print( "\(fieldsdata) \(performance)")
        
        if let basedate = activities.last?.date {
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
            print( "\(aggfieldstats) \(performance)")
        }
    }
    
    func testMultiLevelAggregatedStats() {
        let activityType = GC_TYPE_RUNNING
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

        print( "\(aggtypestats) \(performance)")
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
        
        print( "\(stats) \(performance)")
                
        let aggstats = HistoryAggregator(activities: activities, fields: GCHistoryAggregatedActivityStats.defaultFields(forActivityType: activityType)) {
            act in
            let bucket = DateBucket(date: act.date, unit: .month, calendar: calendar)
            let rv = IndexValue.dateBucket(bucket!)
            return Index(indexValues: [rv] )
        }
        performance.reset()
        aggstats.aggregate()
        print( "\(aggstats) \(performance)")
        
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
