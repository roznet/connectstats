//  MIT License
//
//  Created on 06/01/2019 for FitFileExplorerTests
//
//  Copyright (c) 2019 Brice Rosenzweig
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
@testable import FitFileExplorer

class FitFileExplorerActivities: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let garmin_sample = "last_modern_search_0.json"
        let garmin_sample_url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath(garmin_sample, for: type(of:self)))
        
        if let organizer = ActivitiesOrganizer(url: garmin_sample_url) {
            
            XCTAssertEqual(organizer.activityList.count, 20)
            
            // Load a second time adds nothing
            let result = organizer.load(url: garmin_sample_url)
            XCTAssertEqual(result.updated, 0)
            
            let outfile = "saved.json"
            let outfile_url = URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(outfile))
            
            do {
                try organizer.save(url: outfile_url)
            }catch{
                print("\(error)")
            }
            
            let reloaded = ActivitiesOrganizer(url: outfile_url)
            XCTAssertEqual(reloaded?.activityList.count, organizer.activityList.count)
        }
    }

    func testParseAndSaveBig() {
        let organizer = ActivitiesOrganizer()
        var reachedEnd = false
        RZFileOrganizer.removeEditableFile("test_save_big.db")
        if let db = FMDatabase(path: RZFileOrganizer.writeableFilePath("test_save_big.db")){
            db.open()
            organizer.db = db
            
            let files = RZFileOrganizer.writeableFiles(matching: { (s) -> Bool in s.hasPrefix("last_modern_search") } )
            
            var count = 0
            var samplecount = 0
            var samplechange = 0
            
            for fn in files {
                let url = URL( fileURLWithPath: RZFileOrganizer.writeableFilePath(fn) )
                _ = organizer.load(url: url)
                count += 1
                if samplecount != 0 && organizer.sample().numbers.count != samplecount {
                    samplechange += 1
                }
                samplecount = organizer.sample().numbers.count
            }
            print( "loaded \(count) files, samplecount: \(samplecount), samplechange: \(samplechange) ")
            
            reachedEnd = true
        }
        XCTAssertTrue(reachedEnd)
    }
    
    func testLoadBig() {
        if let fp = RZFileOrganizer.writeableFilePathIfExists("test_save_big.db") {
            if let db = FMDatabase(path: fp){
                db.open()
                let organizer = ActivitiesOrganizer(db: db)
                XCTAssertTrue(organizer.count > 1000)
            }
        }
    }
    
    func testLoadManyJson() {
        
        let files = RZFileOrganizer.bundleFiles(matching: { (s) -> Bool in s.hasPrefix("last_modern_search") }, for: type(of:self))
        //let files = RZFileOrganizer.writeableFiles(matching: { (s) -> Bool in s.hasPrefix("last_modern_search") } )
        
        let organizer = ActivitiesOrganizer()

        var count = 0
        
        var foundEnd = false
        
        for fn in files {
            let url = URL( fileURLWithPath: RZFileOrganizer.bundleFilePath(fn, for: type(of:self)) )
            // check something was added
            let added = organizer.load(url: url)
            
            if added.updated == 0 {
                XCTAssertFalse(foundEnd)
                foundEnd = true
            }
            
            XCTAssertEqual( added.total, added.updated )
            XCTAssertEqual(organizer.activityList.count, count+added.updated)
            count = organizer.activityList.count
        }
        XCTAssertTrue(foundEnd)
        
        let activityIds = [ organizer.activityList[0].activityId, organizer.activityList[1].activityId ]
        let count_added = organizer.remove(activityIds: activityIds)
        XCTAssertEqual(count_added, activityIds.count)
        XCTAssertEqual(organizer.activityList.count, count-count_added)
        let firstfile = RZFileOrganizer.bundleFilePath("last_modern_search_0.json", for: type(of: self))
        let addedback = organizer.load(url: URL(fileURLWithPath: firstfile))
        XCTAssertEqual(organizer.activityList.count, count)
        XCTAssertEqual(addedback.updated, count_added)
        XCTAssertEqual(addedback.total, 20)
    }
    
    func intForQuery(db : FMDatabase, query : String) -> Int {
        let res = db.executeQuery(query, withArgumentsIn: [])
        if let res = res, res.next() {
            return Int(res.int(forColumnIndex: 0))
        }
        return 0
    }
    
    func testDatabase() {
        var reachedEnd = false
        let garmin_sample = "last_modern_search_20.json"
        let garmin_sample_url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath(garmin_sample, for: type(of:self)))
        RZFileOrganizer.removeEditableFile("test_activities.db")
        if let organizer = ActivitiesOrganizer(url: garmin_sample_url) {
            
            if let db = FMDatabase(path: RZFileOrganizer.writeableFilePath("test_activities.db")) {
                db.open()

                XCTAssertEqual(self.intForQuery(db: db, query: "SELECT COUNT(*) FROM activities"), 0)

                organizer.save(to: db)
                organizer.db = db
                
                XCTAssertEqual(self.intForQuery(db: db, query: "SELECT COUNT(*) FROM activities"), organizer.activityList.count)

                let reloaded = ActivitiesOrganizer(db: db)
                XCTAssertEqual(reloaded.activityList.count, organizer.activityList.count)
                
                var count = 0
                for activity in organizer.activityList {
                    if let reloaded_activity = reloaded.activity(activityId: activity.activityId) {
                        count+=1
                        XCTAssertEqual(activity.time, reloaded_activity.time)
                        XCTAssertEqual(activity.numbers.count, reloaded_activity.numbers.count)
                    }
                }
                XCTAssertEqual(count, organizer.count)
                
                let garmin_sample_next = "last_modern_search_0.json"
                let garmin_sample_next_url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath(garmin_sample_next, for: type(of:self)))
                
                let startcount = organizer.count
                let samplecount = organizer.sample().numbers.count
                let res = organizer.load(url: garmin_sample_next_url)
                XCTAssertEqual(organizer.count, startcount+res.updated)

                let newsamplecount = organizer.sample().numbers.count
                XCTAssertEqual(newsamplecount, samplecount)
                
                reachedEnd = true
            }
        }
        
        XCTAssertTrue(reachedEnd)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
