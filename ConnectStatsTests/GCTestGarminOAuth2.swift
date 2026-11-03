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



import XCTest
@testable import ConnectStats

/// Answers every request from a handler and records what was asked
class GCTestMockServer : URLProtocol {
    typealias Handler = (URLRequest) -> (Int, Data?, Error?)

    nonisolated(unsafe) static var handler : Handler = { _ in (500, nil, nil) }
    nonisolated(unsafe) static var requests : [URLRequest] = []
    nonisolated(unsafe) static var bodies : [String] = []

    static func reset(handler : @escaping Handler) {
        self.handler = handler
        self.requests = []
        self.bodies = []
    }

    static func session() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [GCTestMockServer.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { return true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }
    override func stopLoading() {}

    override func startLoading() {
        var body = Data()
        if let stream = self.request.httpBodyStream {
            stream.open()
            var buffer = [UInt8](repeating: 0, count: 4096)
            while stream.hasBytesAvailable {
                let count = stream.read(&buffer, maxLength: buffer.count)
                if count <= 0 { break }
                body.append(buffer, count: count)
            }
            stream.close()
        }
        GCTestMockServer.requests.append(self.request)
        GCTestMockServer.bodies.append(String(data: body, encoding: .utf8) ?? "")

        let (statusCode, data, error) = GCTestMockServer.handler(self.request)
        if let error = error {
            self.client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let response = HTTPURLResponse(url: self.request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if let data = data {
            self.client?.urlProtocol(self, didLoad: data)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
}

class GCTestGarminOAuth2: XCTestCase {
    let path = "https://example.test/prod/api/connectstats/search"
    let serverToken = "test-server-token"
    let tokenId : UInt = 987654321
    let userId : UInt = 456

    let configuration = GCGarminOAuth2Login.Configuration(clientId: "client id",
                                                          authorizeUrl: URL(string: "https://example.test/oauth2Confirm")!,
                                                          redirectUri: "connectstats://ro-z.net/oauth/garmin",
                                                          registerUrl: URL(string: "https://example.test/prod/api/connectstats/user_register_oauth2")!)

    private var savedConfig : [String:Any] = [:]
    private var savedPassword : String = ""

    override func setUpWithError() throws {
        let profile = GCAppGlobal.profile()
        self.savedPassword = profile.currentPassword(for: gcService.connectStats) ?? ""
        self.savedConfig = [
            CONFIG_CONNECTSTATS_GARMIN_LOGIN : profile.configGet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, defaultValue: "") as Any,
            CONFIG_CONNECTSTATS_TOKEN : profile.configGet(CONFIG_CONNECTSTATS_TOKEN, defaultValue: "") as Any,
            CONFIG_CONNECTSTATS_TOKEN_ID : profile.configGetInt(CONFIG_CONNECTSTATS_TOKEN_ID, defaultValue: 0),
            CONFIG_CONNECTSTATS_USER_ID : profile.configGetInt(CONFIG_CONNECTSTATS_USER_ID, defaultValue: 0),
        ]
        GCConnectStatsRequest.signout()
        profile.configSet(CONFIG_CONNECTSTATS_TOKEN, stringVal: "")
        profile.configSet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, stringVal: "")
        GCGarminLoginSetting.clearLastAnswer()
    }

    override func tearDownWithError() throws {
        GCConnectStatsRequest.signout()
        let profile = GCAppGlobal.profile()
        profile.configSet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, stringVal: self.savedConfig[CONFIG_CONNECTSTATS_GARMIN_LOGIN] as? String ?? "")
        profile.configSet(CONFIG_CONNECTSTATS_TOKEN, stringVal: self.savedConfig[CONFIG_CONNECTSTATS_TOKEN] as? String ?? "")
        profile.configSet(CONFIG_CONNECTSTATS_TOKEN_ID, intVal: self.savedConfig[CONFIG_CONNECTSTATS_TOKEN_ID] as? Int ?? 0)
        profile.configSet(CONFIG_CONNECTSTATS_USER_ID, intVal: self.savedConfig[CONFIG_CONNECTSTATS_USER_ID] as? Int ?? 0)
        profile.setPassword(self.savedPassword, for: gcService.connectStats)
        GCGarminLoginSetting.clearLastAnswer()
    }

    private func status(_ json : String) throws -> GCConnectStatsAPIStatus {
        return try JSONDecoder().decode(GCConnectStatsAPIStatus.self, from: Data(json.utf8))
    }

    private func formFields(_ body : String) -> [String:String] {
        var rv : [String:String] = [:]
        for pair in body.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
            rv[parts[0].removingPercentEncoding ?? ""] = parts.count > 1 ? parts[1].removingPercentEncoding : ""
        }
        return rv
    }

    private func oauth2Credentials(activityExport : Bool = true) -> GCGarminOAuth2Credentials {
        return GCGarminOAuth2Credentials(tokenId: self.tokenId, userId: self.userId, serverToken: self.serverToken, activityExport: activityExport)
    }

    /// As a request fresh from the store
    private func loginWithOAuth2() throws {
        XCTAssertTrue(GCConnectStatsRequest()!.completeOAuth2Login(self.oauth2Credentials()))
    }

    /// Same state as a user that logged in on an earlier version
    private func loginWithOAuth1() {
        let profile = GCAppGlobal.profile()
        profile.configSet(CONFIG_CONNECTSTATS_TOKEN, stringVal: "oauth1-token")
        profile.setPassword("oauth1-secret", for: gcService.connectStats)
        profile.configSet(CONFIG_CONNECTSTATS_TOKEN_ID, intVal: 123)
        profile.configSet(CONFIG_CONNECTSTATS_USER_ID, intVal: 456)
    }

    //MARK: - PKCE

    func testPKCEMatchesRFC7636Example() {
        let pkce = GCGarminPKCE(verifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
        XCTAssertEqual(pkce.challenge, "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")
    }

    func testPKCEGeneratedVerifierIsValidAndRandom() {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let pkce = GCGarminPKCE()
        XCTAssertGreaterThanOrEqual(pkce.verifier.count, 43)
        XCTAssertLessThanOrEqual(pkce.verifier.count, 128)
        XCTAssertTrue(pkce.verifier.unicodeScalars.allSatisfy { allowed.contains($0) })
        XCTAssertNotEqual(pkce.verifier, GCGarminPKCE().verifier)
    }

    //MARK: - Authorization and redirect

    func testAuthorizationUrl() throws {
        let pkce = GCGarminPKCE(verifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
        let url = try XCTUnwrap(GCGarminOAuth2Login.authorizationUrl(configuration: self.configuration, pkce: pkce, state: "a-state"))
        XCTAssertTrue(url.absoluteString.hasPrefix("https://example.test/oauth2Confirm?"))
        let items = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
        let query = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(query, [
            "response_type" : "code",
            "client_id" : "client id",
            "code_challenge" : pkce.challenge,
            "code_challenge_method" : "S256",
            "redirect_uri" : "connectstats://ro-z.net/oauth/garmin",
            "state" : "a-state",
        ])
        XCTAssertFalse(url.absoluteString.contains(pkce.verifier), "verifier must not be sent to Garmin")
    }

    func testRedirectChecksState() throws {
        let good = URL(string: "connectstats://ro-z.net/oauth/garmin?code=a-code&state=expected")!
        XCTAssertEqual(try GCGarminOAuth2Login.authorizationCode(callback: good, expectedState: "expected"), "a-code")

        let badUrls = [
            "connectstats://ro-z.net/oauth/garmin?code=a-code&state=other",
            "connectstats://ro-z.net/oauth/garmin?code=a-code",
            "connectstats://ro-z.net/oauth/garmin?state=expected",
            "connectstats://ro-z.net/oauth/garmin?state=expected&code=",
            "connectstats://ro-z.net/oauth/garmin?error=access_denied&state=expected",
        ]
        for one in badUrls {
            XCTAssertThrowsError(try GCGarminOAuth2Login.authorizationCode(callback: URL(string: one)!, expectedState: "expected"), one)
        }
    }

    //MARK: - Server contract

    func testRegisterRequestSendsSecretsInBodyOnly() throws {
        let pkce = GCGarminPKCE(verifier: "a+verifier/value")
        let request = GCGarminOAuth2Login.registerRequest(configuration: self.configuration, code: "a code&more", pkce: pkce)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
        XCTAssertEqual(request.url?.absoluteString, "https://example.test/prod/api/connectstats/user_register_oauth2")
        let body = try XCTUnwrap(String(data: try XCTUnwrap(request.httpBody), encoding: .utf8))
        XCTAssertEqual(self.formFields(body), [
            "code" : "a code&more",
            "code_verifier" : "a+verifier/value",
            "redirect_uri" : "connectstats://ro-z.net/oauth/garmin",
        ])
    }

    func testRegisterResponseParsing() throws {
        func parse(_ json : String, statusCode : Int = 200) throws -> GCGarminOAuth2Credentials {
            return try GCGarminOAuth2Login.credentials(data: Data(json.utf8), statusCode: statusCode)
        }
        let full = try parse(#"{"token_id": 123, "cs_user_id": 456, "server_token": "abc", "activity_export": true}"#)
        XCTAssertEqual(full.tokenId, 123)
        XCTAssertEqual(full.userId, 456)
        XCTAssertEqual(full.serverToken, "abc")
        XCTAssertTrue(full.activityExport)

        // PHP can easily send numbers as strings and booleans as numbers
        let strings = try parse(#"{"token_id": "123", "cs_user_id": "456", "server_token": "abc", "activity_export": "0"}"#)
        XCTAssertEqual(strings.tokenId, 123)
        XCTAssertFalse(strings.activityExport)
        XCTAssertFalse(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": "abc", "activity_export": false}"#).activityExport)
        XCTAssertFalse(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": "abc", "activity_export": 0}"#).activityExport)
        XCTAssertTrue(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": "abc"}"#).activityExport)
        XCTAssertTrue(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": "abc", "error": null}"#).activityExport)

        XCTAssertThrowsError(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": "abc"}"#, statusCode: 400))
        XCTAssertThrowsError(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": "abc"}"#, statusCode: 500))
        XCTAssertThrowsError(try parse(#"{"error": "invalid_grant"}"#))
        XCTAssertThrowsError(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": "abc", "error": "x"}"#))
        XCTAssertThrowsError(try parse(#"{"cs_user_id": 2, "server_token": "abc"}"#))
        XCTAssertThrowsError(try parse(#"{"token_id": 0, "cs_user_id": 2, "server_token": "abc"}"#))
        XCTAssertThrowsError(try parse(#"{"token_id": 1, "server_token": "abc"}"#))
        XCTAssertThrowsError(try parse(#"{"token_id": 1, "cs_user_id": 2}"#))
        XCTAssertThrowsError(try parse(#"{"token_id": 1, "cs_user_id": 2, "server_token": ""}"#))
        XCTAssertThrowsError(try parse("<html>not json</html>"))
        XCTAssertThrowsError(try GCGarminOAuth2Login.credentials(data: nil, statusCode: 200))
    }

    //MARK: - Setting

    func testSettingFromStatusCheck() throws {
        XCTAssertFalse(GCGarminLoginSetting.isOAuth2, "off by default")

        GCGarminLoginSetting.record(status: try self.status(#"{"status": 1, "garmin_login": "oauth2"}"#))
        XCTAssertTrue(GCGarminLoginSetting.isOAuth2)

        // an unsuccessful answer isn't an answer: keep what was saved
        GCGarminLoginSetting.record(status: try self.status(#"{"status": 0}"#))
        XCTAssertTrue(GCGarminLoginSetting.isOAuth2)

        GCGarminLoginSetting.record(status: try self.status(#"{"status": 1, "garmin_login": "OAUTH2"}"#))
        XCTAssertFalse(GCGarminLoginSetting.isOAuth2, "any other value means OAuth 1.0")

        GCGarminLoginSetting.record(status: try self.status(#"{"status": 1, "garmin_login": "oauth2"}"#))
        GCGarminLoginSetting.record(status: try self.status(#"{"status": 1}"#))
        XCTAssertFalse(GCGarminLoginSetting.isOAuth2, "absent turns it back off")
    }

    func testUnexpectedSettingTypeKeepsRestOfStatus() throws {
        let decoded = try self.status(#"{"status": 1, "redirect": "https://ro-z.net/prod", "garmin_login": 2}"#)
        XCTAssertEqual(decoded.status, 1)
        XCTAssertEqual(decoded.redirect, "https://ro-z.net/prod")
        XCTAssertNil(decoded.garminLogin)
    }

    private func resolve(file : StaticString = #filePath, line : UInt = #line) -> Bool {
        let done = self.expectation(description: "resolved")
        var result = false
        GCGarminLoginSetting.resolveUseOAuth2(session: GCTestMockServer.session()) { useOAuth2 in
            result = useOAuth2
            done.fulfill()
        }
        self.wait(for: [done], timeout: 10.0)
        return result
    }

    func testResolveAsksWithoutRecentAnswer() throws {
        GCTestMockServer.reset { _ in (200, Data(#"{"status": 1}"#.utf8), nil) }
        XCTAssertFalse(self.resolve())
        XCTAssertEqual(GCTestMockServer.requests.count, 1)
        XCTAssertEqual(GCTestMockServer.requests.first?.url?.absoluteString, GCWebConnectStatsApiCheck(GCAppGlobal.webConnectsStatsConfig()))

        // the answer just received is recent: no need to ask again
        XCTAssertFalse(self.resolve())
        XCTAssertEqual(GCTestMockServer.requests.count, 1)
    }

    func testResolveWithoutAnswerUsesLastSavedValue() throws {
        let failed = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        GCTestMockServer.reset { _ in (0, nil, failed) }
        XCTAssertFalse(self.resolve(), "nothing saved means OAuth 1.0")
        XCTAssertEqual(GCTestMockServer.requests.count, 1)

        GCAppGlobal.profile().configSet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, stringVal: "off")
        GCTestMockServer.reset { _ in (200, Data("<html>down</html>".utf8), nil) }
        XCTAssertFalse(self.resolve(), "other saved value is OAuth 1.0")
        XCTAssertEqual(GCAppGlobal.profile().configGet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, defaultValue: ""), "off", "a useless answer doesn't change it")
    }

    func testResolveUsesOAuth1WithoutClientId() throws {
        // sample credentials have no usable client id, and neither will a build made before Garmin's conversion
        try XCTSkipIf(GCGarminOAuth2Login.Configuration.current() != nil, "credentials.json has an oauth2_client_id")
        GCTestMockServer.reset { _ in (200, Data(#"{"status": 1, "garmin_login": "oauth2"}"#.utf8), nil) }
        XCTAssertFalse(self.resolve())
        XCTAssertTrue(GCGarminLoginSetting.isOAuth2)
    }

    //MARK: - Login flow, with a mock server and no browser

    private func runFlow(browser : @escaping GCGarminOAuth2Login.Browser) -> (GCGarminOAuth2Credentials?, Error?) {
        let done = self.expectation(description: "login finished")
        var result : (GCGarminOAuth2Credentials?, Error?) = (nil, nil)
        let login = GCGarminOAuth2Login(configuration: self.configuration, session: GCTestMockServer.session(), browser: browser)
        login.start(anchor: nil) { credentials, error in
            result = (credentials, error)
            done.fulfill()
        }
        self.wait(for: [done], timeout: 10.0)
        return result
    }

    private func redirect(for url : URL, code : String = "a-code") -> URL {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let state = items.first { $0.name == "state" }?.value ?? ""
        return URL(string: "connectstats://ro-z.net/oauth/garmin?code=\(code)&state=\(state)")!
    }

    func testFlowSuccessMatchesVerifierAndChallenge() throws {
        GCTestMockServer.reset { _ in
            (200, Data(#"{"token_id": 123, "cs_user_id": 456, "server_token": "abc", "activity_export": false}"#.utf8), nil)
        }
        var authorizationUrl : URL? = nil
        let (credentials, error) = self.runFlow { url, completion in
            authorizationUrl = url
            completion(self.redirect(for: url), nil)
            return true
        }
        XCTAssertNil(error)
        XCTAssertEqual(credentials?.serverToken, "abc")
        XCTAssertEqual(credentials?.tokenId, 123)
        XCTAssertEqual(credentials?.activityExport, false)

        XCTAssertEqual(GCTestMockServer.requests.count, 1)
        XCTAssertEqual(GCTestMockServer.requests.first?.httpMethod, "POST")
        XCTAssertEqual(GCTestMockServer.requests.first?.url, self.configuration.registerUrl)
        let fields = self.formFields(try XCTUnwrap(GCTestMockServer.bodies.first))
        XCTAssertEqual(fields["code"], "a-code")
        XCTAssertEqual(fields["redirect_uri"], self.configuration.redirectUri)

        // the verifier sent to the server is the one the challenge sent to Garmin was made from
        let items = URLComponents(url: try XCTUnwrap(authorizationUrl), resolvingAgainstBaseURL: false)?.queryItems ?? []
        let challenge = items.first { $0.name == "code_challenge" }?.value
        XCTAssertEqual(GCGarminPKCE(verifier: try XCTUnwrap(fields["code_verifier"])).challenge, challenge)
    }

    func testFlowDoesNotCallServerOnBadRedirect() throws {
        GCTestMockServer.reset { _ in (200, nil, nil) }

        let (_, wrongState) = self.runFlow { _, completion in
            completion(URL(string: "connectstats://ro-z.net/oauth/garmin?code=a-code&state=forged")!, nil)
            return true
        }
        XCTAssertNotNil(wrongState)

        let cancelled = NSError(domain: "com.apple.AuthenticationServices.WebAuthenticationSession", code: 1)
        let (_, cancelledError) = self.runFlow { _, completion in
            completion(nil, cancelled)
            return true
        }
        XCTAssertEqual((cancelledError as NSError?)?.code, 1)

        let (_, notStarted) = self.runFlow { _, _ in false }
        XCTAssertNotNil(notStarted)

        XCTAssertEqual(GCTestMockServer.requests.count, 0)
    }

    func testFlowFailsWhenServerRejects() throws {
        GCTestMockServer.reset { _ in (400, Data(#"{"error": "invalid_grant"}"#.utf8), nil) }
        let (credentials, error) = self.runFlow { url, completion in
            completion(self.redirect(for: url), nil)
            return true
        }
        XCTAssertNil(credentials)
        XCTAssertNotNil(error)
    }

    func testFlowWithoutPresentationContextFails() throws {
        GCTestMockServer.reset { _ in (200, nil, nil) }
        let done = self.expectation(description: "login finished")
        let login = GCGarminOAuth2Login(configuration: self.configuration, session: GCTestMockServer.session())
        login.start(anchor: nil) { credentials, error in
            XCTAssertNil(credentials)
            XCTAssertNotNil(error)
            done.fulfill()
        }
        self.wait(for: [done], timeout: 10.0)
    }

    //MARK: - Signing requests

    func testNotSignedInByDefault() throws {
        XCTAssertFalse(GCConnectStatsRequest()!.isSignedIn())
    }

    func testOAuth2LoginSignsWithBearer() throws {
        try self.loginWithOAuth2()

        let request : GCConnectStatsRequest = GCConnectStatsRequest()!
        XCTAssertTrue(request.isSignedIn())
        XCTAssertEqual(request.tokenId, self.tokenId)
        XCTAssertEqual(request.userId, self.userId)

        let params : [AnyHashable:Any] = ["token_id" : self.tokenId, "start" : 20, "name" : "a b&c", "enabled" : true]
        let prepared = request.preparedUrlRequest(self.path, params: params)
        XCTAssertEqual(prepared.value(forHTTPHeaderField: "Authorization"), "Bearer \(self.serverToken)")
        XCTAssertEqual(prepared.httpMethod, "GET")

        let items = try XCTUnwrap(URLComponents(url: try XCTUnwrap(prepared.url), resolvingAgainstBaseURL: false)?.queryItems)
        let query = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(query, ["token_id" : "\(self.tokenId)", "start" : "20", "name" : "a b&c", "enabled" : "1"])
        XCTAssertFalse(try XCTUnwrap(prepared.url).absoluteString.contains(self.serverToken), "token must not be in the url")
    }

    func testBearerOnAllRequestTypes() throws {
        try self.loginWithOAuth2()
        let bearer = "Bearer \(self.serverToken)"

        let nextRequest : GCConnectStatsRequest = GCConnectStatsRequest(nextWith: GCConnectStatsRequest()!)
        XCTAssertEqual(nextRequest.preparedUrlRequest(self.path, params: [:]).value(forHTTPHeaderField: "Authorization"), bearer)

        let search = GCConnectStatsRequestSearch.request(withStart: 0, mode: false, andNavigationController: nil)
        XCTAssertEqual(search.preparedUrlRequest()?.value(forHTTPHeaderField: "Authorization"), bearer)

        let backgroundSearch = GCConnectStatsRequestBackgroundSearch(requestMode: .downloadAndProcess, cacheDb: FMDatabase())
        XCTAssertEqual(backgroundSearch.preparedUrlRequest()?.value(forHTTPHeaderField: "Authorization"), bearer)

        let validate = GCConnectStatsRequestLogin.request(nil)
        XCTAssertEqual(validate.preparedUrlRequest()?.value(forHTTPHeaderField: "Authorization"), bearer)
    }

    func testUnauthorizedForcesNewLogin() throws {
        class Delegate : NSObject, GCWebRequestDelegate {
            func processDone(_ req: Any?) {}
            func processNewStage() {}
            func loginSuccess(_ service: gcWebService) {}
            func requireLogin(_ service: gcWebService) {}
            func lastStatusCode() -> Int { return 401 }
        }
        try self.loginWithOAuth2()
        let delegate = Delegate()
        let request : GCConnectStatsRequest = GCConnectStatsRequest()!
        request.delegate = delegate

        XCTAssertFalse(request.checkNoErrors())
        XCTAssertEqual(request.status, GCWebStatus.loginFailed)
        XCTAssertFalse(GCConnectStatsRequest()!.isSignedIn())
    }

    func testSignoutClearsOAuth2() throws {
        try self.loginWithOAuth2()
        XCTAssertTrue(GCConnectStatsRequest()!.isSignedIn())

        GCConnectStatsRequest.signout()
        XCTAssertFalse(GCConnectStatsRequest()!.isSignedIn())

        // the token is really gone: coming back with the same token_id doesn't find it
        GCAppGlobal.profile().configSet(CONFIG_CONNECTSTATS_TOKEN_ID, intVal: Int(self.tokenId))
        GCAppGlobal.profile().configSet(CONFIG_CONNECTSTATS_USER_ID, intVal: Int(self.userId))
        XCTAssertFalse(GCConnectStatsRequest()!.isSignedIn())
    }

    func testOAuth1UserUnaffectedBySetting() throws {
        self.loginWithOAuth1()

        for setting in ["", "oauth2"] {
            GCAppGlobal.profile().configSet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, stringVal: setting)
            let request : GCConnectStatsRequest = GCConnectStatsRequest()!
            XCTAssertTrue(request.isSignedIn(), "setting '\(setting)'")
            XCTAssertEqual(request.tokenId, 123)
            let prepared = request.preparedUrlRequest(self.path, params: ["token_id" : 123])
            let header = try XCTUnwrap(prepared.value(forHTTPHeaderField: "Authorization"))
            XCTAssertTrue(header.hasPrefix("OAuth "), "setting '\(setting)'")
            XCTAssertTrue(header.contains("oauth_token=\"oauth1-token\""), "setting '\(setting)'")
        }
    }

    func testOAuth2UserUnaffectedBySetting() throws {
        GCAppGlobal.profile().configSet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, stringVal: "oauth2")
        try self.loginWithOAuth2()

        // setting turned back off after login
        GCAppGlobal.profile().configSet(CONFIG_CONNECTSTATS_GARMIN_LOGIN, stringVal: "")
        let request : GCConnectStatsRequest = GCConnectStatsRequest()!
        XCTAssertTrue(request.isSignedIn())
        XCTAssertEqual(request.preparedUrlRequest(self.path, params: [:]).value(forHTTPHeaderField: "Authorization"), "Bearer \(self.serverToken)")
    }

    func testOAuth2LoginReplacesOAuth1Leftovers() throws {
        self.loginWithOAuth1()
        GCConnectStatsRequest.signout()
        try self.loginWithOAuth2()

        XCTAssertEqual(GCAppGlobal.profile().configGet(CONFIG_CONNECTSTATS_TOKEN, defaultValue: "x"), "")
        let request : GCConnectStatsRequest = GCConnectStatsRequest()!
        XCTAssertTrue(request.isSignedIn())
        XCTAssertEqual(request.preparedUrlRequest(self.path, params: [:]).value(forHTTPHeaderField: "Authorization"), "Bearer \(self.serverToken)")
    }
}
