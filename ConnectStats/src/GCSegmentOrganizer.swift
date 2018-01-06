//
//  GCSegmentOrganizer.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 30/08/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import UIKit
import Foundation

class GCSegmentOrganizer : NSObject {
    var segmentList : [String : GCSegment ]
    var db : FMDatabase
    var athlete : GCAthlete?;
    
    @objc public init(withDb aDb:FMDatabase) {
        self.db = aDb
        GCSegment.ensureDbStructure(db: db)
        GCAthlete.ensureDbStructure(db: db)
        
        segmentList = [:]
        
        if let res = db.executeQuery("SELECT * FROM gc_segments", withArgumentsIn: []) {
            while(res.next()){
                let one = GCSegment(withResultSet: res);
                if let sid:String = one.segmentId{
                    segmentList[sid] = one
                }
            }
        }
        if let res = db.executeQuery("SELECT * FROM gc_athlete LIMIT 1", withArgumentsIn: []), res.next(){
            athlete = GCAthlete(withResultSet:  res );
        }else{
            athlete = nil;
        }
        super.init()
    }
    
    public func updateAthlete(withAthlete : GCAthlete){
        if withAthlete != athlete{
            athlete = withAthlete;
            athlete?.saveToDb(db);
        }
    }
    
    public func addSegments(segments: [GCSegment]){
        for segment in segments {
            if let sid = segment.segmentId {
                segmentList[sid] = segment
                segment.save(toDb: db);
            }
        }
    }
    
}
