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
import RZExternalUniversal
import RZUtilsSwift
import ZIPFoundation

class GarminRequestFitFile: GarminRequest {
    
    struct Notifications {
        static let downloaded = Notification.Name("GarminRequestFitFile.downloaded")
    }
    
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
    
    func fitZipFileName() -> String {
        return "\(self.activityId).fit.zip"
    }

    func fitFileName() -> String {
        return "\(self.activityId).fit"
    }

    @objc override func process(_ theData: Data, andDelegate delegate: GCWebRequestDelegate) {
        let path = RZFileOrganizer.writeableFilePath(self.fitZipFileName())
        do {
            try theData.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomicWrite)
            if( try self.unzip() ){
                NotificationCenter.default.post(name: GarminRequestFitFile.Notifications.downloaded, object: self.activityId)
            }
            
        }catch let error as NSError{
            RZSLog.error( "\(error)")
        }catch{
            
        }
        
        delegate.processDone(self)
    }

    func unzip() throws -> Bool {
        var success = false
        
        let zipPath = RZFileOrganizer.writeableFilePath(self.fitZipFileName())
        guard let archive = Archive(url: URL(fileURLWithPath: zipPath), accessMode: .read) else {
            return success
        }
                
        var fitFileEntry : Entry? = nil
        for item in archive {
            if item.path.hasSuffix(".fit"){
                fitFileEntry = item
            }
        }
                
        if let fitFileEntry = fitFileEntry {
            do {
                let fitPath = RZFileOrganizer.writeableFilePath(self.fitFileName())
                _ = try archive.extract(fitFileEntry, to: URL(fileURLWithPath: fitPath))
                success = true
            }catch{
                    
            }
        }
        if success {
            RZFileOrganizer.removeEditableFile(self.fitZipFileName())
        }
        
        return success
    }
    
}
