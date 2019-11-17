//
//  GCStatsSerieOfSerieWithUnits.h
//  RZUtils
//
//  Created by Brice Rosenzweig on 17/11/2019.
//  Copyright © 2019 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCStatsDataSerieWithUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCStatsSerieOfSerieWithUnits : NSObject
@property (nonatomic,readonly) GCUnit * sUnit;

+(GCStatsSerieOfSerieWithUnits*)serieOfSerieWithUnits:(GCUnit*)sUnit;

-(void)addSerie:(GCStatsDataSerieWithUnit*)serie for:(GCNumberWithUnit*)val;
-(void)addSerie:(GCStatsDataSerieWithUnit*)serie forDate:(NSDate*)date;

-(GCStatsDataSerieWithUnit*)serieForX:(GCNumberWithUnit*)x;

@end

NS_ASSUME_NONNULL_END
