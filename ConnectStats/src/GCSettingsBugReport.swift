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
    
    @objc func createBugReportArchive() {
        let bugPath = RZFileOrganizer.writeableFilePath(kBugFilename)
        let bugPathURL = URL(fileURLWithPath: bugPath )
        
        
        let archive = Archive(url: bugPathURL, accessMode: .create)
        do {
            if let data = RZLogFileContent().data(using: .utf8){
                try archive?.addEntry(with: "bugreport.log",
                                      type: .file,
                                      uncompressedSize: UInt32(data.count),
                                      provider: { (position,size) -> Data in
                                        return data.subdata(in: position..<position+size)
                                      })
            }
            if let jsonMissingFields = self.missingFieldsAsJson {
                try archive?.addEntry(with: "missing_fields.json",
                                      type: .file,
                                      uncompressedSize: UInt32(jsonMissingFields.count),
                                      provider: { (position,size) -> Data in
                                        return jsonMissingFields.subdata(in: position..<position+size)
                                      })

            }
            if self.includeErrorFiles {
                let errors = GCActivitiesCacheManagement.errorFiles()
                for filename in errors {
                    let pathUrl = URL(fileURLWithPath: filename)

                    try archive?.addEntry(with: pathUrl.lastPathComponent, relativeTo: pathUrl.deletingLastPathComponent())
                }
            }
            if self.includeActivityFiles {
                if let activity = GCAppGlobal.organizer()?.currentActivity() {
                    let adbURL = URL( fileURLWithPath: activity.trackDbFileName)
                    try archive?.addEntry(with: adbURL.lastPathComponent, relativeTo: adbURL.deletingLastPathComponent())
                }
                if let currentDatabasePath = GCAppGlobal.profile()?.currentDatabasePath() {
                    let dbURL = URL( fileURLWithPath:RZFileOrganizer.writeableFilePath(currentDatabasePath ))
                    try archive?.addEntry(with: "activities_bugreport.db", fileURL: dbURL)
                }
                if let currentDerivedPath = GCAppGlobal.profile()?.currentDerivedDatabasePath() {
                    let dbURL = URL( fileURLWithPath:RZFileOrganizer.writeableFilePath(currentDerivedPath ))
                    try archive?.addEntry(with: "derived_bugreport.db", fileURL: dbURL)
                }
            }
            
            if let settingsPath = RZFileOrganizer.writeableFilePathIfExists("settings.plist") {
                let settingsURL = URL(fileURLWithPath: settingsPath )
                try archive?.addEntry(with: "settings_bugreport.plist", fileURL: settingsURL)
            }
            
            if let jsonSettings = GCAppGlobal.settings().withJSONTypesOnly(){
                let jsonData = try JSONSerialization.data(withJSONObject: jsonSettings,
                                                          options: [JSONSerialization.WritingOptions.prettyPrinted,JSONSerialization.WritingOptions.sortedKeys])
                try archive?.addEntry(with: "settings_bugreport.json",
                                      type: .file,
                                      uncompressedSize: UInt32(jsonData.count),
                                      provider: { (position,size) -> Data in
                                        return jsonData.subdata(in: position..<position+size)
                                      })
            }

        }catch{
            RZSLog.error("Failed to create zip file \(bugPath)")
        }
        
    }
    
    @objc func createBugReportDictionary(extra : [String:String] ) -> [String:String] {
        
        let applicationName = GCAppGlobal.connectStatsVersion() ? "ConnectStats" : "HealthStats"
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        let device = UIDevice()
        let deviceGuru = DeviceGuru()
        let commonid = GCAppGlobal.configGet(CONFIG_BUG_COMMON_ID, defaultValue: kBugNoCommonId) ?? kBugNoCommonId
        
        var rv : [String:String] = [
            "systemName" : device.systemName,
            "systemVersion": device.systemVersion,
            "applicationName" : applicationName,
            "version" : versionString ?? "Unknown Version",
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
