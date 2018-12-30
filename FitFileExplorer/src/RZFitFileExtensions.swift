//  MIT License
//
//  Created on 25/12/2018 for ConnectStats
//
//  Copyright (c) 2018 Brice Rosenzweig
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

extension RZFitFile {
    
    convenience init(fitFile file: FITFitFile){
        var messages :[RZFitMessage] = []
        
        for one in file.allMessageFields() {
            if let field = RZFitMessage(with: one) {
                messages.append(field)
            }
        }
        
        self.init(messages: messages)
    }
    
    func preferredMessageType() -> RZFitMessageType {
        let preferred = [ FIT_MESG_NUM_SESSION, FIT_MESG_NUM_RECORD, FIT_MESG_NUM_FILE_ID]
        for one in preferred {
            if self.messageTypes.contains(one) {
                return one
            }
        }
        return FIT_MESG_NUM_FILE_ID
    }
    
    func fieldKeys( messageType: RZFitMessageType ) -> [RZFitFieldKey] {
        return Array(self.sampleValues(messageType: messageType).keys)
    }
    
    func sampleValues( messageType: RZFitMessageType) -> [RZFitFieldKey:RZFitFieldValue] {
        var rv : [RZFitFieldKey:RZFitFieldValue] = [:]
        let forMessages = self.messages(forMessageType: messageType)
        for one in forMessages {
            for (key,val) in one.interpretedFields() {
                if rv[key] == nil {
                    rv[key] = val
                }
            }
        }
        return rv
    }
}
