//
//  GCTestActivityFitFile.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 01/01/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import XCTest
@testable import ConnectStats
import RZFitFile

class GCTestActivityFitFile: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseFitAndMerge() {
        
        // 10834...: ski activity merge cadence
        // 24772...: run activity merge power
        let testActivityIds = [  "2477200414", "1083407258"]
        for activityId in testActivityIds {
            
            let url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath("activity_\(activityId).fit", for: type(of: self)))

            if 
                let fitFile = RZFitFile(file: url){
                
                let activity = GCActivity(withId: activityId, fitFile: fitFile)
                if let reload = GCGarminRequestActivityReload.test(forActivity: activityId, withFilesIn:RZFileOrganizer.bundleFilePath(nil, for: type(of: self)) ){
                    reload.updateSummaryData(from: activity)
                    reload.updateTrackpoints(from: activity)
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
