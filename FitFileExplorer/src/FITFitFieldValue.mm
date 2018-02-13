//
//  FITFitFieldValue.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 21/05/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#define FIT_USE_STDINT_H

#import "FITFitFieldValue.h"
#import "RZUtils/RZUtils.h"
#import <RZExternalCpp/RZExternalCpp.h>
#import "GCUnit+FIT.h"
#import "FITFitEnumMap.h"
#define SEMICIRCLE_TO_DEGREE(x) (double)x*(180./2147483648.)

@interface FITFitFieldValue ()

@property (nonatomic,assign) fit::Field * originalField;
@property (nonatomic,assign) fit::Field * complementField;
@property (nonatomic,assign) fit::DeveloperField * developerField;

@end

@implementation FITFitFieldValue

+(nullable FITFitFieldValue*)fieldValueFrom:(const fit::Field&)ff{
    FITFitFieldValue * rv = RZReturnAutorelease([[FITFitFieldValue alloc] init]);
    if( rv){
        rv.originalField = nil;
        rv.complementField = nil;
        rv.developerField = nil;
        [rv setFromField:ff];
    }
    return rv;
}

+(nullable FITFitFieldValue*)fieldValueFromDeveloper:(const fit::DeveloperField&)ff{
    FITFitFieldValue * rv = RZReturnAutorelease([[FITFitFieldValue alloc] init]);
    if( rv){
        rv.originalField = nil;
        rv.complementField = nil;
        rv.developerField = nil;
        [rv setFromDeveloperField:ff];
    }
    return rv;

}
-(void)dealloc{
    if( _originalField){
        delete _originalField;
    }
    if( _complementField){
        delete _complementField;
    }
    if( _developerField){
        delete _developerField;
    }
#if !__has_feature(objc_arc)
    [_stringValue release];
    [_dateValue release];
    [_numberWithUnit release];
    [_enumValue release];
    [_locationValue release];
    [_fieldKey release];
    [super dealloc];
#endif
}

#pragma mark - Setup 

-(void)setFromField:(const fit::Field &)field{
    if( _originalField ){
        delete _originalField;
    }
    if( _developerField ){
        delete _developerField;
    }
    _originalField = new fit::Field(field);
    _developerField = nil;
    [self setFromFieldBase:field];
}

-(void)setFromDeveloperField:(const fit::DeveloperField &)field{
    if( _developerField ){
        delete _developerField;
    }
    if( _originalField){
        delete _originalField;
    }
    _developerField = new fit::DeveloperField(field);
    _originalField = nil;
    
    
    
    [self setFromFieldBase:field];
}

-(NSString*)fieldSource{
    NSString * rv = @"";
    if( _developerField ){
        if( _developerField->GetDefinition().GetDeveloper().IsManufacturerIdValid()){
            FIT_MANUFACTURER fact = _developerField->GetDefinition().GetDeveloper().GetManufacturerId();
            rv =  [FITFitEnumMap defsFor:@"FIT_MANUFACTURER" andKey:@(fact)];
        }else{
            FIT_UINT8 n = _developerField->GetDefinition().GetDeveloper().GetNumDeveloperId();
            if( n > 0){
                NSMutableString * devid = [NSMutableString string];
                for (FIT_UINT8 i=0; i<n; i++) {
                    [devid appendFormat:@"%@", @(_developerField->GetDefinition().GetDeveloper().GetDeveloperId(i))];
                }
                rv = devid;
            }
        }
    }
    return rv;
}

-(NSString*)derivedFieldKey:(const fit::FieldBase&)field{
    NSString * base = [NSString stringWithUTF8String:field.GetName().c_str()];
    if( _developerField ){
        NSString * prefix = @"developer";
        if( _developerField->GetDefinition().GetDeveloper().IsManufacturerIdValid()){
            FIT_MANUFACTURER fact = _developerField->GetDefinition().GetDeveloper().GetManufacturerId();
            prefix =  [FITFitEnumMap defsFor:@"FIT_MANUFACTURER" andKey:@(fact)] ?: prefix;
        }
        base = [prefix stringByAppendingFormat:@"_%@", base];

    }
    return base;
}

