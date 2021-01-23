//
//  FitFileExplorerTests.swift
//  FitFileExplorerTests
//
//  Created by Brice Rosenzweig on 08/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import XCTest
@testable import FitFileExplorer
import FitFileParser


class FitFileExplorerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFastFitFile() {
        let filenames = [ "activity_1378220136.fit", "activity_1382772474.fit" ]
        
        for filename in filenames {
            if
                let fastfit = FitFile(file: URL(fileURLWithPath: RZFileOrganizer.bundleFilePath(filename, for: type(of:self)))) {
                let fasttypes = fastfit.messageTypes
                XCTAssertNotNil(fasttypes)
                
                let records = fastfit.messages(forMessageType: FitMessageType.record)
                if  records.count > 0 {
                    let csv = fastfit.csv(messageType: FitMessageType.record)
                    XCTAssertEqual(csv.count, records.count+1)
                    
                    var size : Int? = nil
                    var counter : Int = 0
                    for line in csv {
                        let elements = line.split(separator: ",", maxSplits: Int.max, omittingEmptySubsequences: false)
                        if size == nil {
                            size = elements.count
                        }else{
                            XCTAssertEqual(size, elements.count, "line \(counter)")
                        }
                        counter+=1                    }
                }
            }
        }
    }
       
    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        //let filenames = [ "activity_1378220136.fit", "activity_1382772474.fit", "activity_2477200414.fit", "activity_2944936628.fit" ]
        let filenames = [ "activity_1378220136.fit",
                          "activity_1382772474.fit",
                          "activity_2477200414.fit",
                          //"activity_2944936628.fit",
                          "activity_2545022458.fit"
        ]
        let datas = filenames.map {
            try? Data(contentsOf: URL(fileURLWithPath: RZFileOrganizer.bundleFilePath($0, for: type(of:self))))
        }
        
        self.measure {
            for data in datas{
                if let data = data {
                    let fastfit = FitFile(data: data)
                    let records = fastfit.messages(forMessageType: FitMessageType.record)
                    XCTAssertGreaterThan(records.count, 0)
                }else{
                    XCTAssertTrue(false)
                }
            }
            
            if let one = datas.first, let data = one {
                let fastfit = FitFile(data: data)
                let records = fastfit.messages(forMessageType: FitMessageType.record)
                let interp = records.map {
                    $0.interpretedFields()
                }
                XCTAssertGreaterThan(interp.count, 0)
            }else{
                XCTAssertTrue(false)
            }

        }
    }
    
}
