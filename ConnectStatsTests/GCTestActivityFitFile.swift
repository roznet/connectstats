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
import RZFitFileTypes

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
                
                let activity = GCActivity(withId: activityId, fitFile: fitFile, startTime: Date())
                if let reload = GCGarminRequestActivityReload.test(forActivity: activityId, withFilesIn:RZFileOrganizer.bundleFilePath(nil, for: type(of: self)) ){
                    reload.updateSummaryData(from: activity)
                    reload.updateTrackpoints(from: activity)
                }
                
            }
            
        }
    
    }
    
    func testParseFitSwimAndMultiSport() {
        
        
        let testActivityIds = [  "1451", "1525"]
        for activityId in testActivityIds {
            
            let url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath("track_cs_\(activityId).fit", for: type(of: self)))
            
            if
                let fitFile = RZFitFile(file: url){
                let messages = fitFile.messages(forMessageType: FIT_MESG_NUM_SESSION)
                var activities : [GCActivity] = []
                for message in messages {
                    if let messageStart = message.interpretedField(key: "start_time")?.time{
                        let activity = GCActivity(withId: activityId, fitFile: fitFile, startTime: messageStart)
                        activities.append(activity)
                        
                    }
                }
                if messages.count > 1{
                    // Multi sport test for the whole one.
                    let activity = GCActivity(withId: activityId, fitFile: fitFile, startTime: nil)
                    activities.append(activity)

                }
                for activity in activities {
                    print( "\(activity) \(activity.date) \(activity.trackpoints.count)")
                }
            }
        }
    }
}
