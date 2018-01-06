//  MIT Licence
//
//  Created on 08/06/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCHealthKitWorkoutParser.h"
#import "GCService.h"
#import "GCActivity+Import.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#endif

static  NSString * kGCSamples = @"kWorkoutParserSamples";
static  NSString * kGCResults    = @"kWorkoutParserResults";
static  NSString * kGCVersion = @"kWorkoutParserVersion";

@interface GCHealthKitWorkoutParser ()
@property (nonatomic,retain) NSDictionary * workoutSamples;
@property (nonatomic,retain) NSArray * results;

@end

@implementation GCHealthKitWorkoutParser

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.workoutSamples = [aDecoder decodeObjectForKey:kGCSamples];
        self.results = [aDecoder decodeObjectForKey:kGCResults];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:1 forKey:kGCVersion];
    [aCoder encodeObject:self.workoutSamples forKey:kGCSamples];
    [aCoder encodeObject:self.results forKey:kGCResults];
}

+(instancetype)parserWithWorkouts:(NSArray*)workouts andSamples:(NSDictionary*)samples{
    GCHealthKitWorkoutParser * rv = [[[GCHealthKitWorkoutParser alloc] init] autorelease];
    if (rv) {
        rv.workoutSamples = samples;
        rv.results = workouts;
    }
    return rv;
}

-(void)dealloc{
    [_workoutSamples release];
    [_results release];

    [super dealloc];
}


-(void)parse:(GCHealthKitWorkoutFoundActivity)cb{
#if GC_USE_HEALTHKIT
    for (HKWorkout * one in self.results) {
        NSString * aId = [[GCService service:gcServiceHealthKit] activityIdFromServiceId:one.UUID.UUIDString];
        GCActivity * act = [[GCActivity alloc] initWithId:aId
                                      andHealthKitWorkout:one
                                              withSamples:self.workoutSamples[one.UUID.UUIDString]];
        cb(act,aId);
        [act release];
    }
#endif

}

@end
