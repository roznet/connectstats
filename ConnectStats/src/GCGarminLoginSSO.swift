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

@objc class GCGarminLoginSSO : NSObject {
    
    typealias ssoLoginCompletionHandler = (_ : GCWebStatus) -> Void

    let testing = true
    
    let username : String
    let password : String

    var dataTask : URLSessionDataTask? = nil
    var completion : ssoLoginCompletionHandler? = nil

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
    
    func start() {
        self.preStartStep()
    }
    
    func executeStep(request : URLRequest?,
                     completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void){
        guard let request = request else {
            self.completion?(.internalLogicError)
            return
        }
        
        self.dataTask = URLSession.shared.dataTask(with: request) { data,response,error in
            guard let response = (response as? HTTPURLResponse) else {
                if let error = error {
                    RZSLog.error("Request failed \(error)")
                    self.completion?(.connectionError)
                }else{
                    self.completion?(.internalLogicError)
                }
                return
            }

            if response.statusCode == 200 {
                completionHandler(data,response,error)
            }else{
                let url = self.dataTask?.currentRequest?.url?.absoluteString ?? "nourl"
                RZSLog.error("Service Error \(response.statusCode) \(url)")
                if response.statusCode == 500 || response.statusCode == 403 || response.statusCode == 401{
                    self.completion?(.accessDenied)
                }else{
                    self.completion?(.serviceLogicError)
                }
            }
        }

        guard let task = self.dataTask else {
            self.completion?(.internalLogicError)
            return
        }
        
        task.resume()
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
        getUrlRequest.setValue("NT", forHTTPHeaderField: "nk")
        return getUrlRequest
    }
    func preStartStep(){
        self.executeStep(request: self.preStartStepRequest() ){ data,response,error in
            self.loginStep()
        }
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
        postUrlRequest.setValue("NT", forHTTPHeaderField: "nk")

        return postUrlRequest
    }


    
    func loginStep(){
        self.executeStep(request: self.loginStepRequest() ) { data,response,error in
            // check for specific error in the response
            var status = GCWebStatus.OK
            if //let encoding = response.textEncodingName,
               let data = data,
               let responseText : String = String(data: data, encoding: .utf8) {
                
                if responseText.contains(">sendEvent('FAIL')") {
                    status = .loginFailed
                }else if responseText.contains( ">sendEvent('ACCOUNT_LOCK')" ){
                    status = .accountLocked
                }else if responseText.contains( "renewPassword"){
                    status = .requirePasswordRenew
                }else if responseText.contains("temporarily unavailable") {
                    status = .tempUnavailable
                }
                if status != .OK {
                    RZSLog.warning("Login step failed \(GCWebStatusShortDescription(status))")
                    try? responseText.write(to: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath("error_garmin_sso.html")), atomically: true, encoding: .utf8)
                }
            }
            
            if status == .OK {
                self.cookieStep()
            }else{
                self.completion?(status)
            }
        }
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
        self.executeStep(request: self.cookieStepRequest() ) { data,response,error in
            try? data?.write(to: URL(fileURLWithPath: RZFileOrganizer.writeableFilePath("garmin_sso_final.html")))
            self.completion?(.OK)
        }
    }
}
