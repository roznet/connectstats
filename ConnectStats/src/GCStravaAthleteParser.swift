//
//  GCStravaAthleteParser.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 17/09/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import UIKit

class GCStravaAthleteParser: NSObject {
    let athlete : GCAthlete?;
    
    @objc public init( data: Data){
        let object =  try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        if let athleteInfo = object as? [String:AnyObject]{
            athlete = GCAthlete(withStravaJson: athleteInfo);
        }else{
            athlete = nil;
        }
        super.init();
    }
    
    @objc public func registerInOrganizer( organizer : GCSegmentOrganizer){
        if let athlete = athlete{
            organizer.updateAthlete(withAthlete: athlete);
        }
    }
}
