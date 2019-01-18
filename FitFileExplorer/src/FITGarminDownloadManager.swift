//  MIT License
//
//  Created on 22/11/2018 for FitFileExplorer
//
//  Copyright (c) 2018 Brice Rosenzweig
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
import GenericJSON

class FITGarminDownloadManager: NSObject,RZChildObject {
    struct Notifications {
        static let garminDownloadChange = Notification.Name("garminDownloadChange")
    }
    
    var loginSuccessful : Bool
    
    override init() {
        loginSuccessful = false
        
        super.init()
        
        //self.loadRawFiles()
    }
    deinit {
        FITAppGlobal.shared.web.detach(self)
    }
    
    
    func clear(){
        
    }
    func loadFromFile() {
        
        let fp = URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(FITAppGlobal.currentLoginName()+".json"))
        if let jsonData = try? Data(contentsOf: fp),
            let json = try? JSONDecoder().decode(JSON.self, from: jsonData){
            _ = FITAppGlobal.shared.organizer.load(json: json)
        }
    }
    func saveToFile(){
        if( FITAppGlobal.currentLoginName().count > 0){
            if let json = try? FITAppGlobal.shared.organizer.json(),
                let data = try? JSONEncoder().encode(json){
                let fp = URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(FITAppGlobal.currentLoginName()+".json"))
                try? data.write(to: fp)
            }
            
        }
    }
    
    func notifyCallBack(_ theParent: Any!, info theInfo: RZDependencyInfo!) {
        
        if theInfo.stringInfo == NOTIFY_END {
            NotificationCenter.default.post(name: FITGarminDownloadManager.Notifications.garminDownloadChange, object: self)
        }else if theInfo.stringInfo == NOTIFY_NEXT {
            NotificationCenter.default.post(name: FITGarminDownloadManager.Notifications.garminDownloadChange, object: self)
        }else if theInfo.stringInfo == NOTIFY_ERROR {
            
        }
    }
    
    func startDownload(){
        FITAppGlobal.web().attach(self)
        
        if( self.loginSuccessful != true ){
            let login = FITAppGlobal.currentLoginName()
            let passd = FITAppGlobal.currentPassword()
            
            FITAppGlobal.web().addRequest(GCGarminLoginSSORequest(user: login, andPwd: passd))
        }
        FITAppGlobal.web().addRequest(GarminRequestActivityList(start: 0))
    }
    
    @objc func loadOneFile(filePath : String) -> Int {
        
        let res = FITAppGlobal.shared.organizer.load(url: URL(fileURLWithPath: filePath))
        
        return res.updated
    }
    
    func loadRawFiles() {
        FITAppGlobal.worker().async {
            let files = RZFileOrganizer.writeableFiles { (s) -> Bool in
                s.hasPrefix("last_modern_search")
            }
            var count = 0
            
            for fn in files {
                _ = FITAppGlobal.shared.organizer.load(url: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath(fn)))
                count+=1
                if( count == 5){
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: FITGarminDownloadManager.Notifications.garminDownloadChange, object: self)
                    }
                }
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: FITGarminDownloadManager.Notifications.garminDownloadChange, object: self)
            }
        }
    }

    func samples() -> [String:GCNumberWithUnit] {
        let fields  = FITAppGlobal.shared.organizer.sample().numbers
        return fields
    }
 
    func allFields() -> [String] {
        return Array(self.samples().keys)
    }
    
}


