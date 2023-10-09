//  MIT License
//
//  Created on 03/06/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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



import UIKit
import RZUtilsSwift

class GCConnectStatsRequestBackgroundFitFile: GCConnectStatsRequestFitFile {
    let requestMode : gcRequestMode
    private let cache : GCWebRequestCache
    
    @objc init(activity: GCActivity, requestMode : gcRequestMode, cacheDb : FMDatabase) {
        self.requestMode = requestMode
        self.cache = GCWebRequestCache(db: cacheDb, classname: String(describing: type(of: self)))
        super.init(activity:activity)
    }
    
    @objc override func preparedUrlRequest() -> URLRequest? {
        switch self.requestMode {
        case .downloadAndProcess,.downloadAndCache:
            
            if self.isSignedIn(),
               let aid = self.activity.service.serviceId(fromActivityId: self.activity.activityId){
                let path = GCWebConnectStatsFitFile(GCAppGlobal.webConnectsStatsConfig())
                let params : [AnyHashable:Any] = [
                    "token_id": self.tokenId,
                    "activity_id": aid,
                    "background":1
                ]
                return self.preparedUrlRequest(path, params: params)
            }
        default:
            break
        }
        return nil
    }

    @objc override func process(_ theData: Data, andDelegate delegate: GCWebRequestDelegate) {
        self.delegate = delegate
        
        guard let filename = self.fileName() else {
            self.processDone()
            return
        }

        switch self.requestMode {
        case .downloadAndProcess:
            let fileurl = URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(filename))
            
            do {
                try theData.write(to: fileurl, options: .atomic)
            } catch {
                RZSLog.error("Failed to save \(filename)")
                self.processDone()
                return
            }
            self.stage = gcRequestStage.parsing
            GCAppGlobal.worker().async {
                self.processParseData(theData, filePath: fileurl.path)
            }

        case .downloadAndCache:
            self.cache.save(data: theData, filename: filename)
            self.processDone()
        default:
            RZSLog.warning("Inconsistency, caching should not download data")
            self.process(nil, encoding: String.Encoding.utf8.rawValue, andDelegate: delegate)
            return
        }
    }

    // this is only called if noURL/no data, for cache processing
    @objc override func process(_ theString: String?, encoding: UInt, andDelegate delegate: GCWebRequestDelegate) {
        let searchMore = self.cache.retrieve() {
            data in
            self.processParseData(data, filePath: self.fitFileName)
            self.processDone()
            return true
        }
        if( !searchMore ){
            self.processDone()
        }
    }
    
    @objc override var nextReq: GCWebRequestStandard? {
        return nil
    }
    
    @objc override func remediationReq() -> GCWebRequest? {
        return nil
    }

    @discardableResult
    @objc static func test(activity: GCActivity, path : String, mode:gcRequestMode) -> GCActivity?{
        let req = GCConnectStatsRequestBackgroundFitFile(activity: activity, requestMode:.processCache, cacheDb: activity.db!)
        
        var isDirectory : ObjCBool = false
        let filename = req.fitFileName
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            var fileUrl = URL(fileURLWithPath: path)

            if isDirectory.boolValue {
                fileUrl.appendPathComponent(filename)
            }
            req.processParse(fileUrl.path)
        }
        return req.activity
    }

}
