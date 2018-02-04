//
//  GCTestActivityFitFile.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 01/01/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import XCTest

class GCTestActivityFitFile: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseFit() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let testActivityIds = [ "1083407258", "1378220136", "1382772474"]
        for activityId in testActivityIds {
            
            let url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath("activity_\(activityId).fit", for: type(of: self)))

            if let fitData = try? Data(contentsOf: url),
                let decode = FITFitFileDecode(fitData){
                decode.parse()
                let activity = GCActivity(withId: activityId, fitFile: decode.fitFile)
                if let reload = GCGarminRequestActivityReload.test(forActivity: activityId, withFilesIn:RZFileOrganizer.bundleFilePath(nil, for: type(of: self)) ){
                    print( "\(reload)")
                    reload.mergeTrackPoints(other: activity)
                }
                
            }
            
        }
        
        /*
        for (NSString * activityId in @[@"1378220136",@"1382772474"]) {
            NSData * fitData = [NSData dataWithContentsOfFile:[RZFileOrganizer bundleFilePath:[NSString stringWithFormat:@"activity_%@.fit", activityId] forClass:[self class]]];
            FITFitFileDecode * fitFile = [FITFitFileDecode fitFileDecode:fitData];
            [fitFile parse];
            
            GCActivity * act = [[[GCActivity alloc] initWithId:activityId fitFile:fitFile.fitFile] autorelease];
            NSLog(@"%@", act);
        }*/

    }
    
   /* func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }*/
    
}
