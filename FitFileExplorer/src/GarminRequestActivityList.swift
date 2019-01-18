//  MIT License
//
//  Created on 05/01/2019 for FitFileExplorer
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

class GarminRequestActivityList: GarminRequest {

    static let kActivityRequestCount : UInt = 20
    
    let currentIndex : UInt
    var lastFoundDate : Date
    var parseCount : Int = 0
    
    init(start : UInt) {
        currentIndex = start
        lastFoundDate = Date()
        
        super.init()
    }
    
    init(nextFrom : GarminRequestActivityList) {
        currentIndex = nextFrom.currentIndex + GarminRequestActivityList.kActivityRequestCount
        lastFoundDate = nextFrom.lastFoundDate
        
        super.init()
    }
    
    @objc override func url() -> String {
        return GCWebModernSearchURL(self.currentIndex, GarminRequestActivityList.kActivityRequestCount)
    }
    
    @objc override func description() -> String {
        switch self.stage {
        case gcRequestStage.download:
            return "Downloading History... \(self.lastFoundDate)"
        case gcRequestStage.parsing:
            return "Parsing History... \(self.lastFoundDate)"
        case gcRequestStage.saving:
            return "Saving History... \(self.lastFoundDate)"
        }
    }
    
    func searchFileName(page: UInt) -> String {
        return "last_modern_search_\(page).json"
    }
    
    @objc override func process() {
        
        let path = RZFileOrganizer.writeableFilePath(self.searchFileName(page:self.currentIndex))
        do {
            try self.theString.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        }catch{
            
        }
        self.stage = gcRequestStage.parsing
        DispatchQueue.main.async {
            self.processNewStage()
        }
        if self.checkNoErrors() {
            self.status = GCWebStatus.OK
            self.delegate.loginSuccess(gcWebService.garmin)
            self.parseCount = FITAppGlobal.downloadManager().loadOneFile(filePath: path)
            if self.parseCount > 0 {
                self.lastFoundDate = FITAppGlobal.shared.organizer.lastDate()
                self.nextReq = GarminRequestActivityList(nextFrom: self)
            }
        }
        
        self.processDone()
    }
}
