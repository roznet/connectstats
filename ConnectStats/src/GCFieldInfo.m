//  MIT Licence
//
//  Created on 26/03/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCFieldInfo.h"
#import "GCFieldsDefs.h"
#import "GCField.h"
#import "GCActivityType.h"

@interface GCFieldInfo ()
@property (nonatomic,retain) NSString * fieldKey;
@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) NSDictionary<NSNumber*,GCUnit*> * units;
@property (nonatomic,retain) NSString * displayName;

@end

@implementation GCFieldInfo

+(GCFieldInfo*)fieldInfoFor:(NSString*)field type:(NSString*)aType displayName:(NSString*)aDisplayName andUnitName:(NSString*)aUom{
    GCFieldInfo * rv = RZReturnAutorelease([[GCFieldInfo alloc] init]);
    if (rv) {
        rv.displayName = aDisplayName;
        rv.units = @{ @(GCUnitSystemMetric):[GCUnit unitForKey:aUom]
        };
        rv.field = [GCField fieldForKey:field andActivityType:aType];
        rv.fieldKey = field;
        rv.activityType = aType;
    }
    return rv;
}
+ (GCFieldInfo *)fieldInfoFor:(GCField *)field displayName:(NSString *)aDisplayName andUnits:(NSDictionary<NSNumber *,GCUnit *> *)units {
    GCFieldInfo * rv = RZReturnAutorelease([[GCFieldInfo alloc] init]);
    if (rv) {
        rv.displayName = aDisplayName;
        rv.units = units;
        rv.field = field;
        rv.fieldKey = field.key;
        rv.activityType = field.activityType;
    }
    return rv;
}
+(GCFieldInfo*)fieldInfoForActivityType:(NSString*)aType displayName:(NSString*)aDisplayName{
    GCFieldInfo * rv = RZReturnAutorelease([[GCFieldInfo alloc] init]);
    if (rv) {
        rv.displayName = aDisplayName;
        rv.units = @{};
        rv.field = nil;
        rv.activityType = aType;
    }
    return rv;
}

-(BOOL)match:(NSString*)str{
    if ([self.fieldKey isEqualToString:self.activityType] || [self.activityType isEqualToString:GC_TYPE_ALL]) {
        // special case don't match activity types
        return false;
    }
    NSRange res = [self.displayName rangeOfString:str options:NSCaseInsensitiveSearch];
    if (res.location != NSNotFound) {
        return true;
    }
    res = [self.fieldKey rangeOfString:str options:NSCaseInsensitiveSearch];
    if (res.location != NSNotFound) {
        return true;
    }
    return false;
}

-(GCUnit*)unit{
    return [self unitForSystem:[GCUnit getGlobalSystem]];
}
-(NSString*)activityType{
    return self.field.activityType;
}
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_displayName release];
    [_field release];
    [_fieldKey release];
    [_activityType release];
    [_units release];

    [super dealloc];
}
#endif
-(NSString*)description{
    return [NSString stringWithFormat:@"<GCFieldInfo:%@:%@:%@>",self.fieldKey,self.activityType,self.unit.key];
}


- (GCUnit *)unitForSystem:(gcUnitSystem)system { 
    GCUnit * rv = self.units[@(system)];
    if( rv == nil ){
        rv = self.units[@(GCUnitSystemDefault)];
    }
    if( rv == nil ){
        rv = self.units[@(GCUnitSystemMetric)];
    }
    return rv;
}

@end
