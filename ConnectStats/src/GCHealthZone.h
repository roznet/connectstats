//  MIT Licence
//
//  Created on 18/08/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import <Foundation/Foundation.h>
#import "GCFields.h"

@class  GCField;

typedef NS_ENUM(NSUInteger,gcHealthZoneSource) {
    gcHealthZoneSourceAuto,
    gcHealthZoneSourceManual,
    gcHealthZoneSourceStrava,
    gcHealthZoneSourceGarmin
};

@interface GCHealthZone : NSObject
@property (nonatomic,retain) GCField*field;
/**
 zone name is a holder for a text description of the zone
 */
@property (nonatomic,retain) NSString*zoneName;
/**
 Floor is really the key number used for the zone.
 */
@property (nonatomic,assign) double floor;
/**
 Ceiling is more for display and expected to be equal to next zone floor
 */
@property (nonatomic,assign) double ceiling;
/**

 */
@property (nonatomic,assign) NSUInteger zoneIndex;
@property (nonatomic,retain) GCUnit * unit;

@property (nonatomic,assign) gcHealthZoneSource source;
@property (nonatomic,retain) NSString * sourceKey;

+(GCHealthZone*)zoneForField:(GCField*)field
                        from:(double)floor
                          to:(double)ceiling
                      inUnit:(GCUnit*)unit
                      index:(NSUInteger)n
                        name:(NSString*)name
                   andSource:(gcHealthZoneSource)source;

+(GCHealthZone*)manualZoneFromZone:(GCHealthZone*)other;

+(GCHealthZone*)zoneWithResultSet:(FMResultSet*)rs;

-(void)saveToDb:(FMDatabase*)db;

-(NSString*)ceilingLabelNoUnits;
-(NSString*)ceilingLabel;
-(NSString*)rangeLabel;

+(void)ensureDbStructure:(FMDatabase*)db;

+(NSString*)zoneSourceToKey:(gcHealthZoneSource)source;
+(gcHealthZoneSource)zoneSourceFromKey:(NSString*)sourceString;
+(NSArray<NSString*>*)validZoneSourceKeys;
+(NSString*)zoneSourceDescription:(gcHealthZoneSource)source;
@end
