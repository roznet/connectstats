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



import UIKit
import RZUtilsSwift

class GCStravaRequestStreams: GCStravaRequestBase {

    let activity : GCActivity
    var points : [GCTrackPoint]? = nil
    
    //MARK: - Initialization
    
    @objc init(navigationController:UINavigationController, activity : GCActivity) {
        self.activity = activity
        super.init(navigationController: navigationController)
    }
    
    init(previous:GCStravaRequestStreams){
        self.activity = previous.activity
        self.points = previous.points
        super.init(previous:previous)
    }
    
    //MARK: - Information
    
    func stravaActivityId() -> String? {
        return GCService(gcService.strava)?.serviceId(fromActivityId: self.activity.activityId)
    }

    override func stravaUrl() -> URL? {
        if let sid = self.stravaActivityId() {
            if points == nil {
                return URL(string: "https://www.strava.com/api/v3/activities/\(sid)/streams/latlng,heartrate,time,altitude,cadence,watts,velocity_smooth" )
            }else{
                return URL(string: "https://www.strava.com/api/v3/activities/\(sid)/laps" )
            }
        }
        return nil
    }
    
    override func description() -> String {
        return String(format: NSLocalizedString("Downloading Strava Detail... %@", comment: "Strava Request"),
                      (self.activity.date as NSDate).dateFormatFromToday())
    }
    
    @objc func debugDescription() -> String {
        let info = String(describing: self.activity)
        
        return String(format: "<%@: %@ %@>", NSStringFromClass(type(of: self)),
                      info, (self.urlDescription as NSString).truncateIfLongerThan(129, ellipsis: "..."))
    }

    //MARK: - Processing
    
    func saveDataFileURL() -> URL {
        let sid : String = self.stravaActivityId() ?? self.activity.activityId
        if self.points == nil {
            return URL( fileURLWithPath: "strava_stream_\(sid).json")
        }else{
            return URL( fileURLWithPath:  "strava_laps_\(sid).json")
        }
    }
    
    override func process(data: Data) {
        try? data.write(to: self.saveDataFileURL())
        
        GCAppGlobal.worker().async {
            if self.points == nil {
                self.parseStreams(data: data)
            }else{
                self.parseLaps( data: data)
            }
        }
    }
    
    func parseStreams(data : Data){
        if let parser = GCStravaActivityStreamsParser(data) {
            self.points = parser.points
            self.status = parser.status
        }else{
            self.status = GCWebStatus.parsingFailed
        }
        DispatchQueue.main.async {
            self.processDone()
        }
    }
    
    func parseLaps(data : Data ){
        if let parser = GCStravaActivityLapsParser(data, withPoints: self.points, in: self.activity) {
            GCAppGlobal.organizer().registerActivity(self.activity.activityId, withTrackpoints: self.points, andLaps: parser.laps)
        }
        self.points = nil
        DispatchQueue.main.async {
            self.processDone()
        }
    }
    
    override var nextReq: GCWebRequestStandard! {
        guard self.status == GCWebStatus.OK else {
            return nil;
        }
        
        if self.points != nil {
            return GCStravaRequestStreams(previous: self)
        }
        
        return nil
    }
}
