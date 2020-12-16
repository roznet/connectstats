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
import RZUtilsCore
import RZUtilsMacOS
import GenericJSON
import KeychainSwift
import RZUtilsSwift
import FitFileParser
import FitFileParserTypes


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
    
    let keychain = KeychainSwift()
    
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    
    @IBOutlet weak var activityTable: NSTableView!
    @IBOutlet weak var rightStatus: NSTextField!
    @IBOutlet weak var leftStatus: NSTextField!
    
    
    var pendingOpen : [Activity] = []
    var dataSource = FITDownloadListDataSource()
    
    // MARK: -
    
    func databaseFileName() -> String {
        if let saved_username = keychain.get(FITAppGlobal.ConfigParameters.loginName.rawValue){
        
            var invalidCharacters = CharacterSet(charactersIn: ":/")
           
            invalidCharacters.formUnion(CharacterSet.newlines)
            invalidCharacters.formUnion(CharacterSet.illegalCharacters)
            invalidCharacters.formUnion(CharacterSet.controlCharacters)
            
            let filename = saved_username.components(separatedBy: invalidCharacters).joined(separator: "")
            
            return "activities_\(filename).db"
        }else{
            return "activities_default.db"
        }
    }
    
    func selectedActivities() -> [Activity] {
        let rows = self.activityTable.selectedRowIndexes
        let acts = dataSource.list()
        var rv : [Activity] = []
        for index in rows {
            rv.append(acts[index])
        }
        return rv
    }
    
    
    func exportFitFilesAsCSV(messageType:FitMessageType){
        let todo = self.selectedActivities()
        var files : [FitFile] = []
        for act in todo {
            if let url = act.fitFilePath {
                if let file = FitFile(file: url){
                    files.append(file)
                }
            }
        }
        
        let csv = FitFile.csv(messageType: messageType, fitFiles: files)
        let content = csv.joined(separator: "\n")
        
        let mesg = rzfit_mesg_num_string(input: messageType) ?? "mesg"
        
        self.askAndSave(content: content, candidate: "export_\(mesg)")
    }

    func askAndSave(content:String, candidate:String){
        let savePanel = NSSavePanel()

        savePanel.message = "Choose the location to save the csv file"
        savePanel.allowedFileTypes = [ "csv" ]
        savePanel.nameFieldStringValue = candidate
        if savePanel.runModal() == NSApplication.ModalResponse.OK, let url = savePanel.url {
            do {
                try content.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            }catch{
                RZSLog.error( "Failed to save \(url)")
            }
        }

    }
    
    // MARK: - Buttons and actions
    
    @IBAction func refresh(_ sender: Any) {
        activityTable.dataSource = self.dataSource
        activityTable.delegate = self.dataSource
        
        let dbpath = RZFileOrganizer.writeableFilePath(self.databaseFileName())
        
        let db = FMDatabase(path: dbpath) 
        db.open()
        FITAppGlobal.shared.organizer.load(db: db)
        
        
        FITAppGlobal.downloadManager().startDownloadList()
    }

    @IBAction func downloadFitFile(_ sender: Any) {
        let activities = self.selectedActivities()
        var needDownload : [Activity] = []
        
        for act in activities {
            if !act.downloaded {
                needDownload.append(act)
            }
        }
        
        if( needDownload.count > 0){
            NotificationCenter.default.addObserver(self, selector: #selector(notificationNewFitFile(notification:)),
                                                   name: GarminRequestFitFile.Notifications.downloaded, object: nil)
            
            FITAppGlobal.downloadManager().startDownloadFitFiles(activities: needDownload )

        }
    }
    
    @IBAction func openFitFile(_ sender: Any) {
        let activities = self.selectedActivities()
        var downloaded : [Activity] = []
        var needDownload : [Activity] = []
        
        for act in activities {
            if act.downloaded, let url = act.fitFilePath {
                downloaded.append(act)
                NSDocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: {(doc,bool,err) in })
            }else{
                needDownload.append(act)
            }
        }
        
        if( needDownload.count > 0){
            self.pendingOpen.append(contentsOf: needDownload)
            NotificationCenter.default.addObserver(self, selector: #selector(notificationNewFitFile(notification:)),
                                                   name: GarminRequestFitFile.Notifications.downloaded, object: nil)
            
            FITAppGlobal.downloadManager().startDownloadFitFiles(activities: needDownload )

        }

    }
    
    @IBAction func exportFilesAsCSVSessions(_ sender: Any) {
        self.exportFitFilesAsCSV(messageType: FIT_MESG_NUM_SESSION)
    }
    
    @IBAction func exportFilesAsCSVLaps(_ sender: Any) {
        self.exportFitFilesAsCSV(messageType: FIT_MESG_NUM_LAP)
    }
    
    @IBAction func exportFilesAsCSVRecords(_ sender: Any) {
        self.exportFitFilesAsCSV(messageType: FIT_MESG_NUM_RECORD)
    }
    
    @IBAction func exportList(_ sender: Any) {
        let organizer = FITAppGlobal.shared.organizer
        let csv = organizer.csv()

        let content = csv.joined(separator: "\n")
        
        self.askAndSave(content: content, candidate: "list")
        
    }
    
    @IBAction func editUserName(_ sender: Any) {
        let entered_username = userName.stringValue
        if( !keychain.set(entered_username, forKey: FITAppGlobal.ConfigParameters.loginName.rawValue) ){
            RZSLog.error( "failed to save username" )
        }
        FITAppGlobal.configSet(FITAppGlobal.ConfigParameters.loginName.rawValue, stringVal: entered_username)
    }
    
    @IBAction func editPassword(_ sender: Any) {
        let entered_password = password.stringValue
        if !keychain.set(entered_password, forKey: FITAppGlobal.ConfigParameters.password.rawValue){
            RZSLog.error("failed to save password")
        }
        
        FITAppGlobal.configSet(FITAppGlobal.ConfigParameters.password.rawValue, stringVal: entered_password)
    }

    // MARK: - notifications
    
    @objc func downloadFinished(notification : Notification){
        DispatchQueue.main.async {
            self.rebuildColumns()
            self.activityTable.reloadData()
            self.updateStatus()
        }
    }
    
    
    
    @objc func organizerListChanged(notification : Notification){
        DispatchQueue.main.async {
            self.rebuildColumns()
            self.activityTable.reloadData()
            self.updateStatus()
        }
    }
    
    @objc func notificationNewFitFile(notification:Notification){
        if let activityId = notification.object as? String {
            RZSLog.info( "Success Downloaded \(activityId)")
            
            for act in self.pendingOpen {
                if( act.activityId == activityId ){
                    
                    if let fp = RZFileOrganizer.writeableFilePathIfExists("\(activityId).fit") {
                        NSDocumentController.shared.openDocument(withContentsOf: URL(fileURLWithPath: fp), display: true, completionHandler: {(doc,bool,err) in })
                    }
                    break
                }
            }
            self.pendingOpen.removeAll(where: { $0.activityId == activityId } )
        }
    }

    // MARK: - View Delegate
        
    override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(downloadFinished(notification:)),
                                               name: FITGarminDownloadManager.Notifications.end,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(organizerListChanged(notification:)),
                                               name: ActivitiesOrganizer.Notifications.listChange,
                                               object: nil)

        if let saved_username = keychain.get(FITAppGlobal.ConfigParameters.loginName.rawValue){
            userName.stringValue = saved_username
            if let update = try? JSON( [FITAppGlobal.ConfigParameters.loginName.rawValue:saved_username]) {
                FITAppGlobal.shared.updateSettings(json: update)
            }
        }
        
        if let saved_password = keychain.get(FITAppGlobal.ConfigParameters.password.rawValue) {
            password.stringValue = saved_password
            if let update = try? JSON( [FITAppGlobal.ConfigParameters.password.rawValue:saved_password]) {
                FITAppGlobal.shared.updateSettings(json: update)
            }
        }
        

        //FITAppGlobal.downloadManager().loadFromFile()
        activityTable.dataSource = self.dataSource
        activityTable.delegate = self.dataSource
        rebuildColumns()
        self.activityTable.reloadData()
        self.updateStatus()
        
        if let dbpath = RZFileOrganizer.writeableFilePathIfExists(self.databaseFileName()) {
            FITAppGlobal.shared.worker.async {
                let db = FMDatabase(path: dbpath )
                db.open()
                FITAppGlobal.shared.organizer.load(db: db)
            }
        }

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
    
    
    func rebuildColumns(){
        let samples = FITAppGlobal.downloadManager().samples()
        
        let columns : [NSTableColumn] = self.activityTable.tableColumns
        
        var existing: [NSUserInterfaceItemIdentifier:NSTableColumn] = [:]
        
        for col in columns {
            existing[col.identifier] = col
        }
        
        let required = dataSource.requiredTableColumnsIdentifiers()
        
        let valuekeys : [String] = Array(samples.keys)
        
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
