//  MIT Licence
//
//  Created on 30/09/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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
#import "GCActivity.h"
#import "GCFields.h"

typedef NS_ENUM(NSUInteger, gcTrackStatsStyle){
    gcTrackStatsData,
    gcTrackStatsRollingBest,
    gcTrackStatsHistogram,
    gcTrackStatsBucket,
    gcTrackStatsCumulative,
    gcTrackStatsCompare

};

@class GCHealthZoneCalculator;

@interface GCTrackStats : NSObject<GCSimpleGraphDataSource>

@property (nonatomic,retain) GCActivity * activity;

// Output
@property (nonatomic,readonly) GCStatsDataSerieWithUnit * data;
@property (nonatomic,readonly) NSArray<GCStatsDataSerieWithUnit*> * extra_data;
@property (nonatomic,readonly) GCStatsDataSerie * gradientSerie;
@property (nonatomic,readonly) NSObject<GCStatsFunction> * gradientFunction;
// Inputs
@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) GCField * x_field;
@property (nonatomic,retain) GCField * l_field;

// Configurations
@property (nonatomic,assign) NSUInteger movingAverage;
@property (nonatomic,assign) NSUInteger x_movingAverage;
@property (nonatomic,assign) NSUInteger l_movingAverage;
@property (nonatomic,assign) BOOL distanceAxis;
@property (nonatomic,assign) BOOL timeAxis;
@property (nonatomic,assign) gcTrackStatsStyle statsStyle;
/**
 GCField -> GCField dictionary to override map of fields, for example
 to change speed to come from a calculated field
 */
@property (nonatomic,retain) NSDictionary * fieldSourceMap;
/**
 @brief In Scatter plot, y will become sum for x Units.
 */
@property (nonatomic,assign) double movingSumForUnit;
/**
 @brief Bucket size for gcTrackStatsBucket mode
 */
@property (nonatomic,assign) double bucketUnit;

@property (nonatomic,retain) GCHealthZoneCalculator * zoneCalculator;
@property (nonatomic,assign) NSUInteger highlightLapIndex;
@property (nonatomic,assign) BOOL highlightLap;
/**
 This will only be used if statsStyle is compare
 */
@property (nonatomic,retain) GCActivity * compareActivity;

-(void)updateConfigFrom:(GCTrackStats*)other;

-(void)setupForFieldFlags:(gcFieldFlag)aField xField:(gcFieldFlag)xField andLField:(gcFieldFlag)lField;
-(void)setupForField:(GCField*)aField xField:(GCField*)xField andLField:(GCField*)lField;

-(void)setNeedsForRecalculate;

@end
