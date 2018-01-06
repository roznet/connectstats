//
//  GCSegment.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 25/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import CoreLocation
import RZUtilsSwift

class GCSegment: NSObject {
    let segmentId:String?
    let startCoordinate : CLLocationCoordinate2D
    let name:String?
    let distanceMeters:Double?
    let activityType:String?
    let country:String?
    let city:String?
    let state:String?
    
    class func ensureDbStructure(db:FMDatabase){
        if !db.tableExists("gc_segments") {
            db.executeUpdate("CREATE TABLE gc_segments (segmentId TEXT PRIMARY KEY, name TEXT, startCoordinateLon REAL, startCoordinateLat REAL, distanceMeters REAL, activityType TEXT, country TEXT, city TEXT, state TEXT)", withArgumentsIn: []);
        }
    }
    
    init(withStravaJson one:[String:AnyObject]){
        if let idInt = one["id"] as? Int{
            segmentId = "\(idInt)"
        }else{
            segmentId = nil
        }

        if let lat = one["start_latitude"] as? Double, let lng = one["start_longitude"] as? Double{
            startCoordinate = CLLocationCoordinate2DMake(lat, lng)
        }else{
            startCoordinate = CLLocationCoordinate2DMake(0, 0)
        }

        if let stravaType = one["activity_type"] as? String{
            switch stravaType {
            case "Run":
                activityType = GC_TYPE_RUNNING
                break
            case "Ride":
                activityType = GC_TYPE_CYCLING
                break;
            default:
                activityType = nil
            }
        }else{
            activityType = nil
        }
        
        name = one["name"] as? String
        distanceMeters = one["distance"] as? Double
        country = one["country"] as? String
        city = one["city"] as? String
        state = one["state"] as? String
        
        super.init()
    }
    
    init(withResultSet res:FMResultSet){
        segmentId = res.string(forColumn: "segmentId")
        name = res.string(forColumn: "name")
        startCoordinate = CLLocationCoordinate2DMake(res.double(forColumn: "startCoordinateLat"), res.double(forColumn: "startCoordinateLon"));
        activityType = res.string(forColumn: "activityType")
        country = res.string(forColumn: "country");
        distanceMeters = res.double(forColumn: "distanceMeters");
        city = res.string(forColumn: "city")
        state = res.string(forColumn: "state");
        
        super.init()
    }
    
    public func save(toDb db:FMDatabase){
        let query = "INSERT OR REPLACE INTO gc_segments (segmentId,name,activityType,country,city,state,distanceMeters,startCoordinateLon,startCoordinateLat) VALUES (?,?,?,?,?,?,?,?,?)";
        let opStrValues : [String?] = [segmentId,name,activityType,country,city,state];
        let opNumValues : [Double?] = [distanceMeters,startCoordinate.longitude,startCoordinate.latitude];
        var values :[Any] = opStrValues.flatMap{ $0}
        for one in opNumValues.flatMap({ $0 }) {
            values.append(one);
        }

        if values.count == 9 {
            if !db.executeUpdate(query, withArgumentsIn: values){
                let errorMsg = String(describing:db.lastErrorMessage())
                RZSLog.error("Failed to execute \(query), \(errorMsg)");
            }
        }else{
            RZSLog.error("Attempt to save not complete Segment");
        }
    }
    override var description: String{
        let sid = segmentId ?? "", aType = activityType ?? "nil", aName = name ?? "nil"
        return String(format: "<GCSegment[%@,%@]:%@>", sid, aType, aName);
    }
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? GCSegment{
            return other.segmentId == segmentId && other.name == name && activityType == other.activityType;
        }else{
            return false;
        }
    }
}