-(void)setFromFieldBase:(const fit::FieldBase &)field{
    
    int j = 0;
    self.fieldKey = [self derivedFieldKey:field];
    
    NSNumber * numberValue = nil;
    
    switch (field.GetType())
    {
        case FIT_BASE_TYPE_ENUM:
            numberValue = @( field.GetENUMValue(j) );
            break;
        case FIT_BASE_TYPE_SINT8:
            numberValue = @( field.GetSINT8Value(j) );
            break;
        case FIT_BASE_TYPE_UINT8:
            numberValue = @( field.GetUINT8Value(j) );
            break;
        case FIT_BASE_TYPE_SINT16:
            numberValue = @( field.GetSINT16Value(j) );
            break;
        case FIT_BASE_TYPE_UINT16:
            numberValue = @( field.GetUINT16Value(j) );
            break;
        case FIT_BASE_TYPE_SINT32:
            numberValue = @( field.GetSINT32Value(j) );
            break;
        case FIT_BASE_TYPE_UINT32:
            numberValue = @( field.GetUINT32Value(j) );
            break;
        case FIT_BASE_TYPE_FLOAT32:
            numberValue = @( field.GetFLOAT32Value(j) );
            break;
        case FIT_BASE_TYPE_FLOAT64:
            numberValue = @( field.GetFLOAT64Value(j) );
            break;
        case FIT_BASE_TYPE_UINT8Z:
            numberValue = @( field.GetUINT8ZValue(j) );
            break;
        case FIT_BASE_TYPE_UINT16Z:
            numberValue = @( field.GetUINT16ZValue(j) );
            break;
        case FIT_BASE_TYPE_UINT32Z:
            numberValue = @( field.GetUINT32ZValue(j) );
            break;
        case FIT_BASE_TYPE_STRING:
        {
            std::wstring val( field.GetSTRINGValue() );
            self.stringValue = RZReturnAutorelease([[NSString alloc] initWithBytes:val.data() length:val.size() * sizeof(wchar_t) encoding:NSUTF32LittleEndianStringEncoding]);
            break;
        }
        default:
            break;
    }
    
    
    double scale = field.GetScale();
    double offset = field.GetOffset();
    
    if ( ( scale != 1. || offset != 0. ) && numberValue) {
        NSNumber * n = numberValue;
        numberValue = @( n.doubleValue / scale - offset );
    }
    
    
    NSString * unitStr = [NSString stringWithUTF8String:field.GetUnits().c_str()];
    GCUnit * unit = [GCUnit unitForFitUnit:unitStr];
    
    if( [self.fieldKey isEqualToString:@"total_training_effect"]){
        unit = [GCUnit unitForKey:@"te"];
    }
    if( unit ){
        self.numberWithUnit = [GCNumberWithUnit numberWithUnit:unit andValue:numberValue.doubleValue];
    }else if( unitStr.length ){
        static NSMutableDictionary * missing = nil;
        if (missing == nil) {
            missing = [NSMutableDictionary dictionary];
        }
        
        if (!missing[unitStr]) {
            RZLog(RZLogWarning, @"Missing %@ for %@", unitStr, self.fieldKey);
        }
        missing[unitStr] = @1;
        self.numberWithUnit = [GCNumberWithUnit numberWithUnitName:@"dimensionless" andValue:numberValue.doubleValue];
    }else if( numberValue){
        NSString * key = [NSString stringWithFormat:@"FIT_%@", [self.fieldKey uppercaseString]];
        NSString * found = [FITFitEnumMap defsFor:key andKey:numberValue];
        if (found && [found isKindOfClass:[NSString class]]) {
            self.enumValue = found;
        }
    }
    
    if( ([_fieldKey isEqualToString:@"timestamp"] || [_fieldKey isEqualToString:@"local_timestamp"] || [_fieldKey isEqualToString:@"start_time"] ) && numberValue){
        self.dateValue = [NSDate dateForFitTimestamp:numberValue.integerValue];
        self.numberWithUnit = nil;
    }
}

