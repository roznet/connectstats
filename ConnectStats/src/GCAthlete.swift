//
//  GCAthlete.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 25/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import UIKit

class GCAthlete: NSObject {
    let athleteId:String?
    let username:String?
    let firstName:String?
    let lastName:String?
    
    static let kUserNameKey = "username";
    static let kAthleteIdKey = "athleteId";
    static let kFirstNameKey = "firstname";
    static let kLastNameKey = "lastname";
        
    init(withStravaJson one:[String:AnyObject]){
        if let intId = one["id"] as? Int{
            athleteId = "\(intId)"
        }else{
            athleteId = nil
        }
        
        username = one[GCAthlete.kUserNameKey] as? String
        firstName = one[GCAthlete.kFirstNameKey] as? String
        lastName = one[GCAthlete.kLastNameKey] as? String
        
        super.init()
    }
    init(withResultSet res:FMResultSet){
        athleteId = res.string(forColumn: GCAthlete.kAthleteIdKey);
        username = res.string(forColumn: GCAthlete.kUserNameKey);
        firstName = res.string(forColumn: GCAthlete.kFirstNameKey);
        lastName = res.string(forColumn: GCAthlete.kLastNameKey);
        
        super.init()
    }
    
    func saveToDb(_ db:FMDatabase) {
        if let a = athleteId, let u = username, let f = firstName, let l = lastName{
            db.executeUpdate("INSERT OR REPLACE INTO gc_athlete (athleteId,username,firstName,lastName) VALUES (?,?,?,?)", withArgumentsIn: [a,u,f,l]);
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? GCAthlete{
            return other.athleteId == athleteId && other.username == username && other.firstName == firstName && other.lastName == lastName;
        }
        return false;
    }
    
    class func ensureDbStructure(db:FMDatabase){
        if !db.tableExists("gc_athlete"){
            db.executeUpdate("CREATE TABLE gc_athlete (athleteId TEXT PRIMARY KEY, username TEXT, firstName TEXT, lastName TEXT)", withArgumentsIn: []);
        }
    }
}
