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
    
    func testAggregated() {
        guard let db = GCTestsSamples.sampleActivityDatabase("activities_stats.db") else { XCTAssertTrue(false); return }
        let organizer = GCActivitiesOrganizer(testModeWithDb: db)
        let calendar = GCAppGlobal.calculationCalendar()

        let all = organizer.activities()
        
        var activities : [GCActivity] = []
        for activity in all {
            if activity.activityType == GC_TYPE_RUNNING {
                activities.append(activity)
            }
            if activities.count == 5{
                break
            }
        }
        activities = all
        
        let performance = RZPerformance()
        performance.reset()
        let stats = GCHistoryAggregatedActivityStats(forActivityType: GC_TYPE_ALL)
        stats.activities = activities
        
        stats.aggregate(.month, referenceDate: nil, ignoreMode: gcIgnoreMode.activityFocus)
        
        print( "\(stats) \(performance)")
                
        let aggstats = HistoryAggregator(activities: activities, fields: GCHistoryAggregatedActivityStats.defaultFields(forActivityType: GC_TYPE_ALL)) {
            act in
            let bucket = DateBucket(date: act.date, unit: .month, calendar: calendar)
            let rv = IndexValue.dateBucket(bucket!)
            return Index(indexValues: [rv] )
        }
        performance.reset()
        aggstats.aggregate()
        print( "\(aggstats) \(performance)")
        
        performance.reset()
        let fieldsdata = GCHistoryFieldSummaryStats.fieldStats(withActivities: activities, matching: nil, referenceDate: nil, ignoreMode: gcIgnoreMode.activityFocus)
        print( "\(fieldsdata) \(performance)")
        
        if let basedate = activities.last?.date {
            let indexes : Set<Index> = [
                Index(dateBucket: DateBucket(date: basedate, unit: .weekOfYear, calendar: calendar)!),
                Index(dateBucket: DateBucket(date: basedate, unit: .month, calendar: calendar)!),
                Index(dateBucket: DateBucket(date: basedate, unit: .year, calendar: calendar)!)
            ]
            let aggfieldstats = HistoryAggregator(activities: organizer.activities(), indexes:indexes) {
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
}
