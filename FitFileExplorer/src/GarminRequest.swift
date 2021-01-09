//  MIT License
//
//  Created on 06/01/2019 for FitFileExplorer
//
//  Copyright (c) 2019 Brice Rosenzweig
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

class GarminRequest : GCWebRequestStandard {
    
    static let errors : [String:GCWebStatus] = [
        "Invalid username/password combination." : GCWebStatus.accessDenied,
        //"You are signed in as": GCWebStatus.
        "HTTP Status 403 - " : GCWebStatus.accessDenied,
        "HTTP Status 404 - " : GCWebStatus.deletedActivity,
        "Garmin Connect is temporarily unavailable" : GCWebStatus.tempUnavailable,
        "id=\"error\">Error 500" : GCWebStatus.serviceLogicError,
        "HTTP Status 500 - " : GCWebStatus.accessDenied,
        "\"error\":\"WebApplicationException\"" : GCWebStatus.accessDenied

    ]
    
    
    override func checkNoErrors() -> Bool {
        if self.status == GCWebStatus.OK {
            for (key,val) in GarminRequest.errors {
                if  self.theString.contains(key) {
                    self.status = val
                    break
                }
            }
        }
        
        return self.status == GCWebStatus.OK
    }
    
    override func remediationReq() -> GCWebRequest? {
        if self.status == GCWebStatus.accessDenied {
            self.status = GCWebStatus.OK
            self.stage = gcRequestStage.download
            
            return GarminRequestLogin(username: FITAppGlobal.currentLoginName(), password: FITAppGlobal.currentPassword())
        }
        
        return nil
    }
}
