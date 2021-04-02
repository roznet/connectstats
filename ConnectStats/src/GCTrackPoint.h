//  MIT Licence
//
//  Created on 18/09/2012.
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
#import "CoreLocation/CoreLocation.h"
#import "GCFields.h"
#import "GCField.h"
#import "GCTrackPointExtraIndex.h"

@class GCActivity;
@class GCActivitySummaryValue;

@interface GCTrackPoint : NSObject

/**
 @brief date and time of the point
 */
@property (nonatomic,retain) NSDate * time;
@property (nonatomic,assign) double longitudeDegrees;
@property (nonatomic,assign) double latitudeDegrees;

/**
 @brief Elapsed/Duration for which the Trackpoint is applicable
 */
@property (nonatomic,assign) NSTimeInterval elapsed;

/**
 @brief Distance since the beginning in meters
 */
@property (nonatomic,assign) double distanceMeters;

// Hard Coded Fields
@property (nonatomic,readonly) double heartRateBpm;
@property (nonatomic,readonly) double speed ;
@property (nonatomic,readonly) double cadence;
@property (nonatomic,readonly) double altitude;
@property (nonatomic,readonly) double power;
@property (nonatomic,readonly) double verticalOscillation;
@property (nonatomic,readonly) double groundContactTime;
@property (nonatomic,readonly) double steps;

@property (nonatomic,readonly) gcTrackEventType trackEventType;
@property (nonatomic,readonly) NSString * trackEventTypeDescription;

@property (nonatomic,assign) BOOL useMovingElapsed;

/**
 @brief Index in the laps
 */
@property (nonatomic,assign) NSUInteger lapIndex;
/**
 @brief flags with the fields available as gcFieldFlag
 */
@property (nonatomic,assign) NSUInteger trackFlags;
@property (nonatomic,readonly) NSDictionary<GCField*,GCNumberWithUnit*>*calculated;
@property (nonatomic,readonly) NSDictionary<GCField*,GCNumberWithUnit*>*extra;

@property (nonatomic,readonly) NSString * displayLabel;
@property (nonatomic,readonly) BOOL validCoordinate;
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate2D;
@property (nonatomic,readonly) CLLocation * location;


-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCTrackPoint*)initWithDictionary:(NSDictionary*)aDict forActivity:(GCActivity*)act NS_DESIGNATED_INITIALIZER;
-(GCTrackPoint*)initWithResultSet:(FMResultSet*)res NS_DESIGNATED_INITIALIZER;
-(GCTrackPoint*)initWithTrackPoint:(GCTrackPoint*)other NS_DESIGNATED_INITIALIZER;
-(GCTrackPoint*)initWithTCXElement:(GCXMLElement*)element;

+(GCTrackPoint*)trackPointWithCoordinate2D:(CLLocationCoordinate2D)coord;
+(GCTrackPoint*)trackPointWithCoordinate2D:(CLLocationCoordinate2D)coord
                                        at:(NSDate*)timestamp
                                       for:(NSDictionary<GCField*,GCActivitySummaryValue*>*)sumValues
                                inActivity:(GCActivity*)act;

-(void)saveToDb:(FMDatabase*)trackdb;
-(void)addExtraFromResultSet:(FMResultSet*)res inActivity:(GCActivity*)act;

-(BOOL)updateInActivity:(GCActivity*)act fromTrackpoint:(GCTrackPoint*)other fromActivity:(GCActivity*)otheract forFields:(NSArray<GCField*>*)fields;
-(BOOL)updateElapsedIfNecessaryIn:(GCActivity*)act;
-(void)updateWithExtra:(NSDictionary<GCField*,GCNumberWithUnit*>*)other;
-(void)recordExtraIn:(NSObject<GCTrackPointDelegate>*)act;

-(void)recordTrackEventType:(gcTrackEventType)trackEventType inActivity:(GCActivity*)act;

-(NSString*)fullDescriptionInActivity:(GCActivity*)act;
-(CLLocationDistance)distanceMetersFrom:(GCTrackPoint*)other;
-(NSTimeInterval)timeIntervalSince:(GCTrackPoint*)other;
-(NSComparisonResult)compareTime:(GCTrackPoint*)other;

+(GCUnit*)unitForField:(gcFieldFlag)aField andActivityType:(NSString*)aType;

-(void)add:(GCTrackPoint*)other withAccrued:(double)accrued timeAxis:(BOOL)timeAxis;
-(void)mergeWith:(GCTrackPoint*)other;
-(void)updateWithNextPoint:(GCTrackPoint*)next;

-(BOOL)realisticForActivityType:(NSString*)aType;


/**
 Main Access for value
 */
-(GCNumberWithUnit*)numberWithUnitForField:(GCField*)aF inActivity:(GCActivity*)act;
-(void)setNumberWithUnit:(GCNumberWithUnit*)nu forField:(GCField*)field inActivity:(GCActivity*)act;

-(NSArray<GCField*>*)availableFieldsInActivity:(GCActivity*)act;
-(BOOL)hasField:(GCField*)field inActivity:(GCActivity*)act;

-(void)clearCalculatedForFields:(NSArray<GCField*>*)fields;
-(void)addNumberWithUnitForCalculated:(GCNumberWithUnit*)aN forField:(GCField*)aF;


-(NSSet<GCField*>*)csvFieldsInActivity:(GCActivity*)act;
-(NSArray<NSString*>*)csvLabelsForFields:(NSArray<GCField*>*)fields InActivity:(GCActivity*)act;
-(NSArray<NSString*>*)csvValuesForFields:(NSArray<GCField*>*)fields InActivity:(GCActivity*)act;


-(void)accumulate:(GCTrackPoint*)other inActivity:(GCActivity*)act;
-(void)accumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to inActivity:(GCActivity*)act;
-(void)decumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to inActivity:(GCActivity*)act;
-(void)interpolate:(double)delta within:(GCTrackPoint*)diff inActivity:(GCActivity*)act;

-(void)difference:(GCTrackPoint*)from minus:(GCTrackPoint*)to inActivity:(GCActivity*)act;

-(void)augmentElapsed:(NSDate*)start inActivity:(GCActivity*)act;


@end
