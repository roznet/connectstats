//  MIT Licence
//
//  Created on 10/10/2014.
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

#import "GCHealthSleepBlock.h"
#import "GCHealthSleepMeasure.h"

@implementation GCHealthSleepBlock

-(void)dealloc{
    [_blockId release];
    [_fromTime release];
    [_toTime release];
    [_measures release];

    [super dealloc];
}

+(GCHealthSleepBlock*)blockWithMeasures:(NSArray*)measures{
    GCHealthSleepBlock * rv = [[[GCHealthSleepBlock alloc] init] autorelease];
    if (rv) {
        if (measures.count>0) {
            NSMutableArray * blockMeasures = [NSMutableArray arrayWithCapacity:measures.count];
            rv.blockId = [measures[0] blockId];
            rv.fromTime = [measures[0] time];
            rv.sleepTime = 0.;
            for (GCHealthSleepMeasure * measure in measures) {
                if ([measure.blockId isEqualToString:rv.blockId]) {
                    [blockMeasures addObject:measure];
                    if ([measure isAsleep]) {
                        rv.sleepTime += measure.elapsed;
                    }
                }
            }
            rv.toTime = [blockMeasures.lastObject endTime];
            rv.measures = blockMeasures;
        }
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@ %d measures>",
            NSStringFromClass([self class]),
            self.blockId,
            [GCNumberWithUnit numberWithUnitName:@"second" andValue:[self.toTime timeIntervalSinceDate:self.fromTime]],
            (int)(self.measures).count
            ];
}

#pragma mark - database

-(void)saveToDb:(FMDatabase*)db{
    [db beginTransaction];
    if( [db intForQuery:@"SELECT count(*) FROM gc_health_sleep_blocks WHERE blockId = ?", self.blockId] > 0 ){
        [db executeUpdate:@"DELETE FROM gc_health_sleep_blocks WHERE blockId = ?", self.blockId] ;
    }

    [db executeUpdate:@"INSERT INTO gc_health_sleep_blocks (blockId,startTime,endTime,sleepTime) VALUES(?,?,?,?)",
     self.blockId,
     self.fromTime,
     self.toTime,
     @(self.sleepTime)
     ];
    for (GCHealthSleepMeasure * one in self.measures) {
        [one saveToDb:db];
    }
    [db commit];
}

-(void)loadFromDb:(FMDatabase*)db{
    FMResultSet * res  = [db executeQuery:@"SELECT * FROM gc_health_sleep_measures WHERE blockId = ? ORDER BY startTime", self.blockId];
    NSMutableArray * details=[NSMutableArray arrayWithCapacity:10];
    while ([res next]) {
        GCHealthSleepMeasure * one = [GCHealthSleepMeasure measureForResultSet:res];
        [details addObject:one];
    }
    self.measures = details;
}
+(GCHealthSleepBlock*)blockWithResultSet:(FMResultSet*)res{
    GCHealthSleepBlock * rv = [[[GCHealthSleepBlock alloc] init] autorelease];
    if (rv) {
        rv.blockId = [res stringForColumn:@"blockId"];
        rv.fromTime = [res dateForColumn:@"startTime"];
        rv.toTime =   [res dateForColumn:@"endTime"];
        rv.sleepTime = [res doubleForColumn:@"sleepTime"];
    }
    return rv;
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_health_sleep_blocks"]) {
        [db executeUpdate:@"CREATE TABLE gc_health_sleep_blocks (blockId TEXT KEY, startTime REAL, endTime REAL, sleepTime REAL)"];
    }
    [GCHealthSleepMeasure ensureDbStructure:db];
}
-(NSComparisonResult)compare:(GCHealthSleepBlock*)other{
    NSComparisonResult rv = [self.fromTime compare:other.fromTime];
    if (rv==NSOrderedSame) {
        rv = [self.toTime compare:other.toTime];
    }
    return rv;
}

@end
