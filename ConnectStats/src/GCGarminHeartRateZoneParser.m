//  MIT Licence
//
//  Created on 16/10/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCGarminHeartRateZoneParser.h"
#import "GCHealthZoneCalculator.h"

@interface GCGarminHeartRateZoneParser ()
@property (nonatomic,assign) BOOL success;
@property (nonatomic,retain) NSDictionary<NSString*,GCHealthZoneCalculator*>*calculators;

@end

@implementation GCGarminHeartRateZoneParser

-(void)dealloc{
    [_calculators release];
    [super dealloc];
}

+(GCGarminHeartRateZoneParser*)parserWithData:(NSData*)data{
    GCGarminHeartRateZoneParser * rv = [[[GCGarminHeartRateZoneParser alloc] init] autorelease];
    if (rv) {
        NSError * e= nil;

        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];

        if (json && [json isKindOfClass:[NSArray class]]) {
            NSMutableDictionary * zones = [NSMutableDictionary dictionary];
            for (NSDictionary * one in json) {
                NSString * atype = one[@"sport"];
                if([atype isKindOfClass:[NSString class]]){
                    atype = [atype lowercaseString];
                    if( [atype isEqualToString:@"default"]) {
                        atype = GC_TYPE_ALL;
                    }
                }
                int idx = 1;
                NSMutableArray * zoneValues = [NSMutableArray array];
                NSMutableArray * zoneNames  = [NSMutableArray array];

                BOOL stop = false;
                while(!stop){
                    NSString * nextZoneKey = [NSString stringWithFormat:@"zone%dFloor", idx];
                    NSNumber * floor = one[nextZoneKey];
                    if( [floor isKindOfClass:[NSNumber class]]){
                        [zoneValues addObject:floor];
                        [zoneNames addObject:[NSString stringWithFormat:@"Zone %d", idx]];
                        idx++;
                    }else{
                        stop = true;
                    }
                }
                NSNumber * max = one[@"maxHeartRateUsed"];
                if( [max isKindOfClass:[NSNumber class]]){
                    [zoneValues addObject:max];
                    [zoneNames addObject:[NSString stringWithFormat:@"Zone %d", idx]];
                }
                GCField * field = [GCField fieldForFlag:gcFieldFlagWeightedMeanHeartRate andActivityType:atype];
                GCHealthZoneCalculator * calc = [GCHealthZoneCalculator zoneCalculatorForValues:zoneValues
                                                                                         inUnit:[GCUnit unitForKey:@"bpm"]
                                                                                      withNames:zoneNames
                                                                                          field:field
                                                                                      forSource:gcHealthZoneSourceGarmin];
                zones[ [GCHealthZoneCalculator keyForField:field andSource:gcHealthZoneSourceGarmin] ] = calc;
            }
            rv.success = true;

            rv.calculators = zones;
        }else{
            rv.success = false;
        }
    }
    return rv;
}


@end
