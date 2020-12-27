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
import OAuthSwift
import SwiftKeychainWrapper
import RZUtilsSwift

class GCStravaRequestBase: GCWebRequestStandard {

    let stravaAuth : OAuth2Swift
    let navigationController : UINavigationController
    
    @objc init(navigationController:UINavigationController) {
        self.navigationController = navigationController
        self.stravaAuth = OAuth2Swift(consumerKey: GCAppGlobal.credentials(forService: Credential.serviceName,
                                                                           andKey: "client_id"),
                                      consumerSecret: GCAppGlobal.credentials(forService: Credential.serviceName,
                                                                              andKey: "client_secret"),
                               authorizeUrl: GCAppGlobal.credentials(forService: Credential.serviceName,
                                                                     andKey: "authenticate_url"),
                               accessTokenUrl: GCAppGlobal.credentials(forService: Credential.serviceName,
                                                                       andKey: "access_token_url"),
                               responseType: "code")
        

    }
    
    @objc static func signout() {
        print( "LOGOUT")
    }
    struct Credential {
        static let serviceName = "strava"
    }
    
    override func url() -> String? {
        return nil
    }
    
    func stravaUrl() -> URL? {
        return nil
    }
    
    func saveCredential() {
        if let jsonData = try? JSONEncoder().encode(self.stravaAuth.client.credential){
           let profile = GCAppGlobal.profile()
            RZSLog.info("Saved Strava")
            profile.setLoginName(self.stravaAuth.client.credential.oauthToken, for: gcService.strava)
            profile.setPassword(String(data: jsonData, encoding: .utf8), for: gcService.strava)
            GCAppGlobal.saveSettings()
        }
    }
    
    func clearCredential() {
        let profile = GCAppGlobal.profile()
        profile.setLoginName("", for: gcService.strava)
        profile.setPassword("", for: gcService.strava)
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
    
    func signInToStrava() {
        self.retrieveCredential()
        self.stravaAuth.authorizeURLHandler = SafariURLHandler(viewController: self.navigationController,
                                                               oauthSwift: self.stravaAuth)
        if self.stravaAuth.client.credential.oauthRefreshToken == "" {
            self.stravaAuth.authorize(withCallbackURL: "connectstats://ro-z.net/oauth/strava",
                                      scope: "activity:read_all,read_all",
                                      state: "prod" ) { result in
                switch result {
                case .success:
                    self.saveCredential()
                    self.makeRequest()
                case .failure(let error):
                    RZSLog.error("Failed to authorise \(error)")
                    self.status = GCWebStatus.loginFailed
                    self.processDone()
                }
            }
        }else{
            self.makeRequest()
        }
    }
    
    func makeRequest() {
        if let url = self.stravaUrl() {
            self.stravaAuth.startAuthorizedRequest(url, method: .GET, parameters: [:] ) { result in
                switch result {
                case .success(let response):
                    self.saveCredential()
                    self.process(data: response.data, response:response.response)
                case .failure(let error):
                    var shouldTrySignin : Bool = false
                    
                    switch error {
                    case .requestError(let k, _):
                        let underlyingError = (k as NSError)
                        let code = underlyingError.code
                        let body = underlyingError.userInfo["Response-Body"] ?? "No Body"
                        if( code == 401){
                            // If we had success before, try signin again
                            if GCAppGlobal.profile().serviceSuccess(gcService.strava) {
                                shouldTrySignin = true
                            }
                            GCAppGlobal.profile().serviceSuccess(gcService.strava, set: false)
                            RZSLog.error("Got invalid token, trying signin \(underlyingError.code) \(body)")
                        }else{
                            RZSLog.error("Failed to get response \(underlyingError.code) \(body)")
                            
                        }
                    default:
                        RZSLog.error("Failed to get response \(error.errorCode) \(error.errorUserInfo.keys)")
                        self.status = GCWebStatus.accessDenied
                    }
                    if shouldTrySignin {
                        self.signInToStrava()
                    }else{
                        GCAppGlobal.profile().serviceSuccess(gcService.strava, set: false)
                        self.status = GCWebStatus.accessDenied
                        self.processDone()
                    }
                }
            }
        }
    }
    
    override func process() {
        self.signInToStrava()
    }

    func process(data : Data, response: HTTPURLResponse){
        self.processDone()
    }
}
