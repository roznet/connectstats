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

#import "GCHealthZone.h"
#import "GCField.h"

#define ZONE_DISPLAY @"display"
#define ZONE_NUMBER  @"number"
#define ZONE_FLOOR   @"floor"
#define ZONE_CEILING @"ceiling"


NSArray<NSString*>*sourceKeys(){
    static NSArray<NSString*>* rv = nil;
    if(rv == nil){
        rv = @[
               @"auto",
               @"manual",
               @"strava",
               @"garmin"
               ];
        [rv retain];
    }
    return rv;
}
@implementation GCHealthZone

-(void)dealloc{
    [_unit release];
    [_zoneName release];
    [_field release];
    [super dealloc];
}

+(NSDictionary*)zoneJsonFrom:(double)floor to:(double)ceiling number:(NSUInteger)n andName:(NSString*)name{
    return @{ZONE_CEILING:@(ceiling),
             ZONE_FLOOR:@(floor),
             ZONE_DISPLAY:name,
             ZONE_NUMBER:@(n)};
}

+(GCHealthZone*)zoneForField:(GCField *)field
                        from:(double)floor
                          to:(double)ceiling
                      inUnit:(GCUnit *)unit
                       index:(NSUInteger)n
                        name:(NSString *)name
                   andSource:(gcHealthZoneSource)source{
    GCHealthZone * rv = [[[GCHealthZone alloc] init] autorelease];
    if (rv) {
        rv.field = field;
        rv.floor = floor;
        rv.ceiling = ceiling;
        rv.unit = unit;
        rv.zoneIndex = n;
        rv.zoneName = name;
        rv.source = source;
    }
    return rv;
}

+(GCHealthZone*)manualZoneFromZone:(GCHealthZone*)other{
    GCHealthZone * rv = [[[GCHealthZone alloc] init] autorelease];

    if (rv) {
        rv.field = other.field;
        rv.zoneIndex = other.zoneIndex;
        rv.zoneName = other.zoneName;
        rv.floor = other.floor;
        rv.ceiling = other.ceiling;
        rv.unit = other.unit;
        rv.source = gcHealthZoneSourceManual;
    }
    return rv;
}

+(GCHealthZone*)zoneWithResultSet:(FMResultSet*)rs{
    GCHealthZone * rv = [[[GCHealthZone alloc] init] autorelease];

    if (rv) {
        rv.field = [GCField fieldForKey:[rs stringForColumn:@"field"] andActivityType:[rs stringForColumn:@"activityType"]];
        rv.unit = [GCUnit unitForKey:[rs stringForColumn:@"zoneUnit"]];

        rv.zoneName = [rs stringForColumn:@"zoneName"];
        rv.zoneIndex =[rs intForColumn:@"zoneNumber"];
        rv.floor = [rs doubleForColumn:@"zoneFloor"];
        rv.ceiling = [rs doubleForColumn:@"zoneCeiling"];

        NSString * source = [rs stringForColumn:@"source"];
        if(source.length > 0){
            rv.sourceKey = source;
        }else{
            rv = nil;
        }
    }
    return rv;

}

-(NSString*)rangeLabel{
    NSString * top =[self.unit formatDouble:self.ceiling];
    NSString * bottom = [self.unit formatDoubleNoUnits:self.floor];
    return [NSString stringWithFormat:@"%@..%@", bottom, top];
}

-(NSString*)ceilingLabelNoUnits{
    return [self.unit formatDoubleNoUnits:self.ceiling];

}

-(NSString*)ceilingLabel{
    return [self.unit formatDouble:self.ceiling];
}
-(NSString*)label{
    return [self ceilingLabel];
}

-(void)saveToDb:(FMDatabase*)db{
    NSString * zoneId = [self zoneId];
    [db beginTransaction];
    if( [db intForQuery:@"SELECT count(*) FROM gc_health_zones WHERE zoneId = ?", zoneId] > 0 ){
        [db executeUpdate:@"DELETE FROM gc_health_zones WHERE zoneId = ?", zoneId];
    }


    if(![db executeUpdate:@"INSERT INTO gc_health_zones (zoneId,activityType,field,zoneName,zoneNumber,zoneFloor,zoneCeiling,zoneUnit,source) VALUES (?,?,?,?,?,?,?,?,?)",
         zoneId,
         self.field.activityType,
         self.field.key,
         self.zoneName,
         @(self.zoneIndex),
         @(self.floor),
         @(self.ceiling),
         (self.unit).key,
         self.sourceKey ?: @""

         ]){
        RZLog(RZLogError, @"Db save failed %@", db.lastErrorMessage);
    }
    [db commit];
    if ([db hadError]){
        RZLog(RZLogWarning, @"Db error: %@", [db lastErrorMessage]);
    }
}

-(NSString*)zoneId{
    NSString * sourceId = self.source ? [NSString stringWithFormat:@" %@", self.sourceKey] : @"";
    return [NSString stringWithFormat:@"%@[%ld]%@", self.field, (long)self.zoneIndex, sourceId ];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<GCHealthZone %@ %@ [%.0f,%.0f]>",
            self.zoneName,
            self.field,
            self.floor,
            self.ceiling];
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_health_zones"]) {
        [db executeUpdate:@"CREATE TABLE gc_health_zones (zoneId TEXT KEY, activityType TEXT, field TEXT, zoneName TEXT, zoneNumber REAL, zoneFloor REAL, zoneCeiling REAL, zoneUnit TEXT, source TEXT)"];
    }
}

+(NSString*)zoneSourceToKey:(gcHealthZoneSource)source{
    NSArray * keys = sourceKeys();
    if( source < keys.count){
        return keys[source];
    }else{
        return nil;
    }
}
+(gcHealthZoneSource)zoneSourceFromKey:(NSString*)sourceString{
    NSArray * keys = sourceKeys();
    NSUInteger found = [keys indexOfObject:sourceString];
    if( found == NSNotFound){
        found = gcHealthZoneSourceAuto;
    }
    return found;
}
+(NSArray<NSString*>*)validZoneSourceKeys{
    return sourceKeys();
}

+(NSString*)zoneSourceDescription:(gcHealthZoneSource)source{
    static NSArray<NSString*>*descriptions = nil;
    if( descriptions == nil){

        descriptions = @[
                         NSLocalizedString(@"Automatic", @"Health Zone Source"), //gcHealthZoneSourceAuto
                         NSLocalizedString(@"Manual", @"Health Zone Source"), //gcHealthZoneSourceManual
                         NSLocalizedString(@"Strava", @"Health Zone Source"), //gcHealthZoneSourceStrava
                         NSLocalizedString(@"Garmin", @"Health Zone Source"), //gcHealthZoneSourceGarmin
                         ];
        [descriptions retain];
    }
    return source < descriptions.count ? descriptions[source] : nil;
}


-(NSString*)sourceKey{
    return [GCHealthZone zoneSourceToKey:self.source];
}
-(void)setSourceKey:(NSString*)str{
    self.source = [GCHealthZone zoneSourceFromKey:str];
}

@end
