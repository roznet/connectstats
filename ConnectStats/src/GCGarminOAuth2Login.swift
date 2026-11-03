//  MIT License
//
//  Created on 03/11/2026 for ConnectStats
//
//  Copyright (c) 2026 Brice Rosenzweig
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
import AuthenticationServices
import CryptoKit
import RZUtilsSwift

/// Answer of `GET /api/status/api`
struct GCConnectStatsAPIStatus : Decodable {
    let status : Int
    let redirect : String?
    let garminLogin : String?
    let oauth2ClientId : String?

    enum CodingKeys : String, CodingKey {
        case status
        case redirect
        case garminLogin = "garmin_login"
        case oauth2ClientId = "oauth2_client_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decode(Int.self, forKey: .status)
        self.redirect = try container.decodeIfPresent(String.self, forKey: .redirect)
        // Any unexpected value means OAuth 1.0, and must not lose the rest of the answer
        self.garminLogin = try? container.decodeIfPresent(String.self, forKey: .garminLogin)
        self.oauth2ClientId = try? container.decodeIfPresent(String.self, forKey: .oauth2ClientId)
    }
}

/// The server setting choosing the flow for a new login. It plays no part for a signed-in user:
/// a stored server token means Bearer, otherwise OAuth 1.0
@objc class GCGarminLoginSetting : NSObject {
    private static let oauth2Value = "oauth2"
    /// An answer this recent, usually from the check queued just before login, doesn't need asking again
    private static let answerValidity : TimeInterval = 300.0
    private static let statusCheckTimeout : TimeInterval = 5.0

    private static let lock = NSLock()
    private static var lastAnswer : Date? = nil

    static var isOAuth2 : Bool {
        return GCAppGlobal.profile().configGet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, defaultValue: "") == oauth2Value
    }

    /// The client id from the server, which is only issued once Garmin converts the app, so a build made
    /// before that can still turn on OAuth 2.0. Not secret. Empty if the server didn't provide one
    static var serverClientId : String {
        return GCAppGlobal.profile().configGet(CONFIG_CONNECTSTATS_GARMIN_CLIENT_ID, defaultValue: "") ?? ""
    }

    /// Save the values from a valid answer. Absent means OAuth 1.0, so that it can be turned back off
    static func record(status : GCConnectStatsAPIStatus) {
        guard status.status == 1 else {
            return
        }
        let profile = GCAppGlobal.profile()
        let login = status.garminLogin ?? ""
        let clientId = status.oauth2ClientId ?? ""
        let loginChanged = login != profile.configGet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, defaultValue: "")
        let clientIdChanged = clientId != serverClientId
        if loginChanged {
            RZSLog.info("Garmin login setting changed to '\(login)'")
            profile.configSet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, stringVal: login)
        }
        if clientIdChanged {
            RZSLog.info("Garmin OAuth 2.0 client id from server \(clientId.isEmpty ? "removed" : "changed")")
            profile.configSet(CONFIG_CONNECTSTATS_GARMIN_CLIENT_ID, stringVal: clientId)
        }
        if loginChanged || clientIdChanged {
            GCAppGlobal.saveSettings()
        }
        lock.lock()
        lastAnswer = Date()
        lock.unlock()
    }

    static func clearLastAnswer() {
        lock.lock()
        lastAnswer = nil
        lock.unlock()
    }

    private static var hasRecentAnswer : Bool {
        lock.lock()
        defer { lock.unlock() }
        if let lastAnswer = lastAnswer {
            return Date().timeIntervalSince(lastAnswer) < answerValidity
        }
        return false
    }

    private static var useOAuth2 : Bool {
        guard isOAuth2 else {
            return false
        }
        if GCGarminOAuth2Login.Configuration.current() == nil {
            RZSLog.error("Garmin login setting is oauth2 but no oauth2_client_id available, using OAuth 1.0")
            return false
        }
        return true
    }

    /// Decide the flow for a new login, on the main queue. The check in the request queue normally
    /// answered just before, and this then calls back immediately. The queue doesn't guarantee it though:
    /// after a connection error requests stay queued, and on the next sync a new check lands behind the
    /// left over login. So without a recent answer ask here, and fall back on the last saved value.
    @objc static func resolveUseOAuth2(session : URLSession, completion : @escaping (Bool) -> Void) {
        if hasRecentAnswer {
            completion(useOAuth2)
            return
        }
        guard let url = URL(string: GCWebConnectStatsApiCheck(GCAppGlobal.webConnectsStatsConfig())) else {
            completion(useOAuth2)
            return
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: statusCheckTimeout)
        session.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data, let status = try? JSONDecoder().decode(GCConnectStatsAPIStatus.self, from: data) {
                    record(status: status)
                }else{
                    RZSLog.warning("No answer from status check, using last saved Garmin login setting")
                }
                completion(useOAuth2)
            }
        }.resume()
    }
}

/// PKCE verifier and challenge, RFC 7636
struct GCGarminPKCE {
    let verifier : String
    let challenge : String

