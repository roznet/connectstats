//  MIT License
//
//  Created on 12/11/2018 for FitFileExplorer
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
import RZUtils
import RZUtilsOSX
import RZExternalUniversal
import GenericJSON

extension Date {
    func formatAsRFC3339() -> String {
        return (self as NSDate).formatAsRFC3339()
    }
}
extension GCField {
    func columnName() -> String {
        return self.key + ":" + self.activityType
    }
    func fileName(activityId : String) -> String {
        return activityId + "_" + self.key + "_" + self.activityType
    }
}

class FITDownloadViewController: NSViewController {
    
    let keychain = KeychainWrapper(serviceName: "net.ro-z.FitFileExplorer")
    
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    
    @IBOutlet weak var activityTable: NSTableView!
    @IBOutlet weak var rightStatus: NSTextField!
    @IBOutlet weak var leftStatus: NSTextField!
    
    var dataSource = FITDownloadListDataSource()
    
    // MARK: -
    
    @IBAction func refresh(_ sender: Any) {
        activityTable.dataSource = self.dataSource
        activityTable.delegate = self.dataSource
        FITAppGlobal.downloadManager().startDownloadList()
    }

    @IBAction func downloadSamples(_ sender: Any) {
        activityTable.dataSource = self.dataSource
        activityTable.delegate = self.dataSource
        FITAppGlobal.downloadManager().loadRawFiles()

    }
    
