//  MIT License
//
//  Created on 08/01/2021 for ConnectStats
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
import RZUtilsSwift

@objc class GCGarminSSOLogin : NSObject {
    @objc enum GarminSSOLoginStatus : Int {
        case success
        case internalError
        case prestartError
        case ssoError
        case loginFailed
        case accountLocked
        case renewPassword
    }

    typealias ssoLoginCompletionHandler = (_ : GarminSSOLoginStatus) -> Void

    let testing = true
    
    let username : String
    let password : String

    var dataTask : URLSessionDataTask? = nil
    let completion : ssoLoginCompletionHandler

    let getParams = [
        "service":"https://connect.garmin.com/modern",
        "clientId":"GarminConnect",
        "gauthHost":"https://sso.garmin.com/sso",
        "consumeServiceTicket": "false"
    ]

    var postParams : [String:String] {
        [ "username" : self.username,
          "password" : self.password,
          "_eventId" : "submit",
          "embed" : "true" ]
    }
    
    //MARK: - init
    
    init(username: String, password:String,  handler: @escaping ssoLoginCompletionHandler) {
        self.username = username
        self.password = password
        self.completion = handler
    }
    
    func login() {
        self.preStartStep()
    }
    
    //MARK: - pre Start Step
    
    func preStartStepRequest() -> URLRequest? {
        //let urlString = "https://localhost.ro-z.me/sso/signin"
        let urlString = "https://sso.garmin.com/sso/signin"
        
        guard let getUrlString = RZWebEncodeURLwGet(urlString, self.getParams),
              let getUrl = URL(string: getUrlString) else{
            return nil
        }
        
        var getUrlRequest = URLRequest(url: getUrl)
        getUrlRequest.setValue("https://connectstats.app", forHTTPHeaderField: "Referer")
        return getUrlRequest
    }
    func preStartStep(){
        guard let request = self.preStartStepRequest() else {
            self.completion(.internalError)
            return
        }
        
        self.dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
            guard let response = (response as? HTTPURLResponse) else {
                self.completion(.internalError)
                return
            }
            
            guard response.statusCode == 200 else {
                RZSLog.error("preStart Error \(response.statusCode)")
                self.completion(.prestartError)
                return
            }
            
            self.loginStep()
        }
        guard let task = self.dataTask else {
            completion(.internalError)
            return
        }
        
        task.resume()
    }
    
    //MARK: - login step
    
    func loginStepRequest() -> URLRequest? {
        //let urlString = "https://localhost.ro-z.me/sso/signin"
        let urlString = "https://sso.garmin.com/sso/signin"
        
        guard let getUrlString = RZWebEncodeURLwGet(urlString, self.getParams),
              let postUrl = URL(string: getUrlString) else{
            return nil
        }
        
        var postUrlRequest : URLRequest = URLRequest(url: postUrl)
        postUrlRequest.httpMethod = "POST"
        postUrlRequest.httpBody = RZWebEncodeDictionary(self.postParams).data(using: .utf8)
        postUrlRequest.setValue("https://sso.garmin.com", forHTTPHeaderField: "origin")

        return postUrlRequest
    }
    
    func loginStep(){
        guard let request = self.loginStepRequest() else {
            self.completion(.internalError)
            return
        }
        
        self.dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
            guard let response = (response as? HTTPURLResponse) else {
                self.completion(.internalError)
                return
            }
            
            guard response.statusCode == 200 else {
                RZSLog.error("login Error \(response.statusCode)")
                self.completion(.ssoError)
                return
            }
            // check for specific error in the response
            var status = GarminSSOLoginStatus.success
            if //let encoding = response.textEncodingName,
               let data = data,
               let responseText : String = String(data: data, encoding: .utf8) {
                if responseText.contains(">sendEvent('FAIL')") {
                    status = .loginFailed
                }else if responseText.contains( ">sendEvent('ACCOUNT_LOCK')" ){
                    status = .accountLocked
                }else if responseText.contains( "renewPassword"){
                    status = .renewPassword
                }
            }
            
            if status == .success {
                self.cookieStep()
            }else{
                self.completion(status)
            }
        }

        guard let task = self.dataTask else {
            completion(.internalError)
            return
        }
        
        task.resume()
    }
    
    //MARK: - cookie Step
    
    func cookieStepRequest() -> URLRequest? {
        //let urlString = "https://localhost.ro-z.me/sso/modern"
        let urlString = "https://connect.garmin.com/modern"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return URLRequest(url: url)
    }
    
    func cookieStep(){
        guard let request = self.cookieStepRequest() else {
            self.completion(.internalError)
            return
        }
        
        self.dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
            guard let response = (response as? HTTPURLResponse) else {
                self.completion(.internalError)
                return
            }
            
            guard response.statusCode == 200 else {
                RZSLog.error("Garmin Access Error \(response.statusCode)")
                self.completion(.ssoError)
                return
            }
            
            self.completion(.success)
        }

        guard let task = self.dataTask else {
            completion(.internalError)
            return
        }
        
        task.resume()
    }

    
}
