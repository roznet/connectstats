//  MIT License
//
//  Created on 03/08/2019 for ConnectStats
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
import GenericJSON
import RZFitFile
import RZFitFileTypes

class FITFitFieldMap: NSObject {
    let map : JSON?
    
    override init() {
        let url = URL(fileURLWithPath: RZFileOrganizer.bundleFilePath("fit_map.json"))
        
        if let jsonData = try? Data(contentsOf: url),
            let json = try? JSONDecoder().decode(JSON.self, from: jsonData){
            map = json
        }else{
            map = nil
        }
    }
    
    func messageTypeKey( messageType: RZFitMessageType) -> String? {
        switch (messageType){
        case FIT_MESG_NUM_SESSION:
            return "FIT_MESG_NUM_SESSION"
        case FIT_MESG_NUM_LAP:
            return "FIT_MESG_NUM_LAP"
        case FIT_MESG_NUM_RECORD:
            return "FIT_MESG_NUM_RECORD"
        case FIT_MESG_NUM_LENGTH:
            return "FIT_MESG_NUM_LENGTH"
        default:
            return nil
        }

    }
    
    func fieldKey( messageType : RZFitMessageType, fitField: String) -> String{
        // Default unchanged
        var rv = fitField
        if let key = self.messageTypeKey(messageType: messageType),
            let json = self.map?[key]?.objectValue,
            let mapped = json[fitField]?.stringValue{
            rv = mapped
        }
        return rv
    }
    
}
