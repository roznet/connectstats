//
//  main.swift
//  fittestswift
//
//  Created by Brice Rosenzweig on 16/12/2018.
//  Copyright © 2018 Brice Rosenzweig. All rights reserved.
//

import Foundation
import RZFitFile

let file = URL(fileURLWithPath: CommandLine.arguments[1])

print( "Parsing \(file.path)" )

let startTime = CFAbsoluteTimeGetCurrent()
if let fitfile = RZFitFile(file: file) {
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print( "\(fitfile.messages.count) messages in \(timeElapsed) seconds" )
}else{
    print( "failed" )
}

