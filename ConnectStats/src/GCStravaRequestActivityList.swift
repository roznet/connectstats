//  MIT License
//
//  Created on 26/12/2020 for ConnectStats
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



import UIKit
import RZUtilsSwift

@objc class GCStravaRequestActivityList: GCStravaRequestBase {
    
    let page : Int
    var searchMore : Bool = false
    let reloadAll : Bool
    var lastFoundDate : Date = Date()
    
    //MARK: - Initialisation
    
    @objc init(navigationController:UINavigationController, page:Int, reloadAll : Bool) {
        self.page = page
        self.reloadAll = reloadAll
        super.init(navigationController: navigationController)
    }
    
    init( previous : GCStravaRequestActivityList){
        self.page = previous.page+1
        self.reloadAll = previous.reloadAll
        self.lastFoundDate = previous.lastFoundDate
        super.init(previous:previous)
    }
    
    //MARK: - Information
    
    @objc func debugDescription() -> String {
        var info = "first"
        if self.page > 0 {
            info = String(format: "%@[%@]", (self.lastFoundDate as NSDate).yyyymmdd(),self.page)
        }
        if self.reloadAll {
            info.append("/all")
        }
        
        return String(format: "<%@: %@ %@>", NSStringFromClass(type(of: self)),
                      info, (self.urlDescription as NSString).truncateIfLongerThan(129, ellipsis: "..."))
    }
    override func description() -> String {
        return String(format: NSLocalizedString("Downloading Strava History... %@", comment: "Strava Request"),
                      (self.lastFoundDate as NSDate).dateFormatFromToday())
    }
    
    override func stravaUrl() -> URL? {
        return URL(string: "https://www.strava.com/api/v3/athlete/activities?page=\(self.page+1)")
    }

    func searchFileName(page : Int) -> String {
        return "last_strava_search_\(page).json"
    }
    
    //MARK: - Processing
    
    override func process(data : Data) {
        #if targetEnvironment(simulator)
        try? data.write(to: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(self.searchFileName(page: self.page))))
        #endif
        
        GCAppGlobal.worker().async {
            if let parser = GCStravaActivityListParser(data) {
                self.status = parser.status
                if  parser.status == GCWebStatus.OK {
                    GCAppGlobal.profile().serviceSuccess(gcService.strava)
                    self.stage = gcRequestStage.saving
                    DispatchQueue.main.async {
                        self.processNewStage()
                    }
                    self.addActivities(from: parser, to: GCAppGlobal.organizer())
                }
            }
            DispatchQueue.main.async {
                self.processDone()
            }
        }
    }
    
    func addActivities(from parser : GCStravaActivityListParser, to organizer: GCActivitiesOrganizer){
        let listRegister = GCActivitiesOrganizerListRegister(for: parser.activities, from:GCService(gcService.strava), isFirst: self.page == 0)
        listRegister.add(to: organizer)
        if listRegister.childIds != nil {
            RZSLog.warning("ChildIDs not supported for strava")
        }
        if let newDate = parser.activities.last?.date {
            self.lastFoundDate = newDate
        }
    }
    
    @objc override var nextReq: GCWebRequestStandard? {
        if self.searchMore {
            if self.reloadAll {
                DispatchQueue.main.async {
                    GCAppGlobal.profile().serviceAnchor(gcService.strava, set: self.page)
                    GCAppGlobal.saveSettings()
                }
            }
            
            if let validate = GCAppGlobal.web().validateNextSearch {
                if !validate(lastFoundDate,UInt(self.page)*30) {
                    return nil
                }
            }
            
            return GCStravaRequestActivityList(previous: self)
        }
        if self.reloadAll {
            DispatchQueue.main.async {
                GCAppGlobal.profile().serviceCompletedFull(gcService.strava, set: true)
                GCAppGlobal.saveSettings()
            }
        }
        return nil
    }
    
    //MARK: - Testing functions
    
    @discardableResult
    @objc static func test(organizer: GCActivitiesOrganizer, path : String) -> GCActivitiesOrganizer{
        return self.test(organizer: organizer, path: path, start: 0)
    }
    
    @discardableResult
    @objc static func test(organizer: GCActivitiesOrganizer, path : String, start : Int) -> GCActivitiesOrganizer{
        let search = GCStravaRequestActivityList(navigationController: UINavigationController(), page: start, reloadAll: false)
        
        var isDirectory : ObjCBool = false
        
        if FileManager.default.fileExists(atPath:path, isDirectory: &isDirectory) {
            var fileURL = URL(fileURLWithPath: path)
            if isDirectory.boolValue {
                fileURL.appendPathComponent(search.searchFileName(page: start))
            }
            if let data = try? Data(contentsOf: fileURL) {
                if let parser = GCStravaActivityListParser(data) {
                    search.addActivities(from: parser, to: organizer)
                }
            }
        }
        return organizer
    }

}
