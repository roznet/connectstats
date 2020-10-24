//
//  GCStatsSerieOfSerieWithUnits.h
//  RZUtils
//
//  Created by Brice Rosenzweig on 17/11/2019.
//  Copyright © 2019 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RZUtils/GCStatsDataSerieWithUnit.h>

NS_ASSUME_NONNULL_BEGIN

@class GCStatsDateBuckets;

@interface GCStatsSerieOfSerieWithUnits : NSObject
@property (nonatomic,readonly) GCUnit * sUnit;

/**
    Serie of series for sValues in sUnits
        date1 serie1(x0,x1,....xn)
        date2 serie2(x0,x1,...xn)
        ....
    you can then extract a new serie for x:
        date1,val1=serie1(x),
        date2,val2=serie2(x)
        ....
 */
+(GCStatsSerieOfSerieWithUnits*)serieOfSerieWithUnits:(GCUnit*)sUnit;

-(void)addSerie:(GCStatsDataSerieWithUnit*)serie for:(GCNumberWithUnit*)val;
-(void)addSerie:(GCStatsDataSerieWithUnit*)serie forDate:(NSDate*)date;

-(void)addSerieOfSerie:(GCStatsSerieOfSerieWithUnits*)other;

-(GCStatsDataSerieWithUnit*)serieForX:(GCNumberWithUnit*)x;

-(NSArray<GCNumberWithUnit*>*)allXs;


@end

NS_ASSUME_NONNULL_END
