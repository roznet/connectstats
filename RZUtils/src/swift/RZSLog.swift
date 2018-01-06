//
//  RZSLog.swift
//  RZUtils
//
//  Created by Brice Rosenzweig on 24/07/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

public class RZSLog {
    
    public class func info( _ message:String, functionName:String = #function, fileName:String = #file, lineNumbe:Int = #line ){
        RZSLogBridge.logInfo(functionName, path: fileName , line: lineNumbe, message: message)
    }
    public class func error( _ message:String, functionName:String = #function, fileName:String = #file, lineNumbe:Int = #line ){
        RZSLogBridge.logError(functionName, path: fileName , line: lineNumbe, message: message)
    }
    public class func warning( _ message:String, functionName:String = #function, fileName:String = #file, lineNumbe:Int = #line ){
        RZSLogBridge.logWarning(functionName, path: fileName , line: lineNumbe, message: message)
    }

}
