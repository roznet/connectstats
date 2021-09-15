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
    
    override init(activity: GCActivity) {
        super.init(activity:activity)
    }
    
    @objc override func preparedUrlRequest() -> URLRequest? {
        if self.isSignedIn(),
           let path = GCWebConnectStatsFitFile(GCAppGlobal.webConnectsStatsConfig()),
           let aid = self.activity.service.serviceId(fromActivityId: self.activity.activityId){
            let params : [AnyHashable:Any] = [
                "token_id": self.tokenId,
                "activity_id": aid,
                "background":1
            ]
            return self.preparedUrlRequest(path, params: params)
        }
        return nil
    }
    
    @objc override func process(_ theData: Data, andDelegate delegate: GCWebRequestDelegate) {
        self.delegate = delegate
        
        guard let filename = self.fileName() else {
            self.processDone()
            return
        }
        
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
            self.processParse(filename)
        }
    }

    @objc override var nextReq: GCWebRequestStandard? {
        return nil
    }
    
    @objc override func remediationReq() -> GCWebRequest? {
        return nil
    }

    @discardableResult
    @objc static func test(activity: GCActivity, path : String) -> GCActivity?{
        let req = GCConnectStatsRequestBackgroundFitFile(activity: activity)
        
        var isDirectory :ObjCBool = false
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
