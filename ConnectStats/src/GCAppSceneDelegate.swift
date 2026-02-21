//  MIT License
//
//  Created on 26/12/2020 for ConnectStats
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
import OAuthSwift
import RZUtilsSwift
import UIKit
import UserNotifications

@objc class GCAppSceneDelegate : UIResponder, UIWindowSceneDelegate{
    
    private var tabBarController : GCTabBarController? = nil
    private var splitViewController : GCSplitViewController? = nil
    
    private var appDelegate : GCAppDelegate { return UIApplication.shared.delegate as! GCAppDelegate }
    
    var window : UIWindow? = nil
    @objc var actionDelegate : GCAppActionDelegate? { return tabBarController ?? splitViewController }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        RZSLog.info("scene connect")
        
        if let scene = scene as? UIWindowScene {
            window = UIWindow(windowScene: scene)
            if( appDelegate.startInit() ){
                
                if( UIDevice.current.userInterfaceIdiom == .pad){
                    splitViewController = GCSplitViewController()
                    window?.rootViewController = splitViewController
                }else{
                    tabBarController = GCTabBarController()
                    window?.rootViewController = tabBarController
                }
            }else{
                self.multipleFailureStart()
            }
            window?.makeKeyAndVisible()
        }else{
            RZSLog.info("connect to non window scene \(scene)")
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        RZSLog.info("scene disconnect")
        GCAppGlobal.saveSettings()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        RZSLog.info("scene active")
        
        GCAppGlobal.organizer().ensureSummaryLoaded()
        
        let worker = GCAppGlobal.worker()
        worker.async {
            GCAppGlobal.organizer().ensureDetailsLoaded()
        }
        worker.async {
            GCAppGlobal.derived().ensureDetailsLoaded()
        }
        worker.async {
            GCAppGlobal.health().ensureDetailsLoaded()
        }
        UNUserNotificationCenter.current().setBadgeCount(0)
        
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        RZSLog.info("scene resign actvie")
        GCAppGlobal.saveSettings()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        RZSLog.info("scene foreground")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        RZSLog.info("scene background")
        GCAppGlobal.saveSettings()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        RZSLog.info("context \(URLContexts)")
        
        for context in URLContexts {
            if context.url.path.hasSuffix(".fit"){
                appDelegate.handleOpen(context.url)
                break
            }
            if context.url.path == "/oauth/strava" {
                OAuthSwift.handle(url: context.url)
            }
        }
    }

    func multipleFailureStart() {
        let bugcontroller = GCSettingsBugReportViewController(nibName: nil, bundle: nil)
        bugcontroller.includeErrorFiles = true
        bugcontroller.includeActivityFiles = true
        
        window?.rootViewController = bugcontroller
        
        appDelegate.startSuccessful()
    }
}
