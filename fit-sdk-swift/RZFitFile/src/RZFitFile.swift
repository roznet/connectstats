//
//  fit_file.swift
//  fittestswift
//
//  Created by Brice Rosenzweig on 16/12/2018.
//  Copyright © 2018 Brice Rosenzweig. All rights reserved.
//

import Foundation

typealias RZFitMessageType = FIT_MESG_NUM
typealias RZFitFieldKey = String

class RZFitFile {
    
    public private(set) var messages : [RZFitMessage]
    public private(set) var messageTypes : Set<RZFitMessageType>
    public private(set) var messagesByType : [RZFitMessageType:[RZFitMessage]]
    
    init(  messages input: [RZFitMessage] ){
        var bldmsgnum : Set<RZFitMessageType> = []
        var bldmsgbytype : [RZFitMessageType:[RZFitMessage]] = [:]
        for one in input {
            bldmsgnum.insert(one.messageType)
            if var prev = bldmsgbytype[one.messageType] {
                prev.append(one)
                bldmsgbytype[one.messageType] = prev
            }else{
                bldmsgbytype[one.messageType] = [ one ]
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
                                if var prev = bldmsgbytype[fmesg.messageType] {
                                    prev.append(fmesg)
                                    bldmsgbytype[fmesg.messageType] = prev
                                }else{
                                    bldmsgbytype[fmesg.messageType] = [ fmesg ]
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
            if let prev = rv[one.messageType] {
                rv[one.messageType] = prev + 1
            }else{
                rv[one.messageType] = 1
            }
        }
        return rv
    }
    
    func messages(forMessageType:RZFitMessageType) -> [RZFitMessage] {
        var rv : [RZFitMessage] = []
        for one in messages {
            if one.messageType == forMessageType {
                rv.append(one)
            }
        }
        return rv
    }
    
    func messageTypeDescription( messageType:RZFitMessageType) -> String? {
        return rzfit_mesg_num_string(input: messageType)
    }
    
    func messageTypesDescriptions() -> [String] {
        var rv : [String] = []
        for one in messageTypes {
            if let oneStr = rzfit_mesg_num_string(input: one) {
                rv.append(oneStr)
            }
        }
        return rv
    }
    
    static func messageType( forDescription : String) -> RZFitMessageType? {
        return rzfit_string_to_mesg(mesg: forDescription)
    }
    
    func hasMessageType( messageType:RZFitMessageType) -> Bool{
        if let _ = self.messagesByType[messageType] {
            return true
        }else{
            return false
        }
    }
    
}
