//
//  FITSelectionContext.swift
//  GarminConnect
//
//  Created by Brice Rosenzweig on 28/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

import Foundation

class FITSelectionContext {
    
    
    static let kFITNotificationConfigurationChanged = Notification.Name( "kFITNotificationConfigurationChanged" )
    static let kFITNotificationMessageChanged       = Notification.Name( "kFITNotificationMessageChanged" )
    static let kFITNotificationFieldChanged         = Notification.Name( "kFITNotificationFieldChanged" )

    // MARK: - Stored Properties
    
    /// Selected numbers fields in order, lastObject is latest
    fileprivate var selectedNumberFields : [String] = []
    /// Selected location fields in order, lastObject is latest
    fileprivate var selectedLocationFields : [String] = []
    
    let fitFile : FITFitFile
    
    var speedUnit : GCUnit = GCUnit.kph()
    var distanceUnit : GCUnit = GCUnit.meter()
    
    var enableY2 : Bool = false
    var prettyField : Bool = false;
    
    var queue : [FITSelectionContext] = []

    var selectedMessage: String {
        didSet{
            // If new message does not exist, do nothing
            // else update with some defaults
            if fitFile[selectedMessage] == nil {
                self.selectedMessage = oldValue;
            }else{
                if(selectedMessage != oldValue){
                    self.updateWithDefaultForCurrentMessage()
                }
            }
        }
    }
    lazy var interp : FITFitFileInterpret = FITFitFileInterpret(fitFile: self.fitFile)

    /// Last few selected Fields
    var selectedMessageIndex : UInt = 0 {
        didSet {
            if selectedMessageIndex >= self.message.count() {
                selectedMessageIndex = 0;
            }
        }
    }
    var selectedXField : String = "timestamp"

    var preferredDependendMessage : [String] = ["record", "lap", "session"]
    var dependentMessage : String?
    
    var statsFor : String? {
        get {
            return dependentMessage
        }
        set {
            dependentMessage = newValue
        }
    }
    
    //MARK: - Computed Properties
    
    var selectedMessageFields :FITFitMessageFields? {
        let message = self.message
        
        let useIdx = self.selectedMessageIndex < message.count() ? self.selectedMessageIndex : 0
        var rv : FITFitMessageFields?
        
        if useIdx < message.count() {
            rv = message[useIdx]
        }
        return rv
    }

    
    
    var selectedYField :String? {
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
            }
        }
    }

    var selectedY2Field :String? {
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
            }
        }
    }
    
    var selectedLocationField :String?{
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

    var message :FITFitMessage {
        return self.fitFile[selectedMessage]
    }
    
    var dependentField :String? {
        var rv : String?
        if let dmessagetype = self.dependentMessage,
            let dmessage = self.fitFile[dmessagetype]{
            if dmessage.containsNumberKey(self.selectedYField){
                rv = self.selectedYField
            }else if let fy = self.selectedYField,
                let f = self.interp.mapFields(from: [fy], to: dmessage.allNumberKeys())[fy]{
                if f.count > 0 {
                    rv = f[0]
                }
            }
        }
        return rv
    }

    
    // MARK: Initialization and Queue management
    

    init(fitFile:FITFitFile){
        self.fitFile = fitFile;
        self.selectedMessage = self.fitFile.defaultMessageType()
        updateDependent()
    }
    
    init(withCopy other:FITSelectionContext){
        self.fitFile = other.fitFile
        self.selectedMessage = other.selectedMessage
        self.enableY2 = other.enableY2
        self.distanceUnit = other.distanceUnit
        self.speedUnit = other.speedUnit
        self.prettyField = other.prettyField
        self.selectedXField = other.selectedXField
        self.selectedLocationFields = other.selectedLocationFields
        self.selectedNumberFields = other.selectedNumberFields
        //self.dependentField = other.dependentField
        self.dependentMessage = other.dependentMessage
        self.preferredDependendMessage = other.preferredDependendMessage
        
    }
    
    func push(){
        if queue.count == 0 || queue.last != self{
            let saved = FITSelectionContext(withCopy:self)
            queue.append(saved)
        }
    }
    
    // MARK: - change selection
    
    func notify(){
        NotificationCenter.default.post(name: FITSelectionContext.kFITNotificationConfigurationChanged, object: nil)
    }

    /// Update selection for index and record if number or location field selected
    func selectMessageField(field:String, atIndex idx: UInt){
        let message = self.message
        
        let useIdx = idx < message.count() ? idx : 0
        
        if useIdx < message.count() {
            self.selectedMessageIndex = useIdx
            if let fields = self.selectedMessageFields,
                let value = fields[field]{
                if( value.numberWithUnit != nil){
                    selectedNumberFields.append(field)
                }else if( value.locationValue != nil){
                    selectedLocationFields.append(field)
                }
            }
        }
    }
    
    private func updateDependent(){
        for one in self.preferredDependendMessage {
            if one != self.selectedMessage && self.fitFile.containsMessageType(one){
                self.dependentMessage = one
                break
            }
        }
    }
    
    /// Setup fields if new message selected
    private func updateWithDefaultForCurrentMessage(){
        selectedMessageIndex = 0
        selectedNumberFields = []
        if let first = self.message.allNumberKeys().first{
            selectedNumberFields.append(first)
        }
        selectedLocationFields = []
        if let first = self.message.allLocationKeys().first{
            selectedLocationFields.append(first)
        }
        if( selectedXField == "timestamp" && self.message.containsDateKey("start_time") ){
            selectedXField = "start_time"
        }else if( !self.message.containsFieldKey(selectedXField)){
            selectedXField = "timestamp"
        }
        self.updateDependent()
    }
    
    // MARK: - Display
    
    /// Convert to relevant unit or just description
    ///
    /// - Parameter fieldValue: value to display
    /// - Returns: string
    func display( fieldValue : FITFitFieldValue) -> String {
        if let nu = fieldValue.numberWithUnit {
            for unit in [self.speedUnit, self.distanceUnit] {
                if nu.unit.canConvert(to: unit) {
                    return nu.convert(to: unit).description
                }
            }
        }
        return fieldValue.displayString()
    }
    
    func display( numberWithUnit nu: GCNumberWithUnit) -> String{
        for unit in [self.speedUnit, self.distanceUnit] {
            if nu.unit.canConvert(to: unit) {
                return nu.convert(to: unit).description
            }
        }
        return nu.description;
    }
    
    func displayField( fieldName : String ) -> NSAttributedString {
        var displayText = fieldName
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        var attr = [ NSAttributedString.Key.font:NSFont.systemFont(ofSize: 12.0),
                     NSAttributedString.Key.foregroundColor:NSColor.black,
                     NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        if self.prettyField {
            if let field = self.interp.fieldKey(fitField: fieldName){
                displayText = field.displayName()
            }else{
                attr = [NSAttributedString.Key.font:NSFont.systemFont(ofSize: 12.0),
                        NSAttributedString.Key.foregroundColor:NSColor.lightGray,
                        NSAttributedString.Key.paragraphStyle:paragraphStyle]
            }
        }
        return NSAttributedString(attr, with: displayText)
    }
    
    // MARK: - Extract Information about current selection
    
    func availableNumberFields() -> [String] {
        return self.message.allNumberKeys()
    }
    func availableDateFields() -> [String] {
        return self.message.allDateKeys()
    }

}

extension FITSelectionContext: Equatable {
    static func ==(lhs: FITSelectionContext, rhs: FITSelectionContext) -> Bool {
        return lhs.selectedNumberFields == rhs.selectedNumberFields && lhs.selectedLocationFields == rhs.selectedLocationFields
    }
}
