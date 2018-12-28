//
//  fit_file.swift
//  fittestswift
//
//  Created by Brice Rosenzweig on 16/12/2018.
//  Copyright © 2018 Brice Rosenzweig. All rights reserved.
//

import Foundation

class RZFitFile {

    var messages : [RZFitMessage]
    var messagesNum : Set<FIT_MESG_NUM>
    
    init(  messages input: [RZFitMessage] ){
        var bldmsgnum : Set<FIT_MESG_NUM> = []
        for one in input {
            bldmsgnum.insert(one.num)
        }
        messages = input
        messagesNum = bldmsgnum
    }
    
    init( data : Data){
        var state : FIT_CONVERT_STATE = FIT_CONVERT_STATE()
        var convert_return : FIT_CONVERT_RETURN = FIT_CONVERT_CONTINUE
        
        FitConvert_Init(&state, FIT_TRUE)
        
        var bldmsg :[RZFitMessage] = []
        var bldmsgnum : Set<FIT_MESG_NUM> = []
        while convert_return == FIT_CONVERT_CONTINUE {
            data.withUnsafeBytes({ (ptr: UnsafePointer<UInt8>) in
                repeat {
                    convert_return = FitConvert_Read(&state, ptr, FIT_UINT32(data.count))
                    
                    switch convert_return {
                    case FIT_CONVERT_MESSAGE_AVAILABLE:
                        let mesg = FitConvert_GetMessageNumber(&state)
                        bldmsgnum.insert(mesg)
                        if let uptr : UnsafePointer<UInt8> = FitConvert_GetMessageData(&state) {
                            if let fmesg = rzfit_build_mesg(num: mesg, uptr: uptr)
                            {
                                bldmsg.append(fmesg)
                            }
                        }
                    default:
                        break
                    }
                } while convert_return == FIT_CONVERT_MESSAGE_AVAILABLE
            } )
        }
        messages = bldmsg
        messagesNum = bldmsgnum
    }

    convenience init?( file :URL){
        if let data = try? Data(contentsOf: file) {
            self.init(data: data)
        }else{
            return nil
        }
    }
 
    func messages(forMessage:FIT_MESG_NUM) -> [RZFitMessage] {
        var rv : [RZFitMessage] = []
        for one in messages {
            if one.num == forMessage {
                rv.append(one)
            }
        }
        return rv
    }
    
    func allMessageTypes() -> [String] {
        var rv : [String] = []
        for one in messagesNum {
            if let oneStr = rzfit_mesg_num_string(input: one) {
                rv.append(oneStr)
            }
        }
        return rv
    }
    
}
