//  MIT Licence
//
//  Created on 09/06/2015.
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

#import "GCHealthKitDailySummaryParser.h"
#import "GCActivity.h"
#import "GCActivity+Import.h"

#ifdef GC_USE_HEALTHKIT
#import <HealthKit/HealthKit.h>
#import <RZUtilsHealthkit/RZUtilsHealthkit.h>
#endif

#import "GCService.h"
#import "GCHealthKitRequest.h"

@interface GCHealthKitDailySummaryParser ()
@property (nonatomic,retain) NSDictionary * collected;
@end

@implementation GCHealthKitDailySummaryParser
+(instancetype)parserWithSamples:(NSDictionary*)samples{
    GCHealthKitDailySummaryParser * rv = [[[GCHealthKitDailySummaryParser alloc]init] autorelease];
    if (rv) {
        rv.collected = samples;
    }
    return rv;
}

-(void)dealloc{
    [_collected release];
    [_sourceValidator release];

    [super dealloc];
}

-(void)collectQuantity:(HKQuantity*)quantity
            identifier:(NSString*)identifier
                  date:(NSDate*)date
                prefix:(NSString*)prefix
                  into:(NSMutableDictionary*)data{
    if (quantity) {

        GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnit:[GCHealthKitRequest unitForIdentifier:identifier]
                                                     andQuantity:quantity];
        NSString * field = [GCHealthKitRequest fieldForIdentifier:identifier prefix:prefix];
        if (nu) {
            data[field] = nu;
        }else{
            RZLog(RZLogError, @"Failed to convert %@ (%@)", quantity, identifier);
        }
    }

}

-(HKSource*)sourceForStats:(HKStatistics*)stats{
    NSArray * sources = stats.sources;

    if (sources) {
        if (self.sourceValidator) {
            for (HKSource * source in sources) {
                if (self.sourceValidator(source.bundleIdentifier)) {
                    return source;
                }
            }
        }else if(sources.count > 0){
            return sources[0];
        }
    }
    return nil;
}

-(void)parse:(GCHealthKitDailySummaryFoundActivity)cb{
    for (NSDate * date in self.collected) {
        NSArray * stats = self.collected[date];
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:@{@"BeginTimestamp":date,@"activityType":GC_TYPE_DAY}];

        for (HKStatistics * result in stats) {
            HKQuantityType * type = result.quantityType;

            HKSource * source = [self sourceForStats:result];

            if (source) {
                if (result.averageQuantity) {
                    [self collectQuantity:[result averageQuantityForSource:source]
                               identifier:type.identifier
                                     date:result.startDate
                                   prefix:@"WeightedMean"
                                     into:data];
                }
                if (result.maximumQuantity) {
                    [self collectQuantity:[result maximumQuantityForSource:source]
                               identifier:type.identifier
                                     date:result.startDate
                                   prefix:@"Max"
                                     into:data];
                }
                if (result.minimumQuantity) {
                    [self collectQuantity:[result minimumQuantityForSource:source]
                               identifier:type.identifier
                                     date:result.startDate
                                   prefix:@"Min"
                                     into:data];
                }
                if (result.sumQuantity) {
                    [self collectQuantity:[result sumQuantityForSource:source]
                               identifier:type.identifier
                                     date:result.startDate
                                   prefix:@"Sum"
                                     into:data];

                }
            }
        }
        if (data.count>2) {
            NSString * aId = [[GCService service:gcServiceHealthKit] activityIdFromServiceId:[GCHealthKitRequest dayActivityId:date]];
            GCActivity * act = [[GCActivity alloc] initWithId:aId andHealthKitSummaryData:data];
            cb(act,aId);
            [act release];
        }

    }
}

@end
