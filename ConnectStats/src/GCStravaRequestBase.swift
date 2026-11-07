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



import UIKit
import SafariServices
import OAuthSwift
import RZUtilsSwift

class GCStravaRequestBase: GCWebRequestStandard, SFSafariViewControllerDelegate {

    let stravaAuth : OAuth2Swift
    let navigationController : UINavigationController

    /// Interactive (Safari) sign-in is only started when the user explicitly asked for it
    /// from settings. Automatic syncs never pop up the Strava sign-in page, otherwise a user
    /// whose credential was cleared gets the page (and a hung sync) on every launch.
    @objc static var signInRequested : Bool = false

    /// Ensures processDone is only called once for the interactive sign-in, whichever of the
    /// OAuth completion or the Safari "Done" button comes first
    private var signInFinished : Bool = false
    private var customMessageText : String? = nil

    struct Credential {
        static let serviceName = "strava"
    }
    
    @objc init(navigationController:UINavigationController) {
        self.navigationController = navigationController
        self.stravaAuth = OAuth2Swift(consumerKey: GCAppGlobal.credentials(forService: Credential.serviceName, andKey: "client_id"),
                                      consumerSecret: GCAppGlobal.credentials(forService: Credential.serviceName, andKey: "client_secret"),
                                      authorizeUrl: GCAppGlobal.credentials(forService: Credential.serviceName, andKey: "authenticate_url"),
                                      accessTokenUrl: GCAppGlobal.credentials(forService: Credential.serviceName, andKey: "access_token_url"),
                                      responseType: "code")
        self.stravaAuth.authorizeURLHandler = SafariURLHandler(viewController: self.navigationController, oauthSwift: self.stravaAuth)
    }
    
    init(previous : GCStravaRequestBase){
        self.navigationController = previous.navigationController
        self.stravaAuth = previous.stravaAuth
    }
    
    @objc override func service() -> gcWebService {
        return gcWebService.strava
    }
    override func url() -> String? {
        return nil
    }
    
    func stravaUrl() -> URL? {
        return nil
    }

    override var urlDescription: String! {
        if let url = self.stravaUrl() {
            return url.path
        }else{
            return "NoUrl"
        }
    }
    
    //MARK: - Credentials
    
    /// Called from settings when the user turns Strava on or taps login
    @objc static func requestSignIn() {
        RZSLog.info("strava signin requested by user")
        self.signInRequested = true
    }

    @objc static func signout() {
        GCAppGlobal.profile().serviceSuccess(gcService.strava, set: false)
        self.clearCredential()
        DispatchQueue.main.async {
            GCAppGlobal.saveSettings()
        }
    }
    
    static func clearCredential() {
        let profile = GCAppGlobal.profile()
        profile.setLoginName("", for: gcService.strava)
        profile.setPassword("", for: gcService.strava)
    }

    func saveCredential() {
        if let jsonData = try? JSONEncoder().encode(self.stravaAuth.client.credential){
           let profile = GCAppGlobal.profile()
            profile.setLoginName(self.stravaAuth.client.credential.oauthToken, for: gcService.strava)
            profile.setPassword(String(data: jsonData, encoding: .utf8), for: gcService.strava)
            GCAppGlobal.saveSettings()
        }
    }
    
    @discardableResult
    func retrieveCredential() -> Bool {
        guard GCAppGlobal.profile().serviceSuccess(gcService.strava) else {
            return false
        }
        var rv = false
        let profile = GCAppGlobal.profile()
        if  let oauth_credential_json = profile.currentPassword(for: gcService.strava)?.data(using: .utf8),
            let credential = try? JSONDecoder().decode( OAuthSwiftCredential.self, from: oauth_credential_json ) {
            self.stravaAuth.client.credential.oauthToken = credential.oauthToken
            self.stravaAuth.client.credential.oauthTokenSecret = credential.oauthTokenSecret
            self.stravaAuth.client.credential.oauthRefreshToken = credential.oauthRefreshToken
            rv = true
        }
        return rv
    }
    
    //MARK: - Request and Authentication
    
