//
//  fit_file.swift
//  fittestswift
//
//  Created by Brice Rosenzweig on 16/12/2018.
//  Copyright © 2018 Brice Rosenzweig. All rights reserved.
//

import Foundation

class RZFitFile {

    typealias RZFitMessageType = FIT_MESG_NUM
    
    public private(set) var messages : [RZFitMessage]
    public private(set) var messageTypes : Set<RZFitMessageType>
    public private(set) var messagesByType : [RZFitMessageType:[RZFitMessage]]
    
    init(  messages input: [RZFitMessage] ){
        var bldmsgnum : Set<RZFitMessageType> = []
        var bldmsgbytype : [RZFitMessageType:[RZFitMessage]] = [:]
        for one in input {
            bldmsgnum.insert(one.num)
            if var prev = bldmsgbytype[one.num] {
                prev.append(one)
                bldmsgbytype[one.num] = prev
            }else{
                bldmsgbytype[one.num] = [ one ]
            }
        }
        messages = input
        messageTypes = bldmsgnum
        messagesByType = bldmsgbytype
    }
    
    init( data : Data){
        var state : FIT_CONVERT_STATE = FIT_CONVERT_STATE()
        var convert_return : FIT_CONVERT_RETURN = FIT_CONVERT_CONTINUE
        
        FitConvert_Init(&state, FIT_TRUE)
        
        var bldmsg :[RZFitMessage] = []
        var bldmsgnum : Set<RZFitMessageType> = []
        var bldmsgbytype : [RZFitMessageType:[RZFitMessage]] = [:]
        
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
                                if var prev = bldmsgbytype[fmesg.num] {
                                    prev.append(fmesg)
                                    bldmsgbytype[fmesg.num] = prev
                                }else{
                                    bldmsgbytype[fmesg.num] = [ fmesg ]
                                }
                            }
                        }
                    default:
                        break
                    }
                } while convert_return == FIT_CONVERT_MESSAGE_AVAILABLE
            } )
        }
        messages = bldmsg
        messageTypes = bldmsgnum
        messagesByType = bldmsgbytype
    }

    convenience init?( file :URL){
        if let data = try? Data(contentsOf: file) {
            self.init(data: data)
        }else{
            return nil
        }
    }
 
    func countByMessageType() -> [RZFitMessageType:UInt] {
        var rv : [RZFitMessageType:UInt] = [:]
        
        for one in messages {
            if let prev = rv[one.num] {
                rv[one.num] = prev + 1
            }else{
                rv[one.num] = 1
            }
        }
        return rv
    }
    
    func messages(forMessageType:RZFitMessageType) -> [RZFitMessage] {
        var rv : [RZFitMessage] = []
        for one in messages {
            if one.num == forMessageType {
                rv.append(one)
            }
        }
        return rv
    }
    
    func allMessageTypes() -> [String] {
        var rv : [String] = []
        for one in messageTypes {
            if let oneStr = rzfit_mesg_num_string(input: one) {
                rv.append(oneStr)
            }
        }
        return rv
    }
    
}
