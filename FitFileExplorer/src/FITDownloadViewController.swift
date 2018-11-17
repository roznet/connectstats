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

    @IBAction func refresh(_ sender: Any) {
        FITAppGlobal.downloadManager().startDownload()
    }

    override func viewWillAppear() {
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
}
