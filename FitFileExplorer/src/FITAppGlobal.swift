//  MIT License
//
//  Created on 06/01/2019 for FitFileExplorer
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
import GenericJSON

class FITAppGlobal {
    
    enum ConfigParameters : String {
        case loginName = "loginName"
        case password = "password"
    }
    
    static let shared = FITAppGlobal()
    
    var settings : JSON
    let web : GCWebConnect
    let worker : DispatchQueue
    let activityTypes : GCActivityTypes
    let downloadManager : FITGarminDownloadManager
    
    private init() {
        settings = [:]
        if let fp = RZFileOrganizer.writeableFilePathIfExists("settings.json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: fp)){
            let decoder = JSONDecoder()
            if let read = try? decoder.decode(JSON.self, from: data) {
                settings = read
            }
        }
        web = GCWebConnect()
        worker = DispatchQueue.init(label: "net.ro-z.worker")
        activityTypes = GCActivityType.activityTypes()
        downloadManager = FITGarminDownloadManager()
        
        let cache = GCFieldCache(db: nil, andLanguage: nil)
        GCField.setFieldCache(cache)
        GCFields.setFieldCache(cache)
    }
    
    static func configSet(_ key : String, stringVal: String){
        if let update = try? JSON( [key:stringVal]) {
            self.shared.updateSettings(json: update)
        }
    }
    
    
    static func currentLoginName() -> String {
        if let name = self.shared.settings[ConfigParameters.loginName.rawValue]?.stringValue {
            return name
        }
        return "default"
    }
    static func currentPassword() -> String {
        if let pwd = self.shared.settings[ConfigParameters.password.rawValue]?.stringValue {
            return pwd
        }
        return ""
    }
    
    static func web() -> GCWebConnect {
        return self.shared.web
    }
    
    static func downloadManager() -> FITGarminDownloadManager {
        return self.shared.downloadManager
    }
    
    static func worker() -> DispatchQueue {
        return self.shared.worker
    }
    
    static func settings() -> JSON {
        return self.shared.settings
    }
    
    func updateSettings( json : JSON ){
        self.settings = self.settings.merging(with: json)
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self.settings) {
            do {
                try data.write(to: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath("settings.json") ), options: Data.WritingOptions.atomic)
            }catch{
                
            }
        }
    }
}
