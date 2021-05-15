//  MIT License
//
//  Created on 08/05/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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

import UIKit
import RZUtilsSwift

class GCConnectStatsRequestRegisterNotifications : GCConnectStatsRequest {
        
    @objc override func preparedUrlRequest() -> URLRequest? {
        if self.isSignedIn(),
           let path = GCWebConnectStatsSearch(GCAppGlobal.webConnectsStatsConfig()){
            let params : [AnyHashable: Any] = [
                "token_id": self.tokenId,
                "notification_device_token": GCAppGlobal.profile().configGet(CONFIG_NOTIFICATION_DEVICE_TOKEN, defaultValue: "") ?? "",
                "notification_enabled" :  GCAppGlobal.profile().pushNotificationEnabled,
                "notification_push_type" : GCAppGlobal.profile().pushNotificationType,
            ]
            return self.preparedUrlRequest(path, params: params)
        }
        return nil
    }
    
    @objc static func register(){
        if( GCAppGlobal.profile().pushNotificationEnabled){
            RZSLog.info("connectstats enabled requesting notification")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge]){
                granted, error in
                if( granted ){
                    UNUserNotificationCenter.current().getNotificationSettings() {
                        setting in
                        if setting.authorizationStatus == .authorized {
                            DispatchQueue.main.async {
                                RZSLog.info("Push notification granted, registering")
                                UIApplication.shared.registerForRemoteNotifications()
                                GCAppGlobal.web().add(GCConnectStatsRequestRegisterNotifications())
                            }
                        }else{
                            RZSLog.info("Push notification not authorized, disabling")
                            if GCAppGlobal.profile().pushNotificationType != .none {
                                DispatchQueue.main.async {
                                    GCAppGlobal.profile().pushNotificationType = .none
                                    GCAppGlobal.saveSettings()
                                }
                            }
                        }
                    }
                }else{
                    RZSLog.info("Push notification not granted, disabling \(String(describing: error))")
                    if GCAppGlobal.profile().pushNotificationType != .none {
                        DispatchQueue.main.async {
                            GCAppGlobal.profile().pushNotificationType = .none
                            GCAppGlobal.saveSettings()
                        }
                    }
                }
            }
        }
    }
    
    struct NotificationConfirmation : Codable {
        var cs_user_id : Int? = nil
        var device_token : String? = nil
        var push_type : Int? = nil
        var enabled : Bool
    
    }
    
    @objc override func process() {
        guard let data = self.theString.data(using: .utf8)
        else {
            RZSLog.info("invalid data skipping background update")
            self.processDone()
            return
        }
        
        guard self.checkNoErrors()
        else {
            RZSLog.info("Failed to fetch skipping background update")
            self.processDone()
            return
        }
        if let confirmation = try? JSONDecoder().decode(NotificationConfirmation.self, from: data) {
            RZSLog.info("Notification confirmed \(confirmation)")
        }else{
            RZSLog.info("Notification not confirmed \(String(describing: self.theString))")
        }
        
        self.processDone()
    }
}
