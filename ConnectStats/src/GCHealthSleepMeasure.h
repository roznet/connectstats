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

#import <Foundation/Foundation.h>

@class FMDatabase;
@class FMResultSet;

typedef NS_ENUM(NSUInteger, gcSleepState){
    gcSleepStateAwake = 0,
    gcSleepStateLightSleep = 1,
    gcSleepStateDeepSleep = 2,
    gcSleepStateREM = 3,
    gcSleepStateSleep = 4
};

@interface GCHealthSleepMeasure : NSObject
@property (nonatomic,retain) NSString * blockId;
@property (nonatomic,retain) NSDate * time;
@property (nonatomic,assign) NSTimeInterval elapsed;
@property (nonatomic,assign) gcSleepState state;

+(NSString*)sleepStateDescription:(gcSleepState)state;
+(BOOL)sleepStateIsAsleep:(gcSleepState)state;

+(GCHealthSleepMeasure*)measureForResultSet:(FMResultSet*)res;
+(GCHealthSleepMeasure*)measureFor:(NSDate*)time elapsed:(NSTimeInterval)elapsed state:(gcSleepState)state previous:(GCHealthSleepMeasure*)prev;

-(NSDate*)endTime;
-(BOOL)isImmediatelyFollowing:(GCHealthSleepMeasure*)other;
-(BOOL)isAsleep;

+(void)ensureDbStructure:(FMDatabase*)db;
-(void)saveToDb:(FMDatabase*)db;

@end
