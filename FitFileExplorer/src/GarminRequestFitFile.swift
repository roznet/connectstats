//  MIT License
//
//  Created on 18/01/2019 for FitFileExplorer
//
//  Copyright (c) 2019 Brice Rosenzweig
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



import Cocoa

class GarminRequestFitFile: GarminRequest {
    
    let activityId : String
    
    
    init(activityId : String) {
        self.activityId = activityId
        
        super.init()
    }
    
    
    @objc override func url() -> String {
        return GCWebActivityURLFitFile(self.activityId)
    }
    
    @objc override func description() -> String {
        return "Downloading Fit File... \(self.activityId)"
    }
    
    func fitFileName() -> String {
        return "\(self.activityId).fit.zip"
    }
    
    @objc override func process(_ theData: Data, andDelegate delegate: GCWebRequestDelegate) {
        let path = RZFileOrganizer.writeableFilePath(self.fitFileName())
        do {
            try theData.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomicWrite)
        }catch{
            
        }
        
        self.processDone()

    }

}
