//  MIT Licence
//
//  Created on 02/01/2013.
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

#import "GCGarminActivityDetailJsonParser.h"
#import "GCField+Convert.h"
#import "GCActivity.h"

@interface GCGarminActivityDetailJsonParser ()
@property (nonatomic,retain) GCActivity * activity;
@end

@implementation GCGarminActivityDetailJsonParser

-(instancetype)init{
    return [super init];
}

-(GCGarminActivityDetailJsonParser*)initWithData:(NSData*)jsonData forActivity:(GCActivity*)act{
    self = [super init];
    if (self) {
        NSError *e = nil;
        self.activity = act;
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];

        if (e) {
            self.success = false;
            RZLog(RZLogError, @"parsing failed %@", e);

        }else {
            self.success = true;
            if (json[@"metricDescriptors"]!=nil) {
                self.trackPoints = [NSArray arrayWithArray:[self parseModernFormat:json]];
            }else{
                NSArray * keys = json.allKeys;
                if (keys && [keys isKindOfClass:[NSArray class]] && keys.count > 0) {
                    if (json[@"error"]) {
                        self.success = false;
                        if ([json[@"error"] isEqualToString:@"WebApplicationException"]) {
                            RZLog(RZLogInfo, @"WebException, need login");
                            self.webError = true;
                        }else{
                            RZLog(RZLogError, @"Got json error %@", json[@"error"]);
                        }
                    }else{
                        self.trackPoints = [NSArray arrayWithArray:[self parseClassicFormat:json[json.allKeys[0]]]];
                    }
                }
            }
        }
    }

    return self;
}
-(void)dealloc{
    [_trackPoints release];
    [_activity release];
    [_cachedExtraTracksIndexes release];
    [super dealloc];
}

-(NSString*)activityType{
    return self.activity.activityType;
}
-(NSArray*)parseClassicFormat:(NSDictionary*)data{
    if (![data isKindOfClass:[NSDictionary class]]) {
        RZLog(RZLogError, @"Expected NSDictionary got %@", NSStringFromClass([data class]));
        self.success = false;
        return nil;
    }

    NSArray * measurements = data[@"measurements"];
    NSArray * metrics = data[@"metrics"];
    if (metrics == nil || measurements == nil) {
        RZLog(RZLogError, @"Unexpected shape for NSDictionary");
        return nil;
    }
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:metrics.count];
    for (NSDictionary * one in metrics) {
        NSArray * values = one[@"metrics"];

        NSMutableDictionary * onemeasurement = [NSMutableDictionary dictionaryWithCapacity:values.count];


        for (NSDictionary * defs in measurements) {
            NSUInteger index = [defs[@"metricsIndex"] integerValue];
            if (index < values.count) {
                double measure = [values[index] doubleValue];
                NSDictionary * d = @{@"display": defs[@"display"],
                                    @"unit": defs[@"unit"],
                                    @"value": @(measure)};
                onemeasurement[defs[@"key"]] = d;
            }
        }
        [rv addObject:onemeasurement];
    }
    return rv;
}

