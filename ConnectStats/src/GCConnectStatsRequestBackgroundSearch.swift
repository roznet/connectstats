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

class GCConnectStatsRequestBackgroundSearch: GCConnectStatsRequest, @unchecked Sendable {
    
    static let kActivityRequestCount : UInt = 20
    private var searchMore : Bool = false
    private let start : UInt
    private let requestMode : gcRequestMode
    private let cache : GCWebRequestCache
    
    // by default try to download up to 5 tracks/activities
    var loadTracks = 5
    var addedActivities : [GCActivity] = []
    
    @objc init(requestMode : gcRequestMode, cacheDb : FMDatabase) {
        self.start = 0
        self.requestMode = requestMode
        self.cache = GCWebRequestCache(db: cacheDb, classname: String(describing: type(of: self)))
        super.init()
    }
    
    init(nextWith current: GCConnectStatsRequestBackgroundSearch) {
        self.start = current.start + Self.kActivityRequestCount
        self.requestMode = current.requestMode
        self.cache = current.cache
        super.init(nextWith: current)
    }
    
    override var urlDescription: String! {
        return GCWebConnectStatsSearch(GCAppGlobal.webConnectsStatsConfig())
    }
    
    @objc override func preparedUrlRequest() -> URLRequest? {
        switch self.requestMode {
        case .downloadAndProcess,.downloadAndCache:
            if self.isSignedIn(){
                let path = GCWebConnectStatsSearch(GCAppGlobal.webConnectsStatsConfig())
                let params : [AnyHashable: Any] = [
                    "token_id": self.tokenId,
                    "start":self.start,
                    "limit":Self.kActivityRequestCount,
                    "background":1
                ]
                return self.preparedUrlRequest(path, params: params)
            }else{
                RZSLog.warning("Not signed in")
            }
        default:
            return nil
        }
        return nil
    }
    
    func searchFileName(page : UInt) -> String {
        return "last_connectstats_search_\(page).json"
    }

    func processSaveDataToCache() {
        guard let data = self.theString?.data(using: .utf8)
        else {
            RZSLog.info("invalid data skipping background update")
            self.processDone()
            return
        }
        
        self.cache.save(data: data, filename: self.searchFileName(page: self.start))
        
        self.processDone()
    }
    
    func processDataFromCache(){
        self.searchMore = self.cache.retrieve() {
            data in
            self.process(parse: data)
            return true
        }
        if( !self.searchMore ){
            self.processDone()
        }
    }
    
    func processDataAndParse(){
        guard let data = self.theString?.data(using: .utf8)
        else {
            RZSLog.info("invalid data skipping background update")
            self.processDone()
            return
        }
        
        self.process(parse: data)
    }
    
    func process(parse data : Data){
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
            if parser.success{
                self.addActivities(from: parser, to: GCAppGlobal.organizer())
            }
            self.processDone()
        }

    }
    
    @objc override func process() {
        switch self.requestMode {
        case .downloadAndProcess:
            self.processDataAndParse()
        case .downloadAndCache:
            self.processSaveDataToCache()
        case .processCache:
            self.processDataFromCache()
        default:
            self.processDataAndParse()
        }
    }
    
    func addActivities(from parser : GCConnectStatsSearchJsonParser, to organizer: GCActivitiesOrganizer){
        let listRegister = GCActivitiesOrganizerListRegister(for: parser.activities, from:GCService(gcService.connectStats), isFirst: self.start == 0)
        listRegister.updateNewOnly = true;
        // don't use the normal download track, we'll use dedicated background load
        listRegister.loadTracks = 0;
        listRegister.add(to: organizer)
        if listRegister.childIds != nil {
            RZSLog.warning("ChildIDs not supported for connectstats")
        }
        if let addedActivities = listRegister.addedActivities {
            self.addedActivities.append(contentsOf: addedActivities)
            RZSLog.info("Found new activities, background downloading trackpoints for \(addedActivities.count) activities")
            for act in addedActivities {
                if self.loadTracks > 0 {
                    let req = GCConnectStatsRequestBackgroundFitFile(activity: act, requestMode: self.requestMode, cacheDb: organizer.db)
                    GCAppGlobal.web().add(req)
                    self.loadTracks -= 1
                }
            }
        }
        self.searchMore = listRegister.shouldSearchForMore(with: Self.kActivityRequestCount, reloadAll: false)
    }
    
    @objc override var nextReq: GCWebRequestStandard? {
        if self.searchMore {
            return GCConnectStatsRequestBackgroundSearch(nextWith: self)
        }
        return nil
    }
    
    @discardableResult
    @objc static func test(organizer: GCActivitiesOrganizer, path : String, mode: gcRequestMode) -> GCActivitiesOrganizer{
        let search = GCConnectStatsRequestBackgroundSearch(requestMode: .processCache, cacheDb: organizer.db)
        
        var isDirectory : ObjCBool = false
        
        if FileManager.default.fileExists(atPath:path, isDirectory: &isDirectory) {
            var fileURL = URL(fileURLWithPath: path)
            if isDirectory.boolValue {
                fileURL.appendPathComponent(search.searchFileName(page: 0))
            }
            if( mode == .processCache){
                search.cache.retrieve(){
                    data in
                    let parser = GCConnectStatsSearchJsonParser(data: data)
                    if parser.success {
                        search.loadTracks = 0
                        search.addActivities(from: parser, to: organizer)
                    }
                    return true
                }
            }else{
                if let data = try? Data(contentsOf: fileURL) {
                    switch mode {
                    case .downloadAndCache:
                        search.theString = String(data: data, encoding: .utf8)
                        search.processSaveDataToCache()
                    case .downloadAndProcess:
                        let parser = GCConnectStatsSearchJsonParser(data: data)
                        if parser.success {
                            search.loadTracks = 0
                            search.addActivities(from: parser, to: organizer)
                        }
                        if isDirectory.boolValue && search.addedActivities.count > 0 {
                            for act in search.addedActivities {
                                GCConnectStatsRequestBackgroundFitFile.test(activity: act, path: path, mode: .downloadAndProcess)
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
        return organizer
        
    }
}
