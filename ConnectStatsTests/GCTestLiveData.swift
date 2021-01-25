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

class GCTestLiveData: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testParsingLiveZeroDistance() throws {
        // This is a test to run on live data
        if RZFileOrganizer.writeableFilePathIfExists("last_connectstats_search_zerodistance.json") != nil {
            RZFileOrganizer.removeEditableFile("activities_testLiveZeroDistance.db")
            let db = FMDatabase(path: RZFileOrganizer.writeableFilePath("activities_testLiveZeroDistance.db"))
            db.open()
            GCActivitiesOrganizer.ensureDbStructure(db)
            let organizer = GCActivitiesOrganizer(testModeWithDb: db)
            
            // ConnectStats data has no distance, should get 0.0
            GCConnectStatsRequestSearch.test(for: organizer, withFilesInPath: RZFileOrganizer.writeableFilePath("last_connectstats_search_zerodistance.json"))
            var act = organizer.currentActivity()
            if let act = act, let nu = act.numberWithUnit(for: GCField(for: .sumDistance, andActivityType: act.activityType)) {
                XCTAssertEqual( nu, GCNumberWithUnit(name: "meter", andValue: 0.0))
            }
            // Garmin data has manually edited distance, should get non 0.0
            GCGarminRequestModernSearch.test(for: organizer, withFilesInPath: RZFileOrganizer.writeableFilePath("last_modern_search_zerodistance.json"))
            act = organizer.currentActivity()
            if let act = act, let nu = act.numberWithUnit(for: GCField(for: .sumDistance, andActivityType: act.activityType)) {
                XCTAssertNotEqual( nu, GCNumberWithUnit(name: "meter", andValue: 0.0))
            }
            // ConnectStats data has no distance, but should not override previous non zero data
            GCConnectStatsRequestSearch.test(for: organizer, withFilesInPath: RZFileOrganizer.writeableFilePath("last_connectstats_search_zerodistance.json"))
            act = organizer.currentActivity()
            if let act = act, let nu = act.numberWithUnit(for: GCField(for: .sumDistance, andActivityType: act.activityType)) {
                XCTAssertNotEqual( nu, GCNumberWithUnit(name: "meter", andValue: 0.0))
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
