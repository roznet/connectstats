//  MIT Licence
//
//  Created on 25/03/2017.
//
//  Copyright (c) 2017 Brice Rosenzweig.
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

#import "RZTimeStampManager.h"
#import <RZUtils/RZMacros.h>
#import <RZUtils/FMDatabase.h>
#import "FMDatabaseAdditions.h"
#import "RZLog.h"

// Limit will be multiplied when
// possible the query will not find all as unique
const NSUInteger kLimitMultiplier = 5;


@interface RZTimeStampManager ()
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) NSString * table;



@property (nonatomic,retain) NSString * lastKey;

@end

@implementation RZTimeStampManager

+(instancetype)timeStampManagerWithDb:(FMDatabase*)db andTable:(NSString*)table{
    RZTimeStampManager * rv = [[RZTimeStampManager alloc] init];
    if(rv){
        rv.db = db;
        rv.table = table;
        rv.collector = ^(){
            return [NSDate date];
        };
        rv.queryLimit = 10;
        rv.recordChangeOnly = true;
        [rv ensureDbStructure];
    }
    return rv;
}

-(void)ensureDbStructure{
    if(![self.db tableExists:self.table]){
        NSString * query = [NSString stringWithFormat:@"CREATE TABLE %@ (ts_key TEXT, ts_timestamp REAL)", self.table];
        RZEXECUTEUPDATE(self.db, query);
    }
}

-(void)recordTimeStampForKey:(NSString*)key{
    if( ![self.lastKey isEqualToString:key] || !self.recordChangeOnly){
        NSDate * ts = self.collector();
        NSString * query = [NSString stringWithFormat:@"INSERT INTO %@ (ts_key,ts_timestamp) VALUES (?,?)", self.table];
        RZEXECUTEUPDATE(self.db, query, key, ts);
        self.lastKey = key;
    }
}

-(NSArray<NSString*>*)lastKeysSorted{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ts_timestamp DESC LIMIT %lu", self.table,
                        (unsigned long)self.queryLimit*kLimitMultiplier];
    FMResultSet * res = [self.db executeQuery:query];
    NSMutableDictionary * bykey = [NSMutableDictionary dictionaryWithCapacity:self.queryLimit];
    NSMutableDictionary * bydate = [NSMutableDictionary dictionaryWithCapacity:self.queryLimit];

    while( [res next]){
        NSString * key = [res stringForColumn:@"ts_key"];
        NSDate * ts = [res dateForColumn:@"ts_timestamp"];

        if( ! bykey[key] ){
            bykey[key] = ts;
            bydate[ts] = key;
        }
        if( [bydate count] >= self.queryLimit){
            break;
        }
    }

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.queryLimit];
    NSArray * orderedDates = [bydate.allKeys sortedArrayUsingComparator:^(NSDate * d1, NSDate * d2){ return [d2 compare:d1]; }];
    for (NSDate * date in orderedDates) {
        [rv addObject:bydate[date]];
    }
    return rv;
}

-(NSArray<NSDate*>*)lastTimeStampsForKey:(NSString*)key{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ts_key = ? ORDER BY ts_timestamp DESC LIMIT %lu", self.table, (unsigned long)self.queryLimit*kLimitMultiplier];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.queryLimit];
    FMResultSet * res = [self.db executeQuery:query, key];

    while([res next]){
        [rv addObject:[res dateForColumn:@"ts_timestamp"]];
        if( [rv count] >= self.queryLimit){
            break;
        }
    }

    return rv;
}
-(NSDictionary<NSString*,NSDate*>*)lastKeysAndTimeStamps{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ts_timestamp DESC LIMIT %lu", self.table,
                        (unsigned long)self.queryLimit*5];
    FMResultSet * res = [self.db executeQuery:query];
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:self.queryLimit];
    while( [res next]){
        NSString * key = [res stringForColumn:@"ts_key"];
        NSDate * ts = [res dateForColumn:@"ts_timestamp"];

        if( ! rv[key] ){
            rv[key] = ts;
        }
        if( [rv count] >= self.queryLimit){
            break;
        }
    }
    return rv;
}


-(void)purgeTimeStampsOlderThan:(NSUInteger)days{
    NSString * query = [NSString stringWithFormat:@"SELECT MAX(ts_timestamp) AS recent FROM %@", self.table];
    FMResultSet * res = [self.db executeQuery:query];
    NSDate * cutoff = nil;

    if( [res next]){
        cutoff = [[res dateForColumn:@"recent"] dateByAddingTimeInterval:((-1. * 24. * 3600. * days) +1.)];
    }

    if(cutoff==nil){
        return;
    }

    query = [NSString stringWithFormat:@"SELECT ts_key, MAX(ts_timestamp) AS recent, MIN(ts_timestamp) AS oldest FROM %@ GROUP BY ts_key", self.table];
    res = [self.db executeQuery:query];
    NSMutableDictionary * keyToMaxDate = [NSMutableDictionary dictionary];



    while([res next]){
        NSDate * maxDate = [res dateForColumn:@"recent"];
        NSDate * minDate = [res dateForColumn:@"oldest"];

        // Don't bother issuing delete update is oldest date is more recent than cutoff
        if( [minDate compare:cutoff] == NSOrderedAscending){
            // If most recent date is older than cutoff, preserve it
            if ([maxDate compare:cutoff] == NSOrderedAscending) {
                keyToMaxDate[ [res stringForColumn:@"ts_key"] ] = [maxDate dateByAddingTimeInterval:-1.]; // everything older than max Date
            }else {
                keyToMaxDate[ [res stringForColumn:@"ts_key"] ] = cutoff;
            }
        }
    }

    NSString * update = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ts_key = ? AND ts_timestamp < ?", self.table];
    for (NSString * key in keyToMaxDate) {
        RZEXECUTEUPDATE(self.db, update, key, keyToMaxDate[key]);
    }
}

@end
