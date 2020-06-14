//  MIT License
//
//  Created on 14/06/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCStatsDerivedAnalysisConfig.h"
#import "GCAppGlobal.h"

@interface GCStatsDerivedAnalysisConfig ()
@property (nonatomic,retain) GCDerivedOrganizer * cachedDerived;
@property (nonatomic,assign) NSUInteger derivedSerieMonthIndex;
@property (nonatomic,assign) NSUInteger derivedSerieFieldIndex;

@end

@implementation GCStatsDerivedAnalysisConfig
+(GCStatsDerivedAnalysisConfig*)configForActivityType:(NSString*)activityType{
    GCStatsDerivedAnalysisConfig * rv = RZReturnAutorelease([[GCStatsDerivedAnalysisConfig alloc] init]);
    if( rv ){
        rv.activityType = activityType;
    }
    return rv;
}
-(GCDerivedOrganizer*)derived{
    return self.cachedDerived ? self.cachedDerived : [GCAppGlobal derived];
}

-(void)setDerived:(GCDerivedOrganizer *)derived{
    self.cachedDerived = derived;
}

#pragma mark - DerivedDataSerie Management

-(NSArray<GCDerivedGroupedSeries*>*)availableDataSeries{
    NSArray * series = [[GCAppGlobal derived] groupedSeriesMatching:^(GCDerivedDataSerie*serie){
        BOOL rv = [serie.activityType isEqualToString:self.activityType] &&
        serie.derivedPeriod == gcDerivedPeriodMonth &&
        serie.derivedType == gcDerivedTypeBestRolling ;
        return rv;
    }];
    return series;
}

- (void)nextDerivedSerie {
    NSArray<GCDerivedGroupedSeries*>*available = [self availableDataSeries];
    
    if (self.derivedSerieFieldIndex<available.count) {
        GCDerivedGroupedSeries*current = available[self.derivedSerieFieldIndex];
        
        self.derivedSerieMonthIndex++;
        if (self.derivedSerieMonthIndex>=MIN(3, current.series.count)) {
            self.derivedSerieMonthIndex = 0;
            self.derivedSerieFieldIndex++;
            if (self.derivedSerieFieldIndex>=available.count) {
                self.derivedSerieFieldIndex = 0;
            }
        }
    }else{
        self.derivedSerieFieldIndex = 0;
        self.derivedSerieMonthIndex = 0;
    }
}

- (void)nextDerivedSerieField {
    NSArray<GCDerivedGroupedSeries*> * available = [self availableDataSeries];
    
    self.derivedSerieFieldIndex++;
    if (available && self.derivedSerieFieldIndex < available.count) {
        self.derivedSerieMonthIndex = 0;
    }else{
        self.derivedSerieMonthIndex = 0;
        self.derivedSerieFieldIndex = 0;
    }
}
-(GCDerivedDataSerie*)currentDerivedDataSerie{
    NSArray<GCDerivedGroupedSeries*>*available = [self availableDataSeries];
    GCDerivedDataSerie * current = nil;

    if (self.derivedSerieFieldIndex >= available.count) {
        self.derivedSerieFieldIndex = 0;
        self.derivedSerieMonthIndex = 0;
    }

    if (self.derivedSerieFieldIndex < available.count) {
        GCDerivedGroupedSeries * group = available[self.derivedSerieFieldIndex];
        if( self.derivedSerieMonthIndex < group.series.count){
            current = group.series[self.derivedSerieMonthIndex];
        }else if( group.series.count > 0){ // if index is too far reset to zero
            self.derivedSerieMonthIndex = 0;
            current = group.series[self.derivedSerieMonthIndex];
        }
    }
    return current;
}

-(void)setCurrentDerivedDataSerie:(GCDerivedDataSerie *)currentDerivedDataSerie{
    NSArray<GCDerivedGroupedSeries*>*available = [self availableDataSeries];
    NSUInteger newFieldIndex = 0;
    NSUInteger newMonthIndex = 0;
    
    for (newFieldIndex = 0; available.count; newFieldIndex++) {
        if( [available[newFieldIndex].field isEqualToField:currentDerivedDataSerie.field] ){
            break;
        }
    }
    
    if( newFieldIndex < available.count ){
        GCDerivedGroupedSeries * group = available[newFieldIndex];
        for (newMonthIndex = 0; newMonthIndex < group.series.count; newMonthIndex++) {
            if( [group.series[newMonthIndex].bucketStart isEqualToDate:currentDerivedDataSerie.bucketStart]){
                break;
            }
        }
        if( newMonthIndex < group.series.count ){
            self.derivedSerieFieldIndex = newFieldIndex;
            self.derivedSerieMonthIndex = newMonthIndex;
        }
    }
}

@end
