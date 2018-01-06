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

#import "GCHealthSleepMeasure.h"

@implementation GCHealthSleepMeasure

+(BOOL)sleepStateIsAsleep:(gcSleepState)state{
    return state != gcSleepStateAwake;
}
+(NSString*)sleepStateDescription:(gcSleepState)state{
    NSString * rv = nil;
    switch (state) {
        case gcSleepStateAwake:
            rv = @"Awake";
            break;
        case gcSleepStateDeepSleep:
            rv = @"Deep Sleep";
            break;
        case gcSleepStateLightSleep:
            rv = @"Light Sleep";
            break;
        case gcSleepStateREM:
            rv = @"REM";
            break;
        case gcSleepStateSleep:
            rv = @"Sleep";
            break;
    }
    return rv;
}

+(GCHealthSleepMeasure*)measureFor:(NSDate*)date elapsed:(NSTimeInterval)elapsed state:(gcSleepState)state previous:(GCHealthSleepMeasure*)prev{
    GCHealthSleepMeasure * rv = [[[GCHealthSleepMeasure alloc] init] autorelease];
    if (rv) {
        rv.time = date;
        rv.elapsed = elapsed;
        rv.state = state;
        if (prev && [rv isImmediatelyFollowing:prev]) {
            rv.blockId = prev.blockId;
        }else{
            rv.blockId = [rv.time YYYYMMDDhhmmGMT];
        }
    }
    return rv;
}
-(void)dealloc{
    [_time release];
    [_blockId release];
    [super dealloc];
}

-(NSDate*)endTime{
    return [self.time dateByAddingTimeInterval:self.elapsed];
}
-(BOOL)isImmediatelyFollowing:(GCHealthSleepMeasure*)other{
    NSTimeInterval since = [self.time timeIntervalSinceDate:other.time];
    return since  > 0 && fabs(since-other.elapsed) <= 60.*10.; // 10 minutes
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@ %@>",
            NSStringFromClass([self class]),
            self.time,
            [GCNumberWithUnit numberWithUnitName:@"second" andValue:self.elapsed],
            [GCHealthSleepMeasure sleepStateDescription:self.state]
            ];
}


#pragma mark - database

-(void)saveToDb:(FMDatabase*)db{
    if( [db intForQuery:@"SELECT count(*) FROM gc_health_sleep_measures WHERE blockId = ? and startTime = ?", self.blockId,self.time] > 0 ){
        [db executeUpdate:@"DELETE FROM gc_health_sleep_measures WHERE blockId = ? and startTime = ?", self.blockId,self.time] ;
    }

    [db executeUpdate:@"INSERT INTO gc_health_sleep_measures (blockId,startTime,elapsed,state) VALUES(?,?,?,?)",
     self.blockId,
     self.time,
     @(self.elapsed),
     @(self.state)
     ];

}

+(GCHealthSleepMeasure*)measureForResultSet:(FMResultSet*)res{
    GCHealthSleepMeasure * rv = [[[GCHealthSleepMeasure alloc] init] autorelease];
    if (rv) {
        rv.time = [res dateForColumn:@"startTime"];
        rv.elapsed =[res doubleForColumn:@"elapsed"];
        rv.state = [res intForColumn:@"state"];
        rv.blockId = [res stringForColumn:@"blockId"];
    }
    return rv;
}
-(BOOL)isAsleep{
    return self.state > 0;
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_health_sleep_measures"]) {
        [db executeUpdate:@"CREATE TABLE gc_health_sleep_measures (blockId TEXT, startTime REAL, elapsed REAL, state REAL)"];
    }
}

@end