    override func process() {
        self.retrieveCredential()
        if GCAppGlobal.profile().serviceSuccess(gcService.strava) == false {
            guard GCStravaRequestBase.signInRequested else {
                RZSLog.info("strava not signed in, skipping (sign in from settings)")
                self.customMessageText = NSLocalizedString("Not signed in. Go to Settings › Services › Strava to sign in.", comment: "Strava Request")
                self.status = GCWebStatus.customMessage
                DispatchQueue.main.async {
                    self.processDone()
                }
                return
            }
            GCStravaRequestBase.signInRequested = false
            self.signInFinished = false

            let urlscheme = GCAppGlobal.appURLScheme()
            RZSLog.info("strava signin start")
            if let safariHandler = self.stravaAuth.authorizeURLHandler as? SafariURLHandler {
                // so we get notified if the user closes the page with Done
                safariHandler.delegate = self
            }
            self.stravaAuth.authorize(withCallbackURL: "\(urlscheme)://ro-z.net/oauth/strava",
                                      scope: "activity:read_all,read_all",
                                      state: "prod" ) { result in
                switch result {
                case .success:
                    RZSLog.info("strava signin success")
                    self.signInFinished = true
                    self.clearSafariDelegate()
                    self.saveCredential()
                    self.makeRequest()
                case .failure(let error):
                    RZSLog.error("strava signin failed to authorise \(error)")
                    self.signInFailed()
                }
            }
        }else{
            self.makeRequest()
        }
    }

    private func clearSafariDelegate() {
        if let safariHandler = self.stravaAuth.authorizeURLHandler as? SafariURLHandler {
            safariHandler.delegate = nil
        }
    }

    /// Called on the main thread (OAuth completion and Safari delegate both are)
    private func signInFailed() {
        guard !self.signInFinished else { return }
        self.signInFinished = true
        self.clearSafariDelegate()
        self.status = GCWebStatus.loginFailed
        self.processDone()
    }

    //MARK: - SFSafariViewControllerDelegate

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // "Done" pressed: OAuthSwift only clears its observers and never calls the
        // authorize completion, so without this the request would hang forever
        RZSLog.info("strava signin cancelled by user")
        self.stravaAuth.cancel()
        self.signInFailed()
    }

    @objc override func customMessage() -> String? {
        return self.customMessageText
    }
    
    func makeRequest() {
        // Start with success
        self.status = GCWebStatus.OK
        if let url = self.stravaUrl() {
            self.stravaAuth.client.get(url){ result in
                
                switch result {
                case .success(let response):
                    self.status = GCWebStatus.OK
                    if( !GCAppGlobal.profile().serviceSuccess(gcService.strava)) {
                        DispatchQueue.main.async {
                            GCAppGlobal.profile().serviceSuccess(gcService.strava, set: true)
                            GCAppGlobal.saveSettings()
                        }
                    }
                    self.process(data: response.data)
                case .failure(let queryError):
                    switch queryError {
                    case .requestError(let underlyingError, _ /*request*/):
                        let code = (underlyingError as NSError).code
                        if code == 401 { // expired, renew
                            RZSLog.info("Renewing Strava Token")
                            self.stravaAuth.renewAccessToken(withRefreshToken: self.stravaAuth.client.credential.oauthRefreshToken) { result in
                                switch result {
                                case .success:
                                    self.saveCredential()
                                    self.makeRequest()
                                case .failure(let renewError):
                                    self.requestError(error: renewError, message: "Failed to renew token")
                                }
                            }
                        }else if code == 404 {
                            // Special handling as some request will elegantly handle missing resource
                            self.processResourceNotFound()
                        }
                        else{
                            self.requestError(error: queryError, message: "Request failed with unanticipated code \(code)")
                        }
                    default:
                        self.requestError(error: queryError, message: "Request failed")
                    }
                }
            }
        }else{
            self.status = GCWebStatus.internalLogicError
            RZSLog.error("no strava url \(self)")
            self.processDone()
        }
    }
    
    func requestError( error : OAuthSwiftError, message : String){
        if let underlyingError = error.underlyingError {
            self.lastError = (underlyingError as NSError)
            let code = (underlyingError as NSError).code
            if let body = (underlyingError as NSError).userInfo["Response-Body"] {
                // strava responded
                RZSLog.error("strava denied access, forcing re-authorization \(message) \(code) \(body)")
                self.status = GCWebStatus.accessDenied
                GCStravaRequestBase.signout()
            }else{
                // no response from strava
                self.status = GCWebStatus.connectionError
                RZSLog.error("no response \(message) \(code)")
            }
        }else{
            self.status = GCWebStatus.connectionError
            RZSLog.error("not an nserror \(message) \(error)")
        }
        self.processDone()
    }
    
    //MARK: - to override
    
    func process(data : Data){
        self.processDone()
    }
    
    func processResourceNotFound() {
        self.status = GCWebStatus.resourceNotFound
        RZSLog.error("Resource Not Found \(self)")
        self.processDone()
    }
}
