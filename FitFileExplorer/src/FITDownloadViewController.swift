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

class FITDownloadViewController: NSViewController {
    @IBOutlet weak var userName: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    
    @IBOutlet weak var activityTable: NSTableView!

    var dataSource = FITDownloadListDataSource()
    
    @IBAction func refresh(_ sender: Any) {
        activityTable.dataSource = self.dataSource
        activityTable.delegate = self.dataSource
        FITAppGlobal.downloadManager().startDownload()
    }

    @objc func downloadChanged(notification : Notification){
        rebuildColumns()
        self.activityTable.reloadData()
    }
        
    @IBAction func downloadSamples(_ sender: Any) {
        activityTable.dataSource = self.dataSource
        activityTable.delegate = self.dataSource
        FITAppGlobal.downloadManager().loadRawFiles()

    }
    
    @IBAction func exportList(_ sender: Any) {
        for one  in self.dataSource.list() {
            if let activity = one as? FITGarminActivityWrapper {
                if activity.activityId == "3137094437"{
                    print("Found")
                }
                
                if let path = activity.fitFilePath,
                    let decode = FITFitFileDecode(forFile: path){
                    decode.parse()
                    if  let fitFile = decode.fitFile {
                        let interpret = FITFitFileInterpret(fitFile: fitFile)
                        let cols = interpret.columnDataSeries(message: "record")
                        print( "\(activity.activityId): \(cols.count)" )
                    }
                }
            }
        }
    }
        
    @IBAction func downloadFITFile(_ sender: Any) {
        let row = self.activityTable.selectedRow
        if (row > -1) {
            let act = dataSource.list()[UInt(row)].activityId
            
            print("Download \(row) \(act)")
        }else{
            print("No selection, nothing to download")
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(downloadChanged(notification:)),
                                               name: FITGarminDownloadManager.Notifications.garminDownloadChange,
                                               object: nil)
        
        let keychain = KeychainWrapper(serviceName: "net.ro-z.connectstats")
        
        if let saved_username = keychain.string(forKey: "username"){
            userName.stringValue = saved_username
            FITAppGlobal.configSet(kFITSettingsKeyLoginName, stringVal: saved_username)
        }
        if let saved_password = keychain.string(forKey: "password") {
            password.stringValue = saved_password
            FITAppGlobal.configSet(kFITSettingsKeyPassword, stringVal: saved_password)
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func editUserName(_ sender: Any) {
        let entered_username = userName.stringValue
        let keychain = KeychainWrapper(serviceName: "net.ro-z.connectstats")
        
        keychain.set(entered_username, forKey: "username")
        FITAppGlobal.configSet(kFITSettingsKeyLoginName, stringVal: entered_username)
    }
    
    @IBAction func editPassword(_ sender: Any) {
        let entered_password = password.stringValue
        let keychain = KeychainWrapper(serviceName: "net.ro-z.connectstats")
        
        keychain.set(entered_password, forKey: "password")
        FITAppGlobal.configSet(kFITSettingsKeyPassword, stringVal: entered_password)

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
