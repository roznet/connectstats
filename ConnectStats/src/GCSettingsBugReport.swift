//  MIT License
//
//  Created on 17/12/2020 for ConnectStats
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



import Foundation
import DeviceGuru
import ZIPFoundation
import RZUtilsSwift


extension GCSettingsBugReport {
    
    @discardableResult
    @objc func createBugReportArchive() -> Bool {
        let bugPath = RZFileOrganizer.writeableFilePath(kBugFilename)
        let bugPathURL = URL(fileURLWithPath: bugPath )
        var archiveSucess = true
        
        let archive = Archive(url: bugPathURL, accessMode: .create)
        
        if let data = RZLogFileContent().data(using: .utf8){
            do {
                try archive?.addEntry(with: "bugreport.log",
                                      type: .file,
                                      uncompressedSize: UInt32(data.count),
                                      provider: { (position,size) -> Data in
                                        return data.subdata(in: position..<position+size)
                                      })
            }catch{
                RZSLog.error("bug archive error for log \(error)")
                archiveSucess = false
            }
        }
        if let jsonMissingFields = self.missingFieldsAsJson {
            do {
                try archive?.addEntry(with: "missing_fields.json",
                                      type: .file,
                                      uncompressedSize: UInt32(jsonMissingFields.count),
                                      provider: { (position,size) -> Data in
                                        return jsonMissingFields.subdata(in: position..<position+size)
                                      })
            }catch{
                RZSLog.error("bug archive error for missingJson \(error)")
                archiveSucess = false
            }
        }
        if self.includeErrorFiles {
            let errors = GCActivitiesCacheManagement.errorFiles()
            do {
                for filename in errors {
                    let pathUrl = URL(fileURLWithPath: filename)
                    
                    try archive?.addEntry(with: pathUrl.lastPathComponent, relativeTo: pathUrl.deletingLastPathComponent())
                }
            }catch{
                RZSLog.error("bug archive error for error files \(error)")
                archiveSucess = false
            }
        }
        if self.includeActivityFiles {
            if let activity = GCAppGlobal.organizer().currentActivity() {
                let adbURL = URL( fileURLWithPath: activity.trackDbFileName)
                do {
                    try archive?.addEntry(with: adbURL.lastPathComponent, relativeTo: adbURL.deletingLastPathComponent())
                }catch{
                    RZSLog.error("bug archive error for acivity \(activity) \(error)")
                    archiveSucess = false
                }
            }
            if let currentDatabasePath = GCAppGlobal.profile().currentDatabasePath() {
                let dbURL = URL( fileURLWithPath:RZFileOrganizer.writeableFilePath(currentDatabasePath ))
                do {
                    try archive?.addEntry(with: "activities_bugreport.db", fileURL: dbURL)
                }catch{
                    RZSLog.error("bug archive error for activity database \(error)")
                    archiveSucess = false
                }
            }
            /* derived is too big
            if let currentDerivedPath = GCAppGlobal.profile().currentDerivedDatabasePath() {
                let dbURL = URL( fileURLWithPath:RZFileOrganizer.writeableFilePath(currentDerivedPath ))
                do {
                    try archive?.addEntry(with: "derived_bugreport.db", fileURL: dbURL)
                }catch{
                    RZSLog.error("bug archive error for derived \(error)")
                    archiveSucess = false
                }
            }
             */
        }
        
        if let settingsPath = RZFileOrganizer.writeableFilePathIfExists("settings.plist") {
            let settingsURL = URL(fileURLWithPath: settingsPath )
            do {
                try archive?.addEntry(with: "settings_bugreport.plist", fileURL: settingsURL)
            }catch{
                RZSLog.error("bug archive error for settings \(error)")
                archiveSucess = false
            }
        }
        
        if let jsonSettings = GCAppGlobal.settings().withJSONTypesOnly(){
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonSettings,
                                                          options: [JSONSerialization.WritingOptions.prettyPrinted,JSONSerialization.WritingOptions.sortedKeys])
                try archive?.addEntry(with: "settings_bugreport.json",
                                      type: .file,
                                      uncompressedSize: UInt32(jsonData.count),
                                      provider: { (position,size) -> Data in
                                        return jsonData.subdata(in: position..<position+size)
                                      })
            }catch{
                RZSLog.error("bug archive error for json settings \(error)")
                archiveSucess = false
            }
        }
        
        return archiveSucess
    }
    
    @objc func createBugReportDictionary(extra : [String:String] ) -> [String:String] {
        
        let applicationName = GCAppGlobal.connectStatsVersion() ? "ConnectStats" : "HealthStats"
        let buildString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let device = UIDevice()
        let deviceGuru = DeviceGuru()
        let commonid = GCAppGlobal.configGet(CONFIG_BUG_COMMON_ID, defaultValue: kBugNoCommonId) ?? kBugNoCommonId
        
        var rv : [String:String] = [
            "systemName" : device.systemName,
            "systemVersion": device.systemVersion,
            "applicationName" : applicationName,
            "version" : versionString ?? "Unknown Version",
            "build" : buildString ?? "Unknown Build",
            "platformString": deviceGuru.hardwareDescription() ?? "Unknown Device",
            "commonid" : commonid
        ]
        extra.forEach { (k,v) in rv[k] = v }
        
        if( commonid != kBugNoCommonId ){
            RZSLog.info("Had previous bug report: id=\(commonid)")
        }
        
        return rv
    }
}
