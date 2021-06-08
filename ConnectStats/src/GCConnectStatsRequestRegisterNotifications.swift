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
        #if GC_USE_SANDBOX_APN
        // if using sandbox, skip registration in prod as can't use prod apn from debug build
        if( GCAppGlobal.webConnectsStatsConfig() == gcWebConnectStatsConfig.productionConnectStatsApp){
            RZSLog.info("Disabling notification register because DEBUG build")
            return nil
        }
        #endif
        
        if self.isSignedIn(),
           let path = GCWebConnectStatsRegisterNotification(GCAppGlobal.webConnectsStatsConfig()){
            let type : UInt = GCAppGlobal.profile().pushNotificationType.rawValue
            let params : [AnyHashable: Any] = [
                "token_id": self.tokenId,
                "notification_device_token": GCAppGlobal.profile().configGet(CONFIG_NOTIFICATION_DEVICE_TOKEN, defaultValue: "") ?? "",
                "notification_enabled" :  GCAppGlobal.profile().pushNotificationEnabled,
                "notification_push_type" : type,
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
                                // This will call didregister on app delegate and create a request if the token changed
                                UIApplication.shared.registerForRemoteNotifications()
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
        var cs_user_id : Int
        var device_token : String
        var push_type : Int
        var enabled : Int
    
    }
    
    @objc override func process() {
        guard let str = self.theString else{
            // before logged in, just didn't actually talk to server, success trivially
            self.processDone()
            return
        }
        
        guard let data = str.data(using: .utf8)
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
        do {
            let confirmation = try JSONDecoder().decode(NotificationConfirmation.self, from: data)
            RZSLog.info("Notification confirmed push_type=\(confirmation.push_type) for device=\(confirmation.device_token)")
        }catch{
            RZSLog.info("Notification not confirmed \(String(describing: self.theString)) \(error)")
        }
        
        self.processDone()
    }
}