-(nullable FITFitFieldValue*)locationFieldForComplement:(FITFitFieldValue*)other{
    FITFitFieldValue * rv = nil;
    if( [self.fieldKey hasSuffix:@"_lat"]){
        NSString * prefix = [self.fieldKey substringToIndex:(self.fieldKey.length-4)];
        if( [other.fieldKey isEqualToString:[prefix stringByAppendingString:@"_long"]] ){
            rv = RZReturnAutorelease([[FITFitFieldValue alloc] init]);
            rv.originalField = self.originalField;
            rv.complementField = other.complementField;

            self.originalField = nil;
            other.originalField = nil;
            // take ownership of other field
            
            double latSemi  = self.numberWithUnit.value;
            double longSemi = other.numberWithUnit.value;
            
            CLLocation * loc = RZReturnAutorelease([[CLLocation alloc] initWithLatitude:SEMICIRCLE_TO_DEGREE(latSemi) longitude:SEMICIRCLE_TO_DEGREE(longSemi)]);
            
            rv.locationValue = loc;
            rv.fieldKey = prefix;
        }
    }
    return rv;
}

#pragma mark - Access

-(fit::Field*)field{
    return self.originalField;
}
-(fit::Field*)additionalField{
    return self.complementField;
}

#pragma mark - display and description

-(NSString*)typeDescription{
    NSString * rv = nil;
    if( _originalField ){
        FIT_UINT8 fitBaseType = _originalField->GetType();
        switch (fitBaseType)
        {
            case FIT_BASE_TYPE_ENUM:
                rv = @"FIT_BASE_TYPE_ENUM";
                break;
            case FIT_BASE_TYPE_SINT8:
                rv = @"FIT_BASE_TYPE_SINT8";
                break;
            case FIT_BASE_TYPE_UINT8:
                rv = @"FIT_BASE_TYPE_UINT8";
                break;
            case FIT_BASE_TYPE_SINT16:
                rv = @"FIT_BASE_TYPE_SINT16";
                break;
            case FIT_BASE_TYPE_UINT16:
                rv = @"FIT_BASE_TYPE_UINT16";
                break;
            case FIT_BASE_TYPE_SINT32:
                rv = @"FIT_BASE_TYPE_SINT32";
                break;
            case FIT_BASE_TYPE_UINT32:
                rv = @"FIT_BASE_TYPE_UINT32";
                break;
            case FIT_BASE_TYPE_FLOAT32:
                rv = @"FIT_BASE_TYPE_FLOAT32";
                break;
            case FIT_BASE_TYPE_FLOAT64:
                rv = @"FIT_BASE_TYPE_FLOAT64";
                break;
            case FIT_BASE_TYPE_UINT8Z:
                rv = @"FIT_BASE_TYPE_UINT8Z";
                break;
            case FIT_BASE_TYPE_UINT16Z:
                rv = @"FIT_BASE_TYPE_UINT16Z";
                break;
            case FIT_BASE_TYPE_UINT32Z:
                rv = @"FIT_BASE_TYPE_UINT32Z";
                break;
            case FIT_BASE_TYPE_STRING:
                rv = @"FIT_BASE_TYPE_STRING";
            default:
                break;
        }
    }
    if (rv) {
        return rv;
    }else{
        return @"FIT_BASE_TYPE(UNKOWN)";
    }
}

-(NSString*)description{
    NSString * type = @"Unknown";
    if (self.dateValue){
        type = @"Date";
    }else if (self.enumValue) {
        type = @"Enum";
    }else if (self.stringValue){
        type = @"String";
    }else if (self.numberWithUnit){
        type = @"Number";
    }else if(self.locationValue){
        type = @"Loation";
    }
    return [NSString stringWithFormat:@"<%@[%@]=%@>", NSStringFromClass([self class]), type, self.displayString];
}

-(NSString*)displayString{
    if (self.dateValue){
        return [self.dateValue datetimeFormat];
    }else if (self.enumValue) {
        return self.enumValue;
    }else if (self.stringValue){
        return self.stringValue;
    }else if (self.numberWithUnit){
        return [self.numberWithUnit description];
    }else if(self.locationValue){
        return [NSString stringWithFormat:@"(%.4f,%.4f)", self.locationValue.coordinate.latitude, self.locationValue.coordinate.longitude];
    }else{
        return @"UNKNOWN";
    }
}
/**
 Will sort first: date, enum, string, numbers
 */
-(NSUInteger)sortCategory{
    if (self.dateValue) {
        return 0;
    }else if (self.enumValue){
        return 1;
    }else if (self.stringValue){
        return 2;
    }else if (self.locationValue){
        return 3;
    }else{
        return 4;
    }
}



@end