    init() {
        self.init(verifier: GCGarminPKCE.randomString())
    }

    init(verifier : String) {
        self.verifier = verifier
        self.challenge = GCGarminPKCE.base64url(Data(SHA256.hash(data: Data(verifier.utf8))))
    }

    /// 256 random bits, as 43 characters all within the verifier alphabet. Also used for the state
    static func randomString() -> String {
        return SymmetricKey(size: .bits256).withUnsafeBytes { base64url(Data($0)) }
    }

    static func base64url(_ data : Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

enum GCGarminOAuth2LoginError : Error {
    case invalidConfiguration
    case noPresentationContext
    case browserFailedToStart
    case authorizationFailed
    case stateMismatch
    case missingCode
    case serverRejected(statusCode : Int)
    case invalidServerResponse
}

/// What the server returns for a new login
@objc class GCGarminOAuth2Credentials : NSObject {
    @objc let tokenId : UInt
    @objc let userId : UInt
    @objc let serverToken : String
    @objc let activityExport : Bool

    @objc init(tokenId : UInt, userId : UInt, serverToken : String, activityExport : Bool) {
        self.tokenId = tokenId
        self.userId = userId
        self.serverToken = serverToken
        self.activityExport = activityExport
        super.init()
    }
}

/// New login with Garmin's OAuth 2.0 PKCE flow. The app only gets a code and hands it to our server:
/// Garmin requires the exchange to run on the backend, which is the only one to hold the client secret.
/// It deliberately doesn't use OAuthSwift as for Strava, as that would call the token endpoint itself.
@objc class GCGarminOAuth2Login : NSObject, ASWebAuthenticationPresentationContextProviding {

    struct Configuration {
        static let defaultAuthorizeUrl = "https://connect.garmin.com/oauth2Confirm"

        let clientId : String
        let authorizeUrl : URL
        let redirectUri : String
        let registerUrl : URL

        static func current() -> Configuration? {
            let config = GCAppGlobal.webConnectsStatsConfig()
            // same choice of service as for the OAuth 1.0 credentials
            let service = (config == .remoteDevTesting || config == .localDevTesting) ? "garmin_dev" : "garmin"
            // The server's value first, the one bundled in credentials.json is only a fallback
            let serverClientId = GCGarminLoginSetting.serverClientId
            let clientId : String = serverClientId.isEmpty ? GCAppGlobal.credentials(forService: service, andKey: "oauth2_client_id") : serverClientId
            guard !clientId.isEmpty && clientId != "***" else {
                return nil
            }
            let configuredUrl : String = GCAppGlobal.credentials(forService: service, andKey: "oauth2_authenticate_url")
            let authorizeUrl = URL(string: configuredUrl.isEmpty ? defaultAuthorizeUrl : configuredUrl)
            let registerUrl = URL(string: GCWebConnectStatsRegisterUserOAuth2(config))
            if let authorizeUrl = authorizeUrl, let registerUrl = registerUrl {
                // This value has to be registered with Garmin
                return Configuration(clientId: clientId,
                                     authorizeUrl: authorizeUrl,
                                     redirectUri: "\(GCAppGlobal.appURLScheme())://ro-z.net/oauth/garmin",
                                     registerUrl: registerUrl)
            }
            return nil
        }
    }

    typealias Browser = (_ authorizationUrl : URL, _ completion : @escaping (URL?, Error?) -> Void) -> Bool

    private let configuration : Configuration
    private let session : URLSession
    private var browser : Browser? = nil
    private var anchor : UIWindow? = nil
    private var authenticationSession : ASWebAuthenticationSession? = nil

    /// Browser can be provided to run the flow without UI
    init(configuration : Configuration, session : URLSession, browser : Browser? = nil) {
        self.configuration = configuration
        self.session = session
        self.browser = browser
        super.init()
    }

    /// nil if no OAuth 2.0 client id is available
    @objc static func forCurrentConfig(session : URLSession) -> GCGarminOAuth2Login? {
        guard let configuration = Configuration.current() else {
            return nil
        }
        return GCGarminOAuth2Login(configuration: configuration, session: session)
    }

    //MARK: - Steps

    static func percentEncode(_ value : String) -> String {
        var allowed = CharacterSet.alphanumerics.intersection(CharacterSet(charactersIn: Unicode.Scalar(0)..<Unicode.Scalar(128)))
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }

    static func formEncoded(_ fields : [(String,String)]) -> String {
        return fields.map { "\(percentEncode($0.0))=\(percentEncode($0.1))" }.joined(separator: "&")
    }

    static func authorizationUrl(configuration : Configuration, pkce : GCGarminPKCE, state : String) -> URL? {
        guard var components = URLComponents(url: configuration.authorizeUrl, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.percentEncodedQuery = formEncoded([
            ("response_type", "code"),
            ("client_id", configuration.clientId),
            ("code_challenge", pkce.challenge),
            ("code_challenge_method", "S256"),
            ("redirect_uri", configuration.redirectUri),
            ("state", state),
        ])
        return components.url
    }

    /// Checks state before looking at anything else in the redirect
    static func authorizationCode(callback : URL, expectedState : String) throws -> String {
        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard items.first(where: { $0.name == "state" })?.value == expectedState else {
            throw GCGarminOAuth2LoginError.stateMismatch
        }
        guard let code = items.first(where: { $0.name == "code" })?.value, !code.isEmpty else {
            throw GCGarminOAuth2LoginError.missingCode
        }
        return code
    }

    /// Form-encoded in the body: these shouldn't end up in logs
    static func registerRequest(configuration : Configuration, code : String, pkce : GCGarminPKCE) -> URLRequest {
        var request = URLRequest(url: configuration.registerUrl)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(formEncoded([
            ("code", code),
            ("code_verifier", pkce.verifier),
            ("redirect_uri", configuration.redirectUri),
        ]).utf8)
        return request
    }

    /// Ids and flags are accepted as number or string, as for the OAuth 1.0 registration
    static func credentials(data : Data?, statusCode : Int) throws -> GCGarminOAuth2Credentials {
        guard (200..<300).contains(statusCode) else {
            throw GCGarminOAuth2LoginError.serverRejected(statusCode: statusCode)
        }
        guard let data = data,
              let json = (try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])) as? [String:Any] else {
            throw GCGarminOAuth2LoginError.invalidServerResponse
        }
        if let error = json["error"], !(error is NSNull) {
            throw GCGarminOAuth2LoginError.serverRejected(statusCode: statusCode)
        }
        func identifier(_ key : String) -> UInt? {
            if let number = json[key] as? NSNumber {
                return number.intValue > 0 ? number.uintValue : nil
            }
            if let string = json[key] as? String, let value = UInt(string), value > 0 {
                return value
            }
            return nil
        }
        guard let tokenId = identifier("token_id"),
              let userId = identifier("cs_user_id"),
              let serverToken = json["server_token"] as? String, !serverToken.isEmpty else {
            throw GCGarminOAuth2LoginError.invalidServerResponse
        }
        // Only warn the user if the server actually says so
        var activityExport = true
        if let number = json["activity_export"] as? NSNumber {
            activityExport = number.boolValue
        }else if let string = json["activity_export"] as? String {
            activityExport = !["false", "0", ""].contains(string.lowercased())
        }
        return GCGarminOAuth2Credentials(tokenId: tokenId, userId: userId, serverToken: serverToken, activityExport: activityExport)
    }

    //MARK: - Flow

    /// Must be called from the main queue. Completion is called on the main queue
    @objc func start(anchor : UIWindow?, completion : @escaping (GCGarminOAuth2Credentials?, Error?) -> Void) {
        let finish : (GCGarminOAuth2Credentials?, Error?) -> Void = { credentials, error in
            DispatchQueue.main.async {
                self.authenticationSession = nil
                completion(credentials, error)
            }
        }

        let pkce = GCGarminPKCE()
        let state = GCGarminPKCE.randomString()
        guard let url = GCGarminOAuth2Login.authorizationUrl(configuration: self.configuration, pkce: pkce, state: state) else {
            finish(nil, GCGarminOAuth2LoginError.invalidConfiguration)
            return
        }

        self.anchor = anchor
        let open : Browser = self.browser ?? self.openAuthenticationSession
        if self.browser == nil && anchor == nil {
            // for example a background request finding the user signed out
            finish(nil, GCGarminOAuth2LoginError.noPresentationContext)
            return
        }

        let started = open(url) { callback, error in
            guard let callback = callback, error == nil else {
                finish(nil, error ?? GCGarminOAuth2LoginError.authorizationFailed)
                return
            }
            do {
                let code = try GCGarminOAuth2Login.authorizationCode(callback: callback, expectedState: state)
                self.register(code: code, pkce: pkce, finish: finish)
            }catch{
                finish(nil, error)
            }
        }
        if !started {
            finish(nil, GCGarminOAuth2LoginError.browserFailedToStart)
        }
    }

    private func register(code : String, pkce : GCGarminPKCE, finish : @escaping (GCGarminOAuth2Credentials?, Error?) -> Void) {
        let request = GCGarminOAuth2Login.registerRequest(configuration: self.configuration, code: code, pkce: pkce)
        self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                finish(nil, error)
                return
            }
            do {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                finish(try GCGarminOAuth2Login.credentials(data: data, statusCode: statusCode), nil)
            }catch{
                finish(nil, error)
            }
        }.resume()
    }

    private func openAuthenticationSession(url : URL, completion : @escaping (URL?, Error?) -> Void) -> Bool {
        guard let scheme = URL(string: self.configuration.redirectUri)?.scheme else {
            return false
        }
        let authenticationSession = ASWebAuthenticationSession(url: url, callback: .customScheme(scheme)) { callback, error in
            completion(callback, error)
        }
        authenticationSession.presentationContextProvider = self
        self.authenticationSession = authenticationSession
        return authenticationSession.start()
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.anchor ?? ASPresentationAnchor()
    }
}
