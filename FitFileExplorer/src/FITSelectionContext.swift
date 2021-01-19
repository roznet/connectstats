//
//  FITSelectionContext.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 28/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation
import FitFileParser


class FITSelectionContext {
    static let kFITNotificationMessageTypeChanged = Notification.Name( "kFITNotificationMessageTypeChanged" )
    static let kFITNotificationFieldSelectionChanged = Notification.Name( "kFITNotificationFieldSelectionChanged" )
    static let kFITNotificationMessageSelectionChanged = Notification.Name( "kFITNotificationMessageSelectionChanged" )
    static let kFITNotificationDisplayConfigChanged = Notification.Name( "kFITNotificationDisplayConfigChanged" )
    
    // MARK: - FitFile
    
    let fitFile : FitFile
    lazy var interp : FITFitFileInterpret = FITFitFileInterpret(fitFile: self.fitFile)
    
    // MARK: - Configuration
    var enableY2 : Bool = false
    var prettyField : Bool = false;
    
    enum DateTimeFormat {
        case full, timeOnly, elapsed
        
        static let descriptions = [ "Date and Time", "Time Only", "Elapsed" ]
        
        var description : String {
            switch self {
            case .full:
                return DateTimeFormat.descriptions[0]
            case .timeOnly:
                return DateTimeFormat.descriptions[1]
            case .elapsed:
                return DateTimeFormat.descriptions[2]
            }
        }
        
        init(description : String){
            if description == DateTimeFormat.descriptions[2] {
                self = .elapsed
            }else if description == DateTimeFormat.descriptions[1] {
                self = .timeOnly
            }else {
                self = .full
            }
        }
    }
    
    // MARK: - Message Selection
    
