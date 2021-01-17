//
//  GCTestActivityFitFile.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 01/01/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import XCTest
@testable import ConnectStats
import FitFileParser


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
                let fitFile = FitFile(file: url){
                
                let activity = GCActivity(withId: activityId, fitFile: fitFile, startTime: Date())
                if let reload = GCGarminRequestActivityReload.test(forActivity: activityId, withFilesIn:RZFileOrganizer.bundleFilePath(nil, for: type(of: self)) ){
                    reload.updateSummaryData(from: activity)
                    reload.updateTrackpoints(from: activity)
                }
                
            }
            
        }
    
    }
    
    func testParseFitSwimAndMultiSport() {
        
        RZFileOrganizer.removeEditableFile("multisport.db")
        
        let db = FMDatabase(path: RZFileOrganizer.writeableFilePath("multisport.db"))
        db.open()
        GCActivitiesOrganizer.ensureDbStructure(db)
        let organizer : GCActivitiesOrganizer = GCActivitiesOrganizer(testModeWithDb: db)
        
        let testActivityIds = [  "1525", "1451"]
        for activityId in testActivityIds {
            
            GCConnectStatsRequestSearch.test(for: organizer, withFilesInPath: RZFileOrganizer.bundleFilePath("last_cs_search_\(activityId).json", for: type(of: self)))
            
            let url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath("track_cs_\(activityId).fit", for: type(of: self)))
            
            if
                let fitFile = FitFile(file: url){
                let messages = fitFile.messages(forMessageType: FitMessageType.session)
                var activities : [GCActivity] = []
                for message in messages {
                    if let messageStart = message.interpretedField(key: "start_time")?.time,
                       let activity = GCActivity(withId: activityId, fitFile: fitFile, startTime: messageStart){
                        activities.append(activity)
                        //print( "\(activity) \(activity.summaryData)")
                        var downloaded : GCActivity? = nil
                        for act in organizer.activities() {
                            if act.date == messageStart && act.activityType == activity.activityType{
                                downloaded = act
                                break
                            }
                        }
                        XCTAssertNotNil(downloaded)
                        if  let downloaded = downloaded {
                            
                            XCTAssertEqual(downloaded.summaryFieldValue(inStoreUnit: gcFieldFlag.sumDistance),
                                           activity.summaryFieldValue(inStoreUnit: gcFieldFlag.sumDistance), accuracy: 1.0)
                        }
                    }
                }
                if messages.count > 1{
                    // Multi sport test for the whole one.
                    if let activity = GCActivity(withId: activityId, fitFile: fitFile, startTime: nil){
                        activities.append(activity)
                        let service = GCService(gcService.connectStats)
                        if let serviceId = service?.activityId(fromServiceId: activityId) {
                            XCTAssertNotNil(organizer.activity(forId: serviceId))
                        }
                        // we don't check value as they don't tie out for multi sport, not
                        // sure how they get aggregated/summed in the garmin api...
                    }
                }
            }
        }
    }
}