-(NSArray*)descriptorsWithDeveloperFields:(NSArray*)descriptors{
    if( ![descriptors isKindOfClass:[NSArray class]] ){
        return nil;
    }
    
    static NSDictionary * defs = nil;
    if( defs == nil){
        defs = @{
                            @"660a581e-5301-460c-8f2f-034c8b6dc90f":@{
                                    @0: @[ @"WeightedMeanPower", @"watt" ],
                                    @2: @[ @"WeightedMeanRunPower", @"stepPerMinutes"],
                                    @3: @[ @"WeightedMeanGroundContactTime", @"ms"],
                                    @4: @[ @"WeigthedMeanVerticalOscillation", @"centimeter"],
                                    @7: @[ @"GainElevation", @"meter"],
                                    @8: @[ @"WeightedMeanFormPower", @"watt"],
                                    @9: @[ @"WeightedMeanLegSpringStiffness", @"kN/m"],
                                    },
                            @"a26e5358-7526-4582-af7e-8606884d96bc":@{
                                    @1: @[@"WeightedMeanPower", @"watt"],
                                    },
                            //9ff75afa-d594-4311-89f7-f92ca02118ad[1] momentary energy expenditure
                            //9ff75afa-d594-4311-89f7-f92ca02118ad[2] relative running economy
                            
                            //a26e5358-7526-4582-af7e-8606884d96bc[1] running power
                            };
        [defs retain];
    }
    
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:descriptors.count];
    
    for (NSDictionary * one in descriptors) {
        NSDictionary * use = one;
        if( one[@"appID"] && one[ @"developerFieldNumber"]){
            NSMutableDictionary * fixed = [NSMutableDictionary dictionaryWithDictionary:one];
            fixed[@"unit"] = @{@"key":@"dimensionless"};
            
            NSString * appId = one[@"appID"];
            NSNumber * devNum = one[ @"developerFieldNumber"];
            NSString * fieldKey = [GCField fieldKeyForConnectIQAppID:appId andFieldNumber:devNum];
            if( fieldKey ){
                NSString * unitName = [GCField unitNameForConnectIQAppID:appId andFieldNumber:devNum];
                fixed[@"key"] = fieldKey;
                fixed[@"unit"] = @{@"key": unitName ?: @"dimensionless"};
            }
            use = [NSDictionary dictionaryWithDictionary:fixed];            
        }
        [rv addObject:use];
    }
    
    return rv;
}

-(NSArray*)parseModernFormat:(NSDictionary*)data{
    NSArray * descriptors = [self descriptorsWithDeveloperFields:data[@"metricDescriptors"]];
    NSArray * metrics = data[@"activityDetailMetrics"];
    NSMutableArray * rv = nil;
    BOOL errorReported = false;
    BOOL errorReportedDefs = false;
    if (descriptors && [metrics isKindOfClass:[NSArray class]]) {
        rv = [NSMutableArray arrayWithCapacity:metrics.count];
        self.cachedExtraTracksIndexes = nil;
        for (NSDictionary * one in metrics) {
            NSArray * values = one[@"metrics"];

            NSMutableDictionary * onemeasurement = [NSMutableDictionary dictionaryWithCapacity:values.count];

            for (NSDictionary * defs in descriptors) {
                if( [defs isKindOfClass:[NSDictionary class]]){
                    NSUInteger index = [defs[@"metricsIndex"] integerValue];
                    if (index < values.count) {
                        NSNumber * num = values[index];
                        if ([num respondsToSelector:@selector(doubleValue)]) {
                            double measure = [values[index] doubleValue];
                            NSString * key = defs[@"key"];
                            NSString * unitkey = nil;
                            
                            NSDictionary * unitDict = defs[@"unit"];
                            if( [unitDict isKindOfClass:[NSDictionary class]]){
                                unitkey = unitDict[@"key"];
                            }else if ([unitDict isKindOfClass:[NSString class]]){
                                unitkey  = (NSString*)unitDict;
                            }else{
                                if( ! errorReported ){
                                    RZLog(RZLogError, @"Received unknown unit type %@: %@", NSStringFromClass([unitDict class]), unitDict);
                                    errorReported = true;
                                }
                            }
                            if( unitkey ){
                                NSDictionary * d = @{@"unit": unitkey,
                                                     @"value": @(measure)};
                                onemeasurement[key] = d;
                            }
                        }
                    }
                }else{
                    if( ! errorReportedDefs){
                        errorReportedDefs = true;
                        RZLog(RZLogError, @"Received unknown metrics defs %@: %@", NSStringFromClass([defs class]), defs);
                    }
                }
            }
            GCTrackPoint * tp = [[GCTrackPoint alloc] initWithDictionary:onemeasurement forActivity:self];
            [rv addObject:tp];
            [tp release];
        }
    }
    return rv;
}

-(NSArray*)laps{
    return @[];
}
@end
