//  MIT License
//
//  Created on 28/03/2020 for ConnectStats
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



#import "GCActivity.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCActivity (Series)

#pragma mark - Access Functions

/**
 Return a dataSerie for the field if available.
 The serie will be indexed by time. The standard Filter for the field
 Will have been applied
 */
-(GCStatsDataSerieWithUnit*)timeSerieForField:(GCField*)field;

/**
 Return a dataSerie for the field if available.
 The serie will be indexed by distance
 */
-(GCStatsDataSerieWithUnit*)distanceSerieForField:(GCField*)field;


/**
 Special time serie for swimStroke, will return the value of gcSwimStrokeType for
 each swim length recorded. Will match the x of the other serie in case a filter was applied
 */
-(GCStatsDataSerie * )timeSerieForSwimStrokeMatching:(GCStatsDataSerie*)other;
/**
 Will return a serie for each track point that is 0 if that trackpoint is not
 in lap or the time/distance since the beginning of the lap
 */
-(GCStatsDataSerie*)highlightSerieForLap:(NSUInteger)lap timeAxis:(BOOL)timeAxis;

/**
 will return a serie that is the total distance (or time if timeAxis==false) since beginning
 versus elapsed (or distance if timeAxis==false)
 */
-(GCStatsDataSerieWithUnit*)progressSerie:(BOOL)timeAxis;
/**
 Compare Cumulative Graph
 */
-(GCStatsDataSerieWithUnit*)cumulativeDifferenceSerieWith:(GCActivity*)compareTo timeAxis:(BOOL)timeAxis;

#pragma mark - Laps Series
/**
 return a serie with the value of field for each lap
 */
-(GCStatsDataSerieWithUnit*)lapSerieForTrackField:(GCField*)field timeAxis:(BOOL)timeAxis;


#pragma mark - Internals

/**
 Standard filter to apply for given trackfield
 */
-(GCStatsDataSerieWithUnit*)applyStandardFilterTo:(GCStatsDataSerieWithUnit*)serieWithUnit ForField:(GCField*)field;

@end

NS_ASSUME_NONNULL_END
