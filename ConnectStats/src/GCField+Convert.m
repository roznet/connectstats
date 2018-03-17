//  MIT License
//
//  Created on 11/03/2018 for ConnectStats
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "GCField+Convert.h"
@import RZUtils;

const NSUInteger kDefsConnectIQFieldKeyIndex = 0;
const NSUInteger kDefsConnectIQUnitNameIndex = 1;

@implementation GCField (Convert)

+(NSArray*)connectIQDefsForAppID:(NSString*)appId andFieldNumber:(NSNumber*)num{
    if( appId == nil || num == nil)
        return nil;
    
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
                 @"9ff75afa-d594-4311-89f7-f92ca02118ad": @{
                         @1 : @[ @"WeightedMeanMomentaryEnergyExpenditure", @"dimensionless"],
                         @2 : @[ @"WeightedMeanRelativeRunningEconomy", @"dimensionless" ],
                         },
                 };
        RZRetain(defs);
    }
    NSArray * rv = defs[appId][num];
    
    if( rv == nil){
        static NSMutableDictionary * remember = nil;
        if( ! remember ){
            remember = [NSMutableDictionary dictionary];
            RZRetain(remember);
        }
        NSString * appKey = [NSString stringWithFormat:@"%@[%@]", appId, num];
        if( ! remember[appKey]){
            RZLog(RZLogInfo, @"Unknown ConnectIQ field appid[devfield] %@", appKey);
            remember[appKey] = @1;
        }
    }
    return rv;
}

+(NSString*)fieldKeyForConnectIQAppID:(NSString*)appId andFieldNumber:(NSNumber*)num{
    return [GCField connectIQDefsForAppID:appId andFieldNumber:num][kDefsConnectIQFieldKeyIndex];
}
+(NSString*)unitNameForConnectIQAppID:(NSString*)appId andFieldNumber:(NSNumber*)num{
    return [GCField connectIQDefsForAppID:appId andFieldNumber:num][kDefsConnectIQUnitNameIndex];
}

@end
