//  MIT Licence
//
//  Created on 18/08/2013.
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

#import "GCGarminUserJsonParser.h"
#import "GCHealthZone.h"
#import "GCHealthZoneCalculator.h"

#define ZONE_DISPLAY @"display"
#define ZONE_NUMBER  @"number"
#define ZONE_FLOOR   @"floor"
#define ZONE_CEILING @"ceiling"


@implementation GCGarminUserJsonParser

-(instancetype)init{
    return [super init];
}
-(void)dealloc{
    [_data release];
    [super dealloc];
}

-(GCGarminUserJsonParser*)initWithString:(NSString*)theString andEncoding:(NSStringEncoding)encoding{
    self = [super init];
    if (self) {
        NSData *jsonData = [theString dataUsingEncoding:encoding];
        NSError *e = nil;

        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];

        if (json==nil) {
            self.success = false;
            RZLog(RZLogError, @"parsing failed %@", e);

        }else{
            self.data = [NSMutableDictionary dictionaryWithCapacity:5];

            void (^parseOne)(NSString*,gcFieldFlag) = ^(NSString*key,gcFieldFlag flag){
                NSDictionary * sub = json[@"userProfile"][key];
                if (sub) {
                    for (NSString * activityType in sub) {
                        NSMutableArray * found = [NSMutableArray arrayWithCapacity:5];
                        NSDictionary * toProcess = sub[activityType];
                        GCUnit * unit = [GCUnit unitForKey:toProcess[@"unit"][@"key"] ?: @"dimensionless" ] ;
                        NSArray * zones = toProcess[@"zones"];
                        GCField * field =[GCField fieldForFlag:flag andActivityType:activityType];
                        for (NSDictionary * one in zones) {

                            GCHealthZone * zone = [GCHealthZone zoneForField:field
                                                                        from:[one[ZONE_FLOOR] doubleValue]
                                                                          to:[one[ZONE_CEILING] doubleValue]
                                                                      inUnit:unit
                                                                       index:[one[ZONE_NUMBER] integerValue]
                                                                        name:one[ZONE_DISPLAY]
                                                                   andSource:gcHealthZoneSourceGarmin];

                            [found addObject:zone];
                        }
                        (self.data)[[GCHealthZoneCalculator keyForField:field andSource:gcHealthZoneSourceGarmin]] = [GCHealthZoneCalculator zoneCalculatorForZones:found andField:field];
                    }
                }
            };
            parseOne(@"heartRateZones", gcFieldFlagWeightedMeanHeartRate);
            parseOne(@"powerZones",     gcFieldFlagPower);

            self.success = true;
        }

    }
    return self;
}

@end
