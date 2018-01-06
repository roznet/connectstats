//  MIT Licence
//
//  Created on 17/05/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCActivityTennisHeatmap.h"
#import "GCActivityTennisHeatmap.h"

@implementation GCActivityTennisHeatmap

+(NSArray*)keysInOrder{
    static NSArray * keys = nil;
    if ( keys == nil){
        keys = @[ @"center", @"up", @"down", @"left", @"right" ];
        [keys retain];
    }
    return keys;
}

+(GCActivityTennisHeatmap*)heatmapForJson:(NSDictionary *)dict{
    GCActivityTennisHeatmap * rv = [[[GCActivityTennisHeatmap alloc] init] autorelease];
    if (rv) {
        NSMutableArray * locations = [NSMutableArray arrayWithCapacity:gcHeatmapLocationEnd];
        NSArray * keys = [GCActivityTennisHeatmap keysInOrder];
        GCUnit * pct = [GCUnit unitForKey:@"percent"];
        if( [dict isKindOfClass:[NSDictionary class]]){
        for (NSString * key in keys) {
            id val = dict[key];
            if (val && [val respondsToSelector:@selector(doubleValue)]) {
                [locations addObject:[GCNumberWithUnit numberWithUnit:pct andValue:[val doubleValue]]];
            }else{
                [locations addObject:[GCNumberWithUnit numberWithUnit:pct andValue:0.]];
            }
        }
        }else{
            RZLog(RZLogWarning, @"Invalid heatmap json");
        }
        rv.heatmap = [NSArray arrayWithArray:locations];
    }
    return rv;
}
+(GCActivityTennisHeatmap*)heatmapForResultSet:(FMResultSet*)res{
    GCActivityTennisHeatmap * rv = [[[GCActivityTennisHeatmap alloc] init] autorelease];

    if (rv) {
        NSMutableArray * locations = [NSMutableArray arrayWithCapacity:gcHeatmapLocationEnd];
        NSArray * keys = [GCActivityTennisHeatmap keysInOrder];
        GCUnit * pct = [GCUnit unitForKey:@"percent"];
        for (NSString * key in keys) {
            [locations addObject:[GCNumberWithUnit numberWithUnit:pct andValue:[res doubleForColumn:key]]];
        }
        rv.heatmap = [NSArray arrayWithArray:locations];
    }
    return rv;
}

-(void)dealloc{
    [_heatmap release];
    [super dealloc];
}

-(void)saveToDb:(FMDatabase*)db forId:(NSString*)aId andType:(NSString*)aType{
    NSMutableArray * args = [NSMutableArray arrayWithArray:@[aId, aType]];
    [args addObjectsFromArray:self.heatmap];

    [db beginTransaction];
    FMResultSet * res = [db executeQuery:@"SELECT * FROM babolat_heatmaps WHERE session_id=? AND heatmap_type=?", aId,aType];
    if ([res next]) {
        [res close];
        if (![db executeUpdate:@"DELETE FROM babolat_heatmaps WHERE session_id=? AND heatmap_type=?", aId,aType]) {
            RZLog(RZLogError, @"delete failed %@", [db lastErrorMessage]);
        }
    }
    NSString * query = @"INSERT INTO babolat_heatmaps (session_id,heatmap_type,center,up,down,left,right) VALUES (?,?,?,?,?,?,?)";
    if (![db executeUpdate:query  withArgumentsInArray:args]) {
        RZLog(RZLogError, @"insert failed %@", [db lastErrorMessage]);
    }
    if (![db commit]) {
        RZLog(RZLogError, @"commit failed %@", [db lastErrorMessage]);
    }
}

-(GCNumberWithUnit*)valueForLocation:(gcHeatmapLocation)loc{
    if (loc < self.heatmap.count) {
        return (self.heatmap)[loc];
    }
    return nil;
}

+(BOOL)isHeatmapField:(NSString*)field{
    return [field hasPrefix:@"heatmap_"];
}
+(NSString*)heatmapField:(NSString*)type location:(gcHeatmapLocation)location{
    NSArray * keys = [GCActivityTennisHeatmap keysInOrder];
    return [NSString stringWithFormat:@"heatmap_%@_%@", type, keys[ location ]];
}

+(NSArray*)heatmapFieldInfo:(NSString*)field{
    static NSMutableDictionary * fields = nil;
    if (fields==nil) {
        fields = [NSMutableDictionary dictionary];
        [fields retain];
    }
    NSArray * rv = fields[field];
    if (rv == nil && [field hasPrefix:@"heatmap_"]) {
        NSArray * comp = [field componentsSeparatedByString:@"_"];
        if (comp.count == 3) {
            NSString * locstr = comp[2];
            NSArray * keys = [GCActivityTennisHeatmap keysInOrder];
            for (gcHeatmapLocation i=gcHeatmapLocationCenter; i<gcHeatmapLocationEnd; i++) {
                if ([keys[i] isEqualToString:locstr]) {
                    rv = @[ comp[1], @(i)];
                    fields[field] = rv;
                    break;
                }
            }
        }
    }
    return rv;
}

+(NSString*)heatmapFieldType:(NSString*)field{
    return [GCActivityTennisHeatmap heatmapFieldInfo:field][0];
}
+(gcHeatmapLocation)heatmapFieldLocation:(NSString*)field{
    NSNumber * v = [GCActivityTennisHeatmap heatmapFieldInfo:field][1];
    return v.intValue;
}



@end
