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
    /// Notification sent whenever the a change occurs: messageType, field selection, message selection or configuration
    static let kFITNotificationMessageTypeChanged = Notification.Name( "kFITNotificationMessageTypeChanged" )
    static let kFITNotificationFieldSelectionChanged = Notification.Name( "kFITNotificationFieldSelectionChanged" )
    static let kFITNotificationMessageSelectionChanged = Notification.Name( "kFITNotificationMessageSelectionChanged" )
    static let kFITNotificationDisplayConfigChanged = Notification.Name( "kFITNotificationDisplayConfigChanged" )
    
    // MARK: - FitFile
    
    let fitFile : FitFile
    lazy var interp : FITFitFileInterpret = FITFitFileInterpret(fitFile: self.fitFile)
    
    // MARK: - Configuration
    
    /// controls if secondary graph should be displayed or not
    var enableY2 : Bool = false {
        didSet {
            NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationDisplayConfigChanged, object: self)
        }
    }
    
    /// Controls if the displayed field are mapped to a language or raw fit names
    var prettyField : Bool = false;
    
    /// A flag to indicate if we want the messages in rows or columns
    var messageInColumns : Bool = false

    // MARK: - Message Selection
    
    /// Currently selected messagetype
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

    var messageTypeDescription : String {
        return self.messageType.name()
    }

    /// Keys in reasonable order for all the fields in the current messageType
    /// Order will be date field, coord field, enum field and number fields
    var orderedKeys : [FitFieldKey]
    
    var messages : [FitMessage]

    /// Current selected Message or nil if no selected
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
    
    /// Last selected message Index
    var messageIndex : Int = 0 {
        didSet {
            if messageIndex >= self.messages.count || messageIndex < 0 {
                messageIndex = 0;
            }
        }
    }
    
    /// a sample of the field if a valid number with unit or nil
    /// sample will be taken from sampleMessage, either first or currenlty selected one
    func sampleNumberWithUnit(field : FitFieldKey) -> GCNumberWithUnit? {
        if let sample = self.sampleMessage {
            return sample.interpretedField(key: field)?.numberWithUnit
        }
        return nil
    }
    
    /// a sample of the field if a valid date or nil
    /// sample will be taken from sampleMessage, either first or currenlty selected one
    func sampleTime(field : FitFieldKey) -> Date? {
        if let sample = self.sampleMessage {
            return sample.interpretedField(key: field)?.time
        }
        return nil
    }

    // MARK: - Dependent/Stats messages
    
    private let preferredDependendMessageType : [FitMessageType] = [.record,.lap,.session]
    var statsUsing : FitMessageType?
    var statsFor : FitMessageType?
    

    //MARK: - Field Selections

    /// Last selected Field
    var selectedField : FitFieldKey? = nil

    /// Selected numbers fields in order, lastObject is latest
    fileprivate var selectedNumberFields : [FitFieldKey] = []
    /// Selected location fields in order, lastObject is latest
    fileprivate var selectedLocationFields : [FitFieldKey] = []

    /// field to use for x in graphs
    var selectedXField : FitFieldKey = "timestamp" {
        didSet {
            NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationFieldSelectionChanged, object: self)
        }
    }

    /// Last number selected field, can be used for graphs
    var selectedYField : FitFieldKey? {
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

    /// one before last selected field, can be used as secondary graphs
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
    
    /// last selected location field, used for mapping
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
    
    /// Will setup a default selection Context for a fitfile
    /// It will try to select a relevant messageType (record, or file_id) and setup
    /// decent default for most fields
    /// - Parameter fitFile: fit file to base the selection on
    init(fitFile:FitFile){
        self.fitFile = fitFile;
        self.messageType = self.fitFile.preferredMessageType()
        self.messages = self.fitFile.messages(forMessageType: self.messageType)
        self.orderedKeys = self.fitFile.orderedFieldKeys(messageType: self.messageType)
        self.statsFor = .session // default
        updateWithDefaultForCurrentMessageType()
        if let file_id = fitFile.messages(forMessageType: .file_id).first,
           let started = file_id.time(field: "time_created") {
            self.dateStarted = started
        }
    }
            
    // MARK: - Change Field and Message selection

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
    
    // MARK: - Date and Unit Format
    
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
    

    var dateTimeFormat : DateTimeFormat = .full
    private var dateStarted : Date? = nil
    
    
    private var unitOverrides : [FitFieldKey: GCUnit] = [:]
    
    func clearDisplayUnitOverrides() {
        self.unitOverrides = [:]
    }
    
    /// Return units available for a given field in the current message
    /// - Parameter field: field to check
    /// - Returns: list of units that are valid for this field or empty if unit irrelevent (string, coordinate, etc)
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

    // MARK: - Display Fields

    /// Display value as configured and in the required unit
    /// - Parameter fieldValue: value to display
    /// - Parameter field: field the value is for, unit can be overriden at the field level which impacts how it's displayed
    /// - Returns: string
    func display( fieldValue: FitFieldValue, field: FitFieldKey?) -> String {
        switch ( fieldValue.fitValue ){
        case .time(let date):
            switch self.dateTimeFormat {
            case .full:
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .medium
                return dateFormatter.string(from: date)
            case .timeOnly:
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .medium
                return dateFormatter.string(from: date)
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
    
    /// Display number with unit with the right unit based on the configuration for field
    /// - Parameters:
    ///   - nu: number to display
    ///   - field: optional field corresponding to the number to check for unit override
    /// - Returns: string to display
    func display( numberWithUnit nu: GCNumberWithUnit, field: FitFieldKey?) -> String{
        if let field = field,
           let displayUnit : GCUnit = self.displayUnit(field: field) {
            return nu.convert(to: displayUnit).description
        }
        return nu.description
    }
    
    /// Unit to use for a field based on current configuration and overrides
    func displayUnit(field: FitFieldKey) -> GCUnit? {
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

    func display(field:FitFieldKey, messageType: FitMessageType) -> String {
        var displayText = field
        
        if self.prettyField {
            if let field = self.interp.fieldKey(fitMessageType: messageType, fitField: field){
                displayText = field.displayName()
            }
        }
        return displayText
    }
    
    /// Display field name for message Type
    /// if pretty field enabled will display the display name or else the raw name in disabled color
    func displayAttributed( field : FitFieldKey, messageType: FitMessageType ) -> NSAttributedString {
        let displayText = self.display(field: field, messageType: messageType)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        
        let disabledLabelColor = NSColor.disabledControlTextColor
        let highlightLabelColor = NSColor.textColor
        
        var attr = [ NSAttributedString.Key.font:NSFont.systemFont(ofSize: 12.0),
                     NSAttributedString.Key.foregroundColor:highlightLabelColor,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        // Pretty field, but text didn't change
        if self.prettyField && field == displayText {
            attr = [NSAttributedString.Key.font:NSFont.systemFont(ofSize: 12.0),
                    NSAttributedString.Key.foregroundColor:disabledLabelColor,
                    NSAttributedString.Key.paragraphStyle:paragraphStyle]
        }
        return NSAttributedString(attr, with: displayText)
    }
    
    // MARK: - Extract Information about current selection
    
    /// Available numbers for current messageType or other messagetype in the file
    func availableNumberFields() -> [FitFieldKey] {
        if let message = self.message {
            return message.fieldKeysWithNumberWithUnit()
        }
        return []
    }
    
    func availableDateFields() -> [FitFieldKey] {
        if let message = self.message {
            return message.fieldKeysWithTime()
        }
        return []
    }
}
