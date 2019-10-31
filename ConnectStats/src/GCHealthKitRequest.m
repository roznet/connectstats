//  MIT Licence
//
//  Created on 20/08/2014.
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

#import "GCHealthKitRequest.h"
//#import <HealthKit/HealthKit.h>

#import "GCAppGlobal.h"

@interface GCHealthKitRequest ()
@property (nonatomic,assign) NSUInteger readQuantityIndex;

@end

@implementation GCHealthKitRequest

+(BOOL)isSupported{
#ifdef GC_USE_HEALTHKIT
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [HKHealthStore class];
#else
    return false;
#endif
}

+(instancetype)request{
    GCHealthKitRequest * rv = [[[self alloc] init] autorelease];
    rv.status = GCWebStatusOK;
    return rv;
}
-(void)dealloc{
    [_delegate release];
    [_results release];
    [_error release];
    [_data release];

    [super dealloc];
}

#ifdef GC_USE_HEALTHKIT
-(HKQuantityType*)currentQuantityType{
    NSArray * types =  [self readSampleTypes];
    if (self.readQuantityIndex<types.count) {
        return types[self.readQuantityIndex];
    }
    return nil;
}

-(HKHealthStore*)healthStore{
    return [GCAppGlobal healthKitStore];
}

+(NSDictionary*)hkidentifierDefinitions{
    static NSDictionary * defs = nil;
    if( defs == nil) {
        defs = @{
                 HKQuantityTypeIdentifierStepCount:@[ @(HKStatisticsOptionCumulativeSum),
                                                      [GCUnit unitForKey:@"step"],
                                                      @"Step",
                                                      @(gcFieldFlagCadence)],
                 HKQuantityTypeIdentifierHeartRate:@[ @(HKStatisticsOptionDiscreteAverage|HKStatisticsOptionDiscreteMax|HKStatisticsOptionDiscreteMin),
                                                      [GCUnit unitForKey:@"bpm"],
                                                      @"HeartRate",
                                                      @(gcFieldFlagWeightedMeanHeartRate)],
                 HKQuantityTypeIdentifierDistanceWalkingRunning:@[ @(HKStatisticsOptionCumulativeSum),
                                                                   [GCUnit unitForKey:STOREUNIT_DISTANCE],
                                                                   @"Distance",
                                                                   @(gcFieldFlagSumDistance)],
                 HKQuantityTypeIdentifierDistanceCycling:@[ @(HKStatisticsOptionCumulativeSum),
                                                            [GCUnit unitForKey:STOREUNIT_DISTANCE],
                                                            @"Distance",
                                                            @(gcFieldFlagSumDistance)],
                 HKQuantityTypeIdentifierFlightsClimbed:@[ @(HKStatisticsOptionCumulativeSum),
                                                           [GCUnit unitForKey:@"floor"],
                                                           @"FloorClimbed",
                                                           @(gcFieldFlagAltitudeMeters)]

                 };
        [defs retain];
    }
    return defs;
}


+(HKStatisticsOptions)optionForIdentifier:(NSString*)identifier{
    NSDictionary * defs = [GCHealthKitRequest hkidentifierDefinitions];
    return [defs[identifier][0] integerValue];
}
+(GCUnit*)unitForIdentifier:(NSString*)identifier{
    NSDictionary * defs = [GCHealthKitRequest hkidentifierDefinitions];
    return defs[identifier][1];
}
+(NSString*)fieldForIdentifier:(NSString*)identifier prefix:(NSString*)prefix{
    NSDictionary * defs = [GCHealthKitRequest hkidentifierDefinitions];
    if (defs[identifier]) {
        return [NSString stringWithFormat:@"%@%@", prefix, defs[identifier][2]];
    }else{
        return nil;
    }
}

+(gcFieldFlag)fieldFlagForIdentifier:(NSString*)identifier{
    NSDictionary * defs = [GCHealthKitRequest hkidentifierDefinitions];
    return [defs[identifier][3] intValue];
}

#endif

-(NSString*)description{
#ifdef GC_USE_HEALTHKIT
    NSString * type = [self currentReadSampleType].identifier;
    if ([type hasPrefix:@"HKQuantityTypeIdentifier"]) {
        type = [type substringFromIndex:(@"HKQuantityTypeIdentifier").length];
    }
#else
    NSString * type = @"Disabled";
#endif
    return [NSString stringWithFormat:@"HealthKit Request %@", type];
}
-(NSString*)url{
    return nil;
}
-(NSDictionary*)postData{
    return nil;
}
-(NSDictionary*)deleteData{
    return nil;
}
-(NSData*)fileData{
    return nil;
}
-(NSString*)fileName{
    return nil;
}

-(NSArray*)readSampleTypes{
    return @[ ];
}
#ifdef GC_USE_HEALTHKIT
-(HKSampleType*)currentReadSampleType{
    if (self.readQuantityIndex < [self readSampleTypes].count) {
        return [self readSampleTypes][self.readQuantityIndex];
    }
    return nil;
}


-(HKSampleType*)writeSampleType{
    return nil;
}


