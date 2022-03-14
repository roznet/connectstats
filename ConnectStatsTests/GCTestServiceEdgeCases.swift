//  MIT License
//
//  Created on 25/01/2021 for ConnectStatsXCTests
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

class GCTestServiceEdgeCases: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    // tests running on small parsing edge cases generated from cs_sample.py
    func testParsingLiveMultiSportSingle() throws {
        // This is a test to run on live data
        let tag = "multisportsingle"
        let cs = RZFileOrganizer.bundleFilePath("last_connectstats_search_\(tag).json", for: type(of: self))
        let ga = RZFileOrganizer.bundleFilePath("last_modern_search_\(tag).json", for: type(of: self))
        // Run on live data
        //let cs = RZFileOrganizer.writeableFilePath("last_connectstats_search_\(tag).json")
        //let ga = RZFileOrganizer.writeableFilePath("last_modern_search_\(tag).json")
        
        RZFileOrganizer.removeEditableFile("activities_testLiveZMultiSportSingle.db")
        let db = FMDatabase(path: RZFileOrganizer.writeableFilePath("activities_testLiveZMultiSportSingle.db"))
        db.open()
        GCActivitiesOrganizer.ensureDbStructure(db)
        let organizer = GCActivitiesOrganizer(testModeWithDb: db)

        // Start with list of activity including multi sport sub activities
        GCConnectStatsRequestSearch.test(for: organizer, withFilesInPath: cs)
        let startCount = organizer.activities.count
        // While garmin does not send sub activities, make sure all the activities are preserved and not deleted
        GCGarminRequestModernSearch.test(for: organizer, withFilesInPath: ga)
        XCTAssertEqual(startCount, organizer.activities.count)
    }

    
    func testParsingLiveZeroDistance() throws {
        // This is a test to run on live data
        RZFileOrganizer.removeEditableFile("activities_testLiveZeroDistance.db")
        let db = FMDatabase(path: RZFileOrganizer.writeableFilePath("activities_testLiveZeroDistance.db"))
        db.open()
        GCActivitiesOrganizer.ensureDbStructure(db)
        let organizer = GCActivitiesOrganizer(testModeWithDb: db)
        
        let tag = "zerodistance"
        let cs = RZFileOrganizer.bundleFilePath("last_connectstats_search_\(tag).json", for: type(of: self))
        let ga = RZFileOrganizer.bundleFilePath("last_modern_search_\(tag).json", for: type(of: self))
        // Run on live data
        //let cs = RZFileOrganizer.writeableFilePath("last_connectstats_search_\(tag).json")
        //let ga = RZFileOrganizer.writeableFilePath("last_modern_search_\(tag).json")

        
        // ConnectStats data has no distance, should get 0.0
        GCConnectStatsRequestSearch.test(for: organizer, withFilesInPath: cs)
        var act = organizer.currentActivity()
        if let act = act, let nu = act.numberWithUnit(for: GCField(for: .sumDistance, andActivityType: act.activityType)) {
            XCTAssertEqual( nu, GCNumberWithUnit(name: "meter", andValue: 0.0))
        }
        // Garmin data has manually edited distance, should get non 0.0
        GCGarminRequestModernSearch.test(for: organizer, withFilesInPath: ga)
        act = organizer.currentActivity()
        if let act = act, let nu = act.numberWithUnit(for: GCField(for: .sumDistance, andActivityType: act.activityType)) {
            XCTAssertNotEqual( nu, GCNumberWithUnit(name: "meter", andValue: 0.0))
        }
        // ConnectStats data has no distance, but should not override previous non zero data
        GCConnectStatsRequestSearch.test(for: organizer, withFilesInPath: cs)
        act = organizer.currentActivity()
        if let act = act, let nu = act.numberWithUnit(for: GCField(for: .sumDistance, andActivityType: act.activityType)) {
            XCTAssertNotEqual( nu, GCNumberWithUnit(name: "meter", andValue: 0.0))
        }
    }
}
