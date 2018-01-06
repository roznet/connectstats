//
//  GCTestsSegments.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 30/08/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import XCTest
@testable import ConnectStats

class GCTestsSegments: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let path = RZFileOrganizer.bundleFilePath(nil, for: type(of:self));
        
        if  let parser = GCStravaSegmentListStarred.testParserWithFiles(inPath: path){
            XCTAssertEqual(parser.count(), 7)
            RZFileOrganizer.removeEditableFile("test_segments.db")
            if let db = FMDatabase(path: RZFileOrganizer.writeableFilePath("test_segments.db")){
                db.open()
                let organizer = GCSegmentOrganizer(withDb: db);
                parser.registerIn(organizer:organizer)

                if let parser = GCStravaAthlete.testParserWithFiles(inPath: path){
                    parser.registerInOrganizer(organizer: organizer)
                }else{
                    XCTAssert(false)
                }

                // reload
                let organizer2 = GCSegmentOrganizer(withDb: db);
                for (sid,one) in organizer.segmentList{
                    let other = organizer2.segmentList[sid]
                    XCTAssertEqual(one, other);
                }
                XCTAssertEqual(organizer.athlete, organizer2.athlete);
            }
        }else{
            XCTAssert(false);
        }
        
    }
    
    func testKeyChain() {
        let mgr = GCAppPasswordManager(forService: "garmin", andUsername: "__brice__test__");
        let mgr2 = GCAppPasswordManager(forService: "garmin", andUsername: "__brice__test2__");
        
        XCTAssertNil(mgr.retrievePassword())
        XCTAssertNil(mgr2.retrievePassword())
        
        mgr.savePassword("yo1")
        mgr2.savePassword("yo2")
        
        XCTAssertEqual(mgr.retrievePassword(), "yo1")
        XCTAssertEqual(mgr2.retrievePassword(), "yo2")
        mgr.clearPassword()
        mgr2.clearPassword()
        
        XCTAssertNil(mgr.retrievePassword())
        XCTAssertNil(mgr2.retrievePassword())
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
