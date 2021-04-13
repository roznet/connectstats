//  MIT License
//
//  Created on 13/04/2021 for ConnectStats
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

class GCConnectStatsRequestBackgroundFetch: GCConnectStatsRequest {
    static let kActivityRequestCount : UInt = 20
    private var searchMore : Bool = false
    private let start : UInt
    
    override init() {
        self.start = 0
        super.init()
    }
    
    init(nextWith current: GCConnectStatsRequestBackgroundFetch) {
        self.start = current.start + Self.kActivityRequestCount
        super.init(nextWith: current)
        
    }
    
    @objc override func preparedUrlRequest() -> URLRequest? {
        if self.isSignedIn(),
           let path = GCWebConnectStatsSearch(GCAppGlobal.webConnectsStatsConfig()){
            let params : [AnyHashable: Any] = [
                "token_id": self.tokenId,
                "start":self.start,
                "limit":Self.kActivityRequestCount
            ]
            return self.preparedUrlRequest(path, params: params)
        }
        return nil
    }
    
    @objc override func process() {
        guard let data = self.theString.data(using: .utf8)
        else {
            RZSLog.info("invalid data skipping background update")
            self.processDone()
            return

        }
        
        guard self.checkNoErrors()
        else {
            RZSLog.info("Failed to fetch skipping background update")
            self.processDone()
            return
        }
        RZSLog.info("starting async parsing")
        GCAppGlobal.worker().async {
            let parser = GCConnectStatsSearchJsonParser(data: data)
            RZSLog.info("finished parsing \(parser)")
            if parser.success,
               let activities = parser.activities{
                let register = GCActivitiesOrganizerListRegister(activities,
                                                                 from: GCService(.connectStats), isFirst: self.start == 0)
                register.add(to: GCAppGlobal.organizer())
                self.searchMore = register.shouldSearchForMore(with: Self.kActivityRequestCount, reloadAll: false)
                RZSLog.info("finished adding ")
            }
            self.processDone()
        }
    }
    @objc override var nextReq: GCWebRequestStandard? {
        if self.searchMore {
            return GCConnectStatsRequestBackgroundFetch(nextWith: self)
        }
        return nil
    }
}
