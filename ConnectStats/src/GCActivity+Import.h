//  MIT Licence
//
//  Created on 12/02/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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
@class GCActivitySummaryValue;
@class HKWorkout;

@interface GCActivity (Import)

//-(void)parseGarminJson:(NSDictionary*)aData;
-(void)parseStravaJson:(NSDictionary*)aData;

-(GCActivity*)initWithId:(NSString*)aId andGarminData:(NSDictionary*)aData;
-(GCActivity*)initWithId:(NSString*)aId andStravaData:(NSDictionary*)aData;
-(GCActivity*)initWithId:(NSString*)aId andSportTracksData:(NSDictionary*)aData;
-(GCActivity*)initWithId:(NSString *)aId andHealthKitWorkout:(HKWorkout*)workout withSamples:(NSArray*)samples;
-(GCActivity*)initWithId:(NSString *)aId andHealthKitSummaryData:(NSDictionary*)dict;
-(GCActivity*)initWithId:(NSString *)aId andConnectStatsData:(NSDictionary*)aData;

-(void)updateWithGarminData:(NSDictionary*)data;
-(BOOL)updateWithActivity:(GCActivity*)other;
-(BOOL)updateSummaryDataFromActivity:(GCActivity*)other;
-(BOOL)updateTrackpointsFromActivity:(GCActivity*)other;


/**
 Compute summary values from track points. Will add pace if necessary

 @param trackpoints will process speed, heartrate fields
 @return dictionary suitable for summaryData
 */
-(NSDictionary<GCField*,GCActivitySummaryValue*>*)buildSummaryFromTrackpoints:(NSArray<GCTrackPoint*>*)trackpoints;

/**
 Will update summaryData with data calculated from trackpoints

 @param trackpoints list of trackpoints, should be compatible with index of current activity
 @param missingOnly if true will not change existing value in summarydata, else will replace all
 
 @return true if something changed
 */
-(BOOL)updateSummaryFromTrackpoints:(NSArray<GCTrackPoint*>*)trackpoints missingOnly:(BOOL)missingOnly;


/**
 Checks in summary data for fields that should be set back as fieldFlag
 */
-(void)updateSummaryFieldFromSummaryData;

/**
 Update contents of summary data with new dict. Any existing field in summaryData
 will be replaced by the newDict value. Any summary field and flag will also
 be updated for keys that have a fieldFlag

 @param newDict Dictionary
 */
-(void)mergeSummaryData:(NSDictionary<GCField*,GCActivitySummaryValue*>*)newDict;

/**
 Helper to add Pace info to a mutable dictionary if speed is there
 and activity type warrants need for pace

 @param newSummaryData An summary mutable dictionary
 */
-(void)addPaceIfNecessaryWithSummary:(NSMutableDictionary<GCField*,GCActivitySummaryValue*>*)newSummaryData;

/**
 Build summary data using new format from garmin. Note some format have inconsistent units
 the dictionary for search have a few units for elevation and elapsed duration that are smaller.
 laps, activity etc seem to use dto unit
 
 @param data dictionary coming from garmin
 @param dtoUnits true if data cames from summaryDTO dictionary (as some units are different)
 @return dictionary field -> summary data
 */
-(NSMutableDictionary*)buildSummaryDataFromGarminModernData:(NSDictionary*)data dtoUnits:(BOOL)dtoUnitsFlag;
-(CLLocationCoordinate2D)buildCoordinateFromGarminModernData:(NSDictionary*)data;
-(NSDate*)buildStartDateFromGarminModernData:(NSDictionary*)data;

-(void)setSummaryField:(gcFieldFlag)which with:(GCNumberWithUnit*)nu;
-(GCActivitySummaryValue*)buildSummaryValue:(NSString*)fieldkey uom:(NSString*)uom fieldFlag:(gcFieldFlag)flag andValue:(double)val;

-(BOOL)testForDuplicate:(GCActivity*)other;
-(BOOL)isEqualToActivity:(GCActivity*)other;

@end
