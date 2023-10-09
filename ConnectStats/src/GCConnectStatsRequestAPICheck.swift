//  MIT License
//
//  Created on 08/10/2023 for ConnectStats
//
//  Copyright (c) 2023 Brice Rosenzweig
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
import UIKit
import RZUtilsSwift

extension gcWebConnectStatsConfig {
    func asInt() -> Int {
        switch self {
        case .productionRozNet: return 0
        case .productionConnectStatsApp: return 1
        case .remoteDevTesting: return 2
        case .localProdTesting: return 3
        case .localDevTesting: return 4
        case .end: return 5
        default: return 5
        }
    }
}
class GCConnectStatsRequestAPICheck : GCConnectStatsRequest {
    struct APIStatus : Codable {
        let status : Int
        let redirect : String?
    }
    
    @objc override func preparedUrlRequest() -> URLRequest? {
        if let url = URL(string: GCWebConnectStatsApiCheck(GCAppGlobal.webConnectsStatsConfig())){
            return URLRequest(url: url)
        }
        return nil
    }

    @objc override func process(_ theData: Data, andDelegate delegate: GCWebRequestDelegate) {
        self.delegate = delegate
       
        do {
            let api = try JSONDecoder().decode(APIStatus.self, from: theData)
            if api.status == 1 {
                RZSLog.info("Api Check Success")
                if let redirect = api.redirect {
                    let redirectConfig = GCWebConnectStatsConfigForRedirect(redirect)
                    let currentConfig = GCAppGlobal.webConnectsStatsConfig()
                    if redirectConfig != gcWebConnectStatsConfig.end && redirectConfig != currentConfig {
                        RZSLog.info("API Check requesting redirect from \(GCWebConnectStatsApiCheck(currentConfig)) to \(GCWebConnectStatsApiCheck(redirectConfig))")
                        GCAppGlobal.profile().configSet(CONFIG_CONNECTSTATS_CONFIG, intVal: redirectConfig.asInt())
                        GCAppGlobal.saveSettings()
                    }else{
                        RZSLog.info("API Check already redirected to \(GCWebConnectStatsApiCheck(redirectConfig))")

                    }
                }
            }
        }catch{
            RZSLog.error("API Check Failed to decode \(error)")
        }
        self.processDone()
    }
    
    @objc override var nextReq: GCWebRequestStandard? {
        return nil
    }
    
    @objc override func remediationReq() -> GCWebRequest? {
        return nil
    }

    @objc override func priorityRequest() -> Bool {
        return true
    }
}
