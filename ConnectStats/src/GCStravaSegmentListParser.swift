//
//  GCStravaSegmentListParser.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 25/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

class GCStravaSegmentListParser: NSObject {

    let segments:[GCSegment]
    
    @objc public init( data:Data){

        let object =  try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        if let segmentList = object as? [[String:AnyObject]]{
            var found = [GCSegment]()
            for one in segmentList{
                let seg = GCSegment(withStravaJson: one)
                found.append(seg)
            }
            segments = found
        }else{
            segments = []
        }
        
        super.init()
    }
    
    public func count() -> Int {
        return segments.count
    }
    
    public func registerIn(organizer:GCSegmentOrganizer){
        organizer.addSegments(segments: segments)
    }
}