-(NSSet*)dataTypesToWrite{
    return [NSSet set];
}
-(NSSet*)dataTypesToRead{
    NSArray * types = [self readSampleTypes];
    if (types) {
        return [NSSet setWithArray:[self readSampleTypes]];
    }
    return [NSSet set];
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    self.delegate = delegate;
    if (self.healthStore) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];

        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {

            if (!success) {
                self.status = GCWebStatusAccessDenied;
                RZLog(RZLogError, @"HealthKit access was not granted");
                [self.delegate processDone:self];
                return;
            }

            // Handle success in your app here.
            [self performSelectorOnMainThread:@selector(executeQuery) withObject:nil waitUntilDone:NO];
        }];
    }
}
-(void)resetAnchor{
    NSString * anchorFileName = [[GCAppGlobal profile] currentQueryAnchorFilePathForClass:[self class]];
    [RZFileOrganizer removeEditableFile:anchorFileName];
}


-(HKQueryAnchor*)anchor{
    NSString * anchorFileName = [[GCAppGlobal profile] currentQueryAnchorFilePathForClass:[self class]];
    NSString * anchorFilePath = [RZFileOrganizer writeableFilePathIfExists:anchorFileName];
    if (anchorFilePath) {
        NSData * data = [NSData dataWithContentsOfFile:anchorFilePath];
        return [NSKeyedUnarchiver unarchivedObjectOfClass:[HKQueryAnchor class] fromData:data error:nil];
    }else{
        return [HKQueryAnchor anchorFromValue:HKAnchoredObjectQueryNoAnchor];
    }
}

-(void)setAnchor:(HKQueryAnchor*)nA{
    NSString * anchorFileName = [[GCAppGlobal profile] currentQueryAnchorFilePathForClass:[self class]];
    NSString * anchorFilePath = [RZFileOrganizer writeableFilePath:anchorFileName];
    [[NSKeyedArchiver archivedDataWithRootObject:nA requiringSecureCoding:YES error:nil] writeToFile:anchorFilePath atomically:YES];
}

-(void)executeQuery{
    if ([self currentReadSampleType]) {
        /*
        HKAnchoredObjectQuery * query = [[HKAnchoredObjectQuery alloc] initWithType:[self currentReadSampleType]
                                                                          predicate:nil
                                                                             anchor:self.anchor
                                                                              limit:HKObjectQueryNoLimit
                                                                  completionHandler:^(HKAnchoredObjectQuery *query,
                                                                                      NSArray *results,
                                                                                      NSUInteger newAnchor,
                                                                                      NSError *error){
                                                                      self.anchor = newAnchor;
                                                                      self.error = error;
                                                                      self.results = results;

                                                                      [self performSelector:@selector(processResults) onThread:[GCAppGlobal worker] withObject:nil waitUntilDone:NO];
                                                                  }
                                         ];
        */
        HKAnchoredObjectQuery * query = [[HKAnchoredObjectQuery alloc] initWithType:[self currentReadSampleType]
                                                                          predicate:nil
                                                                             anchor:self.anchor
                                                                              limit:HKObjectQueryNoLimit
                                                                  resultsHandler:^(HKAnchoredObjectQuery *thequery,
                                                                                      NSArray *results,
                                                                                    NSArray * deletedObjects,
                                                                                      HKQueryAnchor* newAnchor,
                                                                                      NSError *error){
                                                                      self.anchor = newAnchor;
                                                                      self.error = error;
                                                                      self.results = results;
                                                                      dispatch_async([GCAppGlobal worker],^(){
                                                                          [self processResults];
                                                                      });
                                                                  }
                                         ];

        [self.healthStore executeQuery:query];
        [query release];
    }else{
        [self.delegate processDone:self];
    }
}

-(void)processResults{
    for (HKQuantitySample * sample in self.results) {
        RZLog(RZLogError, @"Not Processed: %@ %@", [sample quantityType], [sample quantity]);
    }
    [self.delegate processDone:self];
}
#else
-(void)process:(NSString *)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>)delegate{
    [self.delegate processDone:self];
}
#endif

-(id<GCWebRequest>)nextReq{
    if (self.readQuantityIndex+1<[self readSampleTypes].count) {
        GCHealthKitRequest * next = [[[[self class] alloc] init] autorelease];
        next.readQuantityIndex=self.readQuantityIndex+1;
        next.data = self.data;
        return next;
    }
    return nil;
}
-(gcWebService)service{
    return gcWebServiceHealthStore;
}

-(BOOL)isSameAsRequest:(id)req{
    if ([req isMemberOfClass:[self class]] && self.readQuantityIndex == [req readQuantityIndex]) {
        return true;
    }
    return false;
}
-(BOOL)isLastRequest{
    return self.readQuantityIndex+1 > [self readSampleTypes].count;
}
-(void)nextQuantityType{
    self.readQuantityIndex += 1;
}
//-(void)preConnectionSetup;
//-(GTMOAuth2Authentication*)oauth2Authentication;
//-(NSString*)activityId;
//-(id<GCWebRequest>)remediationReq;
-(void)processDone{
    [self.delegate performSelectorOnMainThread:@selector(processDone:) withObject:self waitUntilDone:NO];
}

-(void)saveCollectedData:(NSDictionary*)dict withSuffix:(NSString*)suffix andId:(NSString*)aid{
#if DEBUG
    NSString * name = [NSString stringWithFormat:@"health_%@_%@.data", suffix, aid];
    if(![[NSKeyedArchiver archivedDataWithRootObject:dict requiringSecureCoding:YES error:nil] writeToFile:[RZFileOrganizer writeableFilePath:name] atomically:YES]){
        RZLog(RZLogError, @"ERROR %@", name);
    }
#endif
}

+(NSString*)dayActivityId:(NSDate*)date{
    return [NSString stringWithFormat:@"%@_%@",[[GCAppGlobal profile] currentProfileName], [date YYYYMMDD]];
}

@end
