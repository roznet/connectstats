//  MIT License
//
//  Created on 27/12/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//



import Foundation
import ZIPFoundation
import RZUtilsSwift

extension GCGarminActivityTrack13Request {
    @objc static func extract(fitData : Data, baseName : String) {
        guard let archive = Archive(data: fitData, accessMode: .read ) else {
            RZSLog.error("Failed to create zip archive from data")
            return
        }
        
        var fitFileEntry : Entry? = nil
        for item in archive {
            if item.path.hasSuffix(".fit"){
                if item.path.hasSuffix("fit") {
                    if fitFileEntry != nil {
                        RZSLog.warning("Multiple fit files in archive")
                    }
                    fitFileEntry = item
                }
            }
        }
        
        let fitFile = URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(baseName) )
        if let fitFileEntry = fitFileEntry {
            do {
                _ = try archive.extract(fitFileEntry, to: fitFile)
            }catch{
                RZSLog.error("Failed to extract fit file \(error)")
            }
        }
    }
}
