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
    typealias Sample = (count:Int,one:RZFitFieldValue)
    
    public private(set) var messages : [RZFitMessage]
    public private(set) var messageTypes : [RZFitMessageType]
    public private(set) var messagesByType : [RZFitMessageType:[RZFitMessage]]
    public private(set) var devDataParser : RZFitDevDataParser?
    
    init(  messages input: [RZFitMessage] ){
        var bldmsgnum : Set<RZFitMessageType> = []
        var bldmsgnumorder :[RZFitMessageType] = []
        var bldmsgbytype : [RZFitMessageType:[RZFitMessage]] = [:]
        for one in input {
            if !bldmsgnum.contains(one.messageType){
                bldmsgnum.insert(one.messageType)
                bldmsgnumorder.append(one.messageType)
            }
            if var prev = bldmsgbytype[one.messageType] {
                prev.append(one)
                bldmsgbytype[one.messageType] = prev
            }else{
                bldmsgbytype[one.messageType] = [ one ]
            }
        }
        messages = input
        messageTypes = bldmsgnumorder
        messagesByType = bldmsgbytype
        devDataParser = nil
    }
    
    init( data : Data){
        var state : FIT_CONVERT_STATE = FIT_CONVERT_STATE()
        var convert_return : FIT_CONVERT_RETURN = FIT_CONVERT_CONTINUE
        
        let dev_parser = RZFitDevDataParser(&state, knownUnits: rzfit_known_units())
        
        FitConvert_Init(&state, FIT_TRUE)
        dev_parser.initState(&state)
        
        var bldmsg : [RZFitMessage] = []
        var bldmsgnum : Set<RZFitMessageType> = []
        var bldmsgbytype : [RZFitMessageType:[RZFitMessage]] = [:]
        var bldmsgnumorder : [RZFitMessageType] = []
        
        while convert_return == FIT_CONVERT_CONTINUE {
            data.withUnsafeBytes({ (ptr: UnsafePointer<UInt8>) in
                repeat {
                    convert_return = FitConvert_Read(&state, ptr, FIT_UINT32(data.count))
                    
                    switch convert_return {
                    case FIT_CONVERT_MESSAGE_AVAILABLE:
                        let mesg = FitConvert_GetMessageNumber(&state)
                        if !bldmsgnum.contains(mesg){
                            bldmsgnum.insert(mesg)
                            bldmsgnumorder.append(mesg)
                        }
                        if let uptr : UnsafePointer<UInt8> = FitConvert_GetMessageData(&state) {
                            if( mesg == FIT_MESG_NUM_FIELD_DESCRIPTION){
                                dev_parser.recordDeveloperField(uptr)
                            }
                            if let fmesg = rzfit_build_mesg(num: mesg, uptr: uptr)
                            {
                                if let dev = dev_parser.parseData() as? [RZFitFieldKey:Double],
                                    let devunits = dev_parser.units(),
                                    let devnative = dev_parser.nativeFields() as? [RZFitFieldKey:Int]{
                                    
                                    fmesg.addDevFieldValues(fields: dev, units: devunits, native: devnative)
                                }
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
        messageTypes = bldmsgnumorder
        messagesByType = bldmsgbytype
        devDataParser = dev_parser
    }

    convenience init?( file :URL){
        if let data = try? Data(contentsOf: file) {
            self.init(data: data)
        }else{
            return nil
        }
    }
 
    func countByMessageType() -> [RZFitMessageType:Int] {
        var rv : [RZFitMessageType:Int] = [:]
        
        for (key,val) in messagesByType {
            rv[key] = val.count
        }
        return rv
    }
    
    func messages(forMessageType:RZFitMessageType) -> [RZFitMessage] {
        if let found = self.messagesByType[forMessageType] {
            return found
        }
        
        return []
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
    
    func fieldKeys( messageType: RZFitMessageType ) -> [RZFitFieldKey] {
        return Array(self.sampleValues(messageType: messageType).keys)
    }
    
    func sampleValues( messageType: RZFitMessageType) -> [RZFitFieldKey:Sample] {
        var rv : [RZFitFieldKey:Sample] = [:]
        let forMessages = self.messages(forMessageType: messageType)
        for one in forMessages {
            for (key,val) in one.interpretedFields() {
                
                if rv[key] == nil {
                    rv[key] = (count:1,one:val)
                }else{
                    rv[key]?.count += 1
                }
            }
        }
        return rv
    }

    
}