    var messageTypeDescription : String {
        if let type = self.fitFile.messageTypeDescription(messageType: self.messageType) {
            return type
        }else{
            return "Unknown Message Type"
        }
    }
    var messageType: FitMessageType {
        didSet{
            // If new message does not exist, do nothing
            // else update with some defaults
            if !fitFile.hasMessageType(messageType: messageType) {
                self.messageType = oldValue;
            }else{
                
                if(messageType != oldValue){
                    self.messages = self.fitFile.messages(forMessageType: self.messageType)
                    self.orderedKeys = self.fitFile.orderedFieldKeys(messageType: self.messageType)
                    self.updateWithDefaultForCurrentMessageType()
                    NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationMessageTypeChanged, object: self)
                }
            }
        }
    }
    
    var orderedKeys : [FitFieldKey]
    
    var messages : [FitMessage]

    /// Current selected Message
    var message : FitMessage? {
        let useIdx = self.messageIndex < self.messages.count ? self.messageIndex : 0
        return self.messages[safe: useIdx]
    }
    
    /// Current selected Message and first one as sample
    var sampleMessage : FitMessage? {
        if let message = self.message {
            return message
        }else{
            if let message = self.messages.first {
                return message
            }
        }
        return nil
    }
    
    /// Last few selected Fields
    var messageIndex : Int = 0 {
        didSet {
            if messageIndex >= self.messages.count || messageIndex < 0 {
                messageIndex = 0;
            }
        }
    }
    
    func sampleNumberWithUnit(field : FitFieldKey) -> GCNumberWithUnit? {
        if let sample = self.sampleMessage {
            return sample.interpretedField(key: field)?.numberWithUnit
        }
        return nil
    }
    
    func sampleTime(field : FitFieldKey) -> Date? {
        if let sample = self.sampleMessage {
            return sample.interpretedField(key: field)?.time
        }
        return nil
    }

    // MARK: - Dependent/Stats messages
    
    var preferredDependendMessageType : [FitMessageType] = [.record,.lap,.session]
    var statsUsing : FitMessageType?
    var statsFor : FitMessageType?
    

    //MARK: - Field Selections

    /// Last selected Field
    var selectedField : FitFieldKey? = nil

    /// Selected numbers fields in order, lastObject is latest
    fileprivate var selectedNumberFields : [FitFieldKey] = []
    /// Selected location fields in order, lastObject is latest
    fileprivate var selectedLocationFields : [FitFieldKey] = []

    var selectedXField : FitFieldKey = "timestamp" {
        didSet {
            NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationFieldSelectionChanged, object: self)
        }
    }

    var selectedYField :FitFieldKey? {
        get {
            return self.selectedNumberFields.last
        }
        set {
            if let val = newValue {
                if self.selectedNumberFields.count > 0 {
                    self.selectedNumberFields[self.selectedNumberFields.count-1] = val
                }else{
                    self.selectedNumberFields.append(val)
                }
                NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationFieldSelectionChanged, object: self)
            }
        }
    }

    var selectedY2Field :FitFieldKey? {
        get {
            let cnt = self.selectedNumberFields.count
            return cnt > 1 ? self.selectedNumberFields[cnt-2] : nil
        }
        set {
            if let val = newValue {
                let cnt = self.selectedNumberFields.count
                if cnt > 1 {
                    self.selectedNumberFields[cnt-2] = val
                }else if( cnt > 0){
                    self.selectedNumberFields.insert(val, at: 0)
                }
                NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationFieldSelectionChanged, object: self)
            }
        }
    }
    
    var selectedLocationField :FitFieldKey?{
        get {
            return self.selectedLocationFields.last
        }
        set {
            if let val = newValue {
                if self.selectedLocationFields.count > 0 {
                    self.selectedLocationFields[self.selectedLocationFields.count-1] = val
                }else{
                    self.selectedLocationFields.append(val)
                }
            }
        }
    }

    
    // MARK: - Initialization

    init(fitFile:FitFile){
        self.fitFile = fitFile;
        self.messageType = self.fitFile.preferredMessageType()
        self.messages = self.fitFile.messages(forMessageType: self.messageType)
        self.statsFor = self.messageType
        self.orderedKeys = self.fitFile.orderedFieldKeys(messageType: self.messageType)
        updateDependent()
        if let file_id = fitFile.messages(forMessageType: .file_id).first,
           let started = file_id.time(field: "time_created") {
            self.dateStarted = started
        }
    }
    
    init(withCopy other:FITSelectionContext){
        self.fitFile = other.fitFile
        self.messageType = other.messageType
        self.enableY2 = other.enableY2
        self.prettyField = other.prettyField
        
        self.selectedField = other.selectedField
        self.selectedXField = other.selectedXField
        self.selectedLocationFields = other.selectedLocationFields
        self.selectedNumberFields = other.selectedNumberFields
        
        self.statsUsing = other.statsUsing
        self.statsFor = other.statsFor
        
        self.preferredDependendMessageType = other.preferredDependendMessageType
        self.messages = other.messages
        self.orderedKeys = other.orderedKeys
        
        self.unitOverrides = other.unitOverrides
        self.dateStarted = other.dateStarted
        self.dateTimeFormat = other.dateTimeFormat
    }
        
    // MARK: - change selection

    /// Update selection for index and record if number or location field selected
    func selectMessageField(field : FitFieldKey, atIndex idx : Int){
        if idx != self.messageIndex && self.messages.indices.contains(idx) {
            self.messageIndex = idx
            NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationMessageSelectionChanged, object: self)
        }
        
        if field != self.selectedField {
            self.selectedField = field
            if let message = self.message{
                if message.numberWithUnit(field: field) != nil{
                    selectedNumberFields.append(field)
                }else if( message.coordinate(field: field) != nil){
                    selectedLocationFields.append(field)
                }
            }
            NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationFieldSelectionChanged, object: self)
        }
    }
    
    private func updateDependent(){
        for one in self.preferredDependendMessageType {
            if one != self.statsFor && self.fitFile.messages(forMessageType: one).count != 0{
                self.statsUsing = one
                break
            }
        }
    }
    
    /// Setup fields if new message selected
    private func updateWithDefaultForCurrentMessageType(){
        if self.messageType == FitMessageType.lap || self.messageType == FitMessageType.session {
            self.statsFor = self.messageType
        }
        
        messageIndex = 0
        selectedNumberFields = []
        if let first = self.message?.fieldKeysWithNumberWithUnit().first{
            selectedNumberFields.append(first)
            if let selectedField = self.selectedField,
               self.sampleMessage?.interpretedField(key: selectedField) == nil{
                self.selectedField = first
            }
        }
        selectedLocationFields = []
        if let first = self.message?.fieldKeysWithCoordinate().first{
            selectedLocationFields.append(first)
        }
        if( selectedXField == "timestamp" && self.message?.time(field: "start_time") != nil){
            selectedXField = "start_time"
        }else if( self.message?.time(field: selectedXField) == nil){
            selectedXField = "timestamp"
        }
        
        self.updateDependent()
    }
    
    // MARK: - Unit Selection
    
    var dateTimeFormat : DateTimeFormat = .full
    var dateStarted : Date? = nil
    var unitOverrides : [FitFieldKey: GCUnit] = [:]
    
    func clearDisplayUnitOverrides() {
        self.unitOverrides = [:]
    }
    
    func displayUnitForField(field : FitFieldKey) -> GCUnit? {
        if let nu = self.sampleNumberWithUnit(field: field) {
            if let override = self.unitOverrides[field],
               nu.unit.canConvert(to: override){
                return override
            }else{
                if GCUnit.getGlobalSystem() != .default {
                    // for speed use better than mps
                    if nu.unit.canConvert(to: GCUnit.mps() ) {
                        return GCUnit.kph().forGlobalSystem()
                    }else{
                        return nu.unit.forGlobalSystem()
                    }
                }
            }
        }
        return nil
    }

    func availableDisplayUnitsForField(field : FitFieldKey ) -> [GCUnit] {
        if let nu = self.sampleNumberWithUnit(field: field) {
            return nu.unit.compatibleUnits()
        }
        return []
    }

    func setDisplayUnitOverride(field : FitFieldKey, unit : GCUnit){
        if let nu = self.sampleNumberWithUnit(field: field) {
            if nu.unit.canConvert(to: unit) {
                self.unitOverrides[field] = unit
                NotificationCenter.default.post(Notification.init(name: FITSelectionContext.kFITNotificationDisplayConfigChanged, object: self))
            }
        }
    }

    // MARK: - Display

    /// Convert to relevant unit or just description
    ///
    /// - Parameter fieldValue: value to display
    /// - Returns: string
    func display( fieldValue: FitFieldValue, field: FitFieldKey?) -> String {
        switch ( fieldValue.fitValue ){
        case .time(let date):
            switch self.dateTimeFormat {
            case .full:
                return (date as NSDate).datetimeFormat()
            case .timeOnly:
                return (date as NSDate).timeShortFormat()
            case .elapsed:
                if let started = self.dateStarted {
                    let elapsed = GCNumberWithUnit(name: "second", andValue: date.timeIntervalSince(started))
                    return elapsed.description
                }else{
                    return (date as NSDate).timeShortFormat()
                }
            }
        case .valueUnit:
            if let nu = fieldValue.numberWithUnit {
                return self.display(numberWithUnit: nu, field: field)
            }
        default:
            return fieldValue.displayString()
        }
        return fieldValue.displayString()
    }
    
    func display( numberWithUnit nu: GCNumberWithUnit, field : FitFieldKey?) -> String{
        if let field = field,
           let displayUnit : GCUnit = self.displayUnitForField(field: field) {
            return nu.convert(to: displayUnit).description
        }
        return nu.description
    }
    
    func displayField( fitMessageType: FitMessageType, fieldName : String ) -> NSAttributedString {
        var displayText = fieldName
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        
        let disabledLabelColor = NSColor(named: "DisabledLabel") ?? NSColor.lightGray
        let highlightLabelColor = NSColor(named: "HighlightedLabel") ?? NSColor.black
        
        var attr = [ NSAttributedString.Key.font:NSFont.systemFont(ofSize: 12.0),
                     NSAttributedString.Key.foregroundColor:highlightLabelColor,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        if self.prettyField {
            if let field = self.interp.fieldKey(fitMessageType: fitMessageType, fitField: fieldName){
                displayText = field.displayName()
            }else{
                
                attr = [NSAttributedString.Key.font:NSFont.systemFont(ofSize: 12.0),
                        NSAttributedString.Key.foregroundColor:disabledLabelColor,
                        NSAttributedString.Key.paragraphStyle:paragraphStyle]
            }
        }
        return NSAttributedString(attr, with: displayText)
    }
    
    // MARK: - Extract Information about current selection
    
    func availableNumberFields() -> [String] {
        if let message = self.message {
            return message.fieldKeysWithNumberWithUnit()
        }
        return []
    }
    func availableDateFields() -> [String] {
        if let message = self.message {
            return message.fieldKeysWithTime()
        }
        return []
    }

}

extension FITSelectionContext: Equatable {
    static func ==(lhs: FITSelectionContext, rhs: FITSelectionContext) -> Bool {
        return lhs.selectedNumberFields == rhs.selectedNumberFields && lhs.selectedLocationFields == rhs.selectedLocationFields
    }
}