    @IBAction func openFitFile(_ sender: Any) {
        let row = self.activityTable.selectedRow
        if (row > -1) {
            let act = dataSource.list()[row]
            if act.downloaded, let url = act.fitFilePath {
                
                NSDocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: {(doc,bool,err) in })

            }else{
            
                NotificationCenter.default.addObserver(self, selector: #selector(notificationNewFitFile(notification:)),
                                                       name: GarminRequestFitFile.Notifications.downloaded, object: nil)
                
                FITAppGlobal.downloadManager().startDownloadFitFile(activityId: act.activityId)
            }
        }else{
            print("No selection, nothing to download")
        }

    }
    @IBAction func downloadFITFile(_ sender: Any) {
        let row = self.activityTable.selectedRow
        if (row > -1) {
            let act = dataSource.list()[row].activityId
            
            print("Download \(row) \(act)")
            NotificationCenter.default.addObserver(self, selector: #selector(notificationNewFitFile(notification:)),
                                                   name: GarminRequestFitFile.Notifications.downloaded, object: nil)

            FITAppGlobal.downloadManager().startDownloadFitFile(activityId: act)
            
        }else{
            print("No selection, nothing to download")
        }
    }

    @objc func downloadChanged(notification : Notification){
        DispatchQueue.main.async {
            self.rebuildColumns()
            self.activityTable.reloadData()
            self.updateStatus()
        }
    }
    
    @objc func notificationNewFitFile(notification:Notification){
        if let activityId = notification.object as? String {
            print( "Success Downloaded \(activityId)")
            if let fp = RZFileOrganizer.writeableFilePathIfExists("\(activityId).fit") {
                NSDocumentController.shared.openDocument(withContentsOf: URL(fileURLWithPath: fp), display: true, completionHandler: {(doc,bool,err) in })
            }
        }
    }

    // MARK: -
    
    func exportByFile() {
        var units : [String:GCUnit] = [:]
        
        for activity  in self.dataSource.list() {
            
            if let path =  activity.fitFilePath,
                
                let fitFile = RZFitFile(file: path) {
                let interpret = FITFitFileInterpret(fitFile: fitFile)
                let cols = interpret.columnDataSeries(messageType: FIT_MESG_NUM_RECORD)
                
                for (key,values) in cols.values {
                    var dcols =  [ ["activityId","time",key,"uom"].joined(separator: ",") ]
                    
                    for val in values {
                        let row = [activity.activityId,val.time.formatAsRFC3339(),"\(val.value.value)",val.value.unit.key]
                        dcols.append(row.joined(separator: ","))
                    }
                    
                    if( units[ key ] == nil){
                        if let first = values.first?.value {
                            units[key] = first.unit
                        }
                    }
                    let fn = URL(fileURLWithPath: RZFileOrganizer.writeableFilePath("\(key)_\(activity.activityId).csv"))
                    do {
                        try dcols.joined(separator: "\n").write(to: fn, atomically: true, encoding: .utf8)
                    }catch { }
                }
                
                
                let fn = URL(fileURLWithPath: RZFileOrganizer.writeableFilePath("position_" + activity.activityId + "_" + activity.activityTypeAsString + ".csv"))
                do {
                    let grows = cols.gps.map { tup in
                        [ activity.activityId, tup.time.formatAsRFC3339(), "\(tup.location.latitude)", "\(tup.location.longitude)"].joined( separator: "," )
                    }
                    try grows.joined(separator: "\n").write(to: fn, atomically: true, encoding: .utf8)
                }catch { }
            }
        }
    }
    
    func exportSingleCsv() {
        var units : [String:GCUnit] = [:]
        
        for activity  in self.dataSource.list() {
            
                let val = activity.numbers
                for (key,nu) in val {
                    units[key] = nu.unit
                }
            
        }

        
        let cols = ["activityId", "activityType"] + Array(units.keys)
        
        var csv : String = ""
        var line : [String] = []
        for col in cols {
            if let unit = units[col] {
                line.append("\(col)_\(unit)")
            }else{
                line.append(col)
            }
        }
        csv += line.joined(separator: ",")
        csv += "\n"
        
        for activity  in self.dataSource.list() {
            
            line = []
            let val = activity.numbers
            for key in cols {
                if key == "activityId" {
                    line.append(activity.activityId)
                }else if key == "activityType" {
                    line.append(activity.activityTypeAsString)
                }else if let nu = val[key], let u = units[key] {
                    let dval = nu.convert(to: u).value
                    line.append("\(dval)")
                }else{
                    line.append("")
                }
            }
            
            csv += line.joined( separator: ",")
            csv += "\n"
            
        }
        
        let fn = RZFileOrganizer.writeableFilePath("list.csv")

        do {
        try csv.write(toFile: fn, atomically: true, encoding: String.Encoding.utf8)
        }catch {
            print("Failed to write \(fn)")
        }

    }
    
    @IBAction func exportList(_ sender: Any) {
        self.exportSingleCsv()
    }
    

    // MARK: -
        
    override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(downloadChanged(notification:)),
                                               name: FITGarminDownloadManager.Notifications.garminDownloadChange,
                                               object: nil)
        
        
        print( "\(keychain.allKeys())")
        if let saved_username = keychain.string(forKey: FITAppGlobal.ConfigParameters.loginName.rawValue){
            userName.stringValue = saved_username
            if let update = try? JSON( [FITAppGlobal.ConfigParameters.loginName.rawValue:saved_username]) {
                FITAppGlobal.shared.updateSettings(json: update)
            }
            
            //FITAppGlobal.configSet(kFITSettingsKeyLoginName, stringVal: saved_username)
        }
        if let saved_password = keychain.string(forKey: FITAppGlobal.ConfigParameters.password.rawValue) {
            password.stringValue = saved_password
            if let update = try? JSON( [FITAppGlobal.ConfigParameters.password.rawValue:saved_password]) {
                FITAppGlobal.shared.updateSettings(json: update)
            }
            //FITAppGlobal.configSet(kFITSettingsKeyPassword, stringVal: saved_password)
        }
        FITAppGlobal.downloadManager().loadFromFile()
        activityTable.dataSource = self.dataSource
        activityTable.delegate = self.dataSource
        rebuildColumns()
        self.activityTable.reloadData()
        self.updateStatus()
    }
    
    func updateStatus() {
        let text = self.dataSource.statusString()
        self.leftStatus.stringValue = "\(text)"
        if let activity = FITAppGlobal.shared.web.currentDescription() {
            self.rightStatus.stringValue = activity
        }else{
            self.rightStatus.stringValue = "Ready"
        }
        
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func editUserName(_ sender: Any) {
        let entered_username = userName.stringValue
        keychain.set(entered_username, forKey: FITAppGlobal.ConfigParameters.loginName.rawValue)
        FITAppGlobal.configSet(FITAppGlobal.ConfigParameters.loginName.rawValue, stringVal: entered_username)
    }
    
    @IBAction func editPassword(_ sender: Any) {
        let entered_password = password.stringValue
        keychain.set(entered_password, forKey: FITAppGlobal.ConfigParameters.password.rawValue)
        print( "\(keychain.allKeys())")
        FITAppGlobal.configSet(FITAppGlobal.ConfigParameters.password.rawValue, stringVal: entered_password)
    }
    
    func rebuildColumns(){
        let samples = FITAppGlobal.downloadManager().samples()
        
        let columns : [NSTableColumn] = self.activityTable.tableColumns
        
        var existing: [NSUserInterfaceItemIdentifier:NSTableColumn] = [:]
        
        for col in columns {
            existing[col.identifier] = col
        }
        
        let required = dataSource.requiredTableColumnsIdentifiers()
        
        var valuekeys : [String] = Array(samples.keys)
        
        func sortKey(l:String,r:String) -> Bool {
            if let fl = GCField(forKey: l, andActivityType: GC_TYPE_ALL)?.sortOrder(),
                let fr = GCField(forKey: r, andActivityType: GC_TYPE_ALL)?.sortOrder() {
                return fl < fr;
            }else{
                return l < r;
            }
        }
        let orderedkeys = valuekeys.sorted(by: sortKey )
        
        let newcols = required + orderedkeys
        
        if newcols.count < columns.count{
            var toremove :[NSTableColumn] = []
            for item in required.count..<columns.count {
                toremove.append(columns[item])
            }
            for item in toremove {
                self.activityTable.removeTableColumn(item)
            }
        }
        
        var idx : Int = 0
        for identifier in newcols {
            var title = identifier
            if !required.contains(title){
                if let nice = GCField(forKey: identifier, andActivityType: GC_TYPE_ALL){
                    title = nice.displayName()
                }
            }

            if idx < columns.count {
                let col = columns[idx];
                
                
                col.title = title
                col.identifier = NSUserInterfaceItemIdentifier(identifier)
            }else{
                let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(identifier))
                col.title = title
                self.activityTable.addTableColumn(col)
            }
            idx += 1
        }
    }
}
