//  MIT Licence
//
//  Created on 09/09/2012.
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
#import <CoreLocation/CoreLocation.h>
#import "GCFields.h"
#import "GCField.h"
#import "GCLap.h"
#import "GCActivityMetaValue.h"
#import "GCWeather.h"
#import "GCActivitySettings.h"
#import "GCActivityTypes.h"
#import "GCActivityType.h"

@class GCLapSwim;
@class GCTrackPointSwim;
@class GCActivity;
@class GCService;
@class GCActivitySummaryValue;
@class GCActivityCalculatedValue;


typedef BOOL (^GCActivityMatchBlock)(GCActivity*act);

#define GC_ALL_LAPS -1
#define GC_LAPS_RECORDED        @"__LapsRecorded__"
#define GC_LAPS_SPLIT_DISTHALF  @"__LapsDistanceHalf__"
#define GC_LAPS_SPLIT_DISTQTER  @"__LapsDistanceQuarter__"
#define GC_LAPS_SPLIT_TIMEHALF  @"__LapsTimeHalf__"
#define GC_LAPS_SPLIT_TIMEQTER  @"__LapsTimeQuarter__"

extern NSString * kGCActivityNotifyDownloadDone;
extern NSString * kGCActivityNotifyTrackpointReady;

typedef NS_ENUM(NSUInteger, gcDownloadMethod) {
    gcDownloadMethodDefault     = 0,
    gcDownloadMethodSwim        = 1,
    gcDownloadMethodDetails     = 2,
    gcDownloadMethod13          = 3,
    gcDownloadMethodTennis      = 4,
    gcDownloadMethodStrava      = 5,
    gcDownloadMethodSportTracks = 6,
    gcDownloadMethodFitFile     = 7,
    gcDownloadMethodHealthKit   = 8,
    gcDownloadMethodWithings    = 9,
    gcDownloadMethodModern      = 10,
    gcDownloadMethodConnectStats= 11
};

typedef NS_ENUM(NSUInteger, gcIgnoreMode) {
    gcIgnoreModeActivityFocus,
    gcIgnoreModeDayFocus
};

@interface GCActivity : RZParentObject<RZChildObject>{
    // Private Flags
    BOOL _summaryDataLoading;
    BOOL _downloadRequested;
}

@property (nonatomic,retain) NSString * activityId;

@property (nonatomic,retain) NSDictionary<GCField*,GCActivitySummaryValue*> * summaryData;
@property (nonatomic,retain) NSDictionary<NSString*,GCActivityMetaValue*> * metaData;
@property (nonatomic,retain) NSDictionary<GCField*,GCActivityCalculatedValue*> * calculatedFields;
@property (nonatomic,retain) NSDictionary<NSString*,NSArray*> * calculatedLaps;
@property (nonatomic,retain) NSDictionary<GCField*,GCTrackPointExtraIndex*> * cachedExtraTracksIndexes;
/**
 NSString -> GCCalculactedCachedTrackInfo (to be calculated) or GCStatsDataSerieWithUnit
 */
@property (nonatomic,retain) NSDictionary * cachedCalculatedTracks;


@property (nonatomic,retain) NSString * activityType;// DEPRECATED_MSG_ATTRIBUTE("use GCActivityType.");
@property (nonatomic,retain) GCActivityType * activityTypeDetail;// DEPRECATED_MSG_ATTRIBUTE("use detail of GCActivityType.");
@property (nonatomic,retain) NSString * activityName;

@property (nonatomic,retain) NSString * location;
@property (nonatomic,retain) NSDate * date;
@property (nonatomic,assign) CLLocationCoordinate2D beginCoordinate;

@property (nonatomic,assign) double sumDistance;
@property (nonatomic,assign) double sumDuration;
@property (nonatomic,assign) double weightedMeanHeartRate;
@property (nonatomic,assign) double weightedMeanSpeed;
@property (nonatomic,retain) NSString * speedDisplayUom;
@property (nonatomic,retain) NSString * distanceDisplayUom;

@property (nonatomic,assign) NSUInteger flags;
@property (nonatomic,assign) NSUInteger trackFlags;
@property (nonatomic,assign) BOOL garminSwimAlgorithm;
@property (nonatomic,assign) gcDownloadMethod downloadMethod;

@property (nonatomic,retain) NSString * calculatedLapName;
@property (nonatomic,retain) GCWeather * weather;

@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) FMDatabase * trackdb;

@property (nonatomic,retain) GCActivitySettings * settings;

#pragma mark - Readonly

@property (nonatomic,readonly) NSString* trackDbFileName;

@property (nonatomic,readonly) NSString * externalActivityId;
@property (nonatomic,readonly) GCService * service;

/**
 Array of trackpoints. Note it maybe lazy loaded so
 can return nil, but asking for this will trigger attempt to load from db
 or download from web if applicable
 */
@property (nonatomic,retain) NSArray<GCTrackPoint*> * trackpoints;

/**
 @brief For multi-sport activities, the parent activityId
 */
@property (nonatomic,retain) NSString * parentId;

/**
 @brief For multi-sport activities, Arrays of child activityIds
 */
@property (nonatomic,retain) NSArray<NSString*> * childIds;
/**
 @brief To maintain an activityId in an external system
 */
@property (nonatomic,retain) NSString*externalServiceActivityId;

/**
 @brief Display name, if none, will use location.
 @return Non-nil NSString
 */
@property (nonatomic,readonly) NSString * displayName;

#pragma mark - Methods

-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCActivity*)initWithId:(NSString*)aId NS_DESIGNATED_INITIALIZER;
-(GCActivity*)initWithResultSet:(FMResultSet*)res NS_DESIGNATED_INITIALIZER;

-(BOOL)saveTrackpoints:(NSArray*)aTrack andLaps:(NSArray*)laps;
-(void)saveTrackpointsSwim:(NSArray<GCTrackPointSwim*> *)aSwim andLaps:(NSArray<GCLapSwim*>*)laps;
-(void)saveTrackpointsAndLapsToDb:(FMDatabase*)aDb;
-(void)saveLocation:(NSString*)aLoc;

#pragma mark - Trackpoints and time series
/**
 Will check if the track database is obsolete
 */
-(BOOL)trackdbIsObsolete:(FMDatabase*)trackdb;

/** @brief check if trackpoint require web download. Will not trigger any load or download
    @return True is trackpoints not loaded and no trackdb available
             False if trackpoints are loaded or trackdb available
 */
-(BOOL)trackPointsRequireDownload;

/**
 check if trackpoints are ready. Will load from trackdb if exists or start download
 */
-(BOOL)trackpointsReadyOrLoad;

/**
 checks if trackpoints are ready, but won't trigger any load or download
 */
-(BOOL)trackpointsReadyNoLoad;
/**
 Checks if trackdb file exists, but will not open it.
 */
-(BOOL)hasTrackDb;

-(void)clearTrackdb;

-(BOOL)hasTrackField:(gcFieldFlag)which;
//-(void)addTrackPoint:(GCTrackPoint*)point;

/**
 Check if activities has trackfield available. Note it may not be available
 immediately and require a load from the database or web
 */
-(BOOL)hasTrackForField:(GCField*)field;

/**
 Return the next Field which has a track serie.
 If one is nil or not a valid field, the first available field will be returned
 */
-(GCField*)nextAvailableTrackField:(GCField*)one;

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
 Standard filter to apply for given trackfield
 */
-(GCStatsDataSerieWithUnit*)applyStandardFilterTo:(GCStatsDataSerieWithUnit*)serieWithUnit ForField:(GCField*)field;

/**
 Special time serie for swimStroke, will return the value of gcSwimStrokeType for
 each swim length recorded
 */
-(GCStatsDataSerie*)timeSerieForSwimStroke;
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
/**
 Return list of available fields with Track Points. Will include calculated tracks
 @return NSArray<GCField*>
 */
-(NSArray<GCField*>*)availableTrackFields;
/**
 Will clear trackpoints, trackpoints database files and retrigger reload from the web service
 */
-(void)forceReloadTrackPoints;

/**
 Will load trackpoints from a database. This should be mainly used in testing,
 It is preferrable to use the trackpoints properly directly.
 */
-(void)loadTrackPointsFromDb:(FMDatabase*)trackdb;

#pragma mark - Field Access
/**
 unit to use for given field. Can be specific to this activity (displayUnit)
 so not always the same as the generic unit for a field
 */
-(GCUnit*)displayUnitForField:(GCField*)field;

/**
 Unit that should be used to store value of field
 */
-(GCUnit*)storeUnitForField:(GCField*)field;

/**
 return numberWithUnit for field. This is the main access function for values
 */
-(GCNumberWithUnit*)numberWithUnitForField:(GCField*)field;

/**
 Format a value with unit similar to a given field
 */
-(NSString*)formatValue:(double)aval forField:(GCField*)which;

/**
 Format a value with unit similar to a given field, unit name not displayed
 */
-(NSString*)formatValueNoUnits:(double)aval forField:(GCField*)which;

/**
 Format a numberWithUnit similar to how field which would be formatted.
 It will convert to displayUnit which may be different than generic field
 */
-(NSString*)formatNumberWithUnit:(GCNumberWithUnit*)nu forField:(GCField*)which;
/**
 Return value for field formatted as number with unit
 */
-(NSString*)formattedValue:(GCField*)field;

-(BOOL)hasField:(GCField*)field;

/**
 Returns all available summary fields as GCField. Includes calculated fields.
 */
-(NSArray<GCField*>*)allFields;
/**
 Returns all available summary fields as NSString Keys. Includes calculated fields.
 */
-(NSArray<NSString*>*)allFieldsKeys DEPRECATED_MSG_ATTRIBUTE("use allFields.");

-(GCActivityMetaValue*)metaValueForField:(NSString*)field;


/**
 Add a dictionary of metavalue entries
 */
-(void)addEntriesToMetaData:(NSDictionary<NSString*,GCActivityMetaValue*> *)dict;
-(void)addEntriesToCalculatedFields:(NSDictionary<GCField*,GCActivityCalculatedValue*> *)dict;

#pragma mark - Laps

-(NSArray<GCLap*>*)laps;
-(NSUInteger)lapCount;
-(GCLap*)lapNumber:(NSUInteger)idx;
-(GCTrackPointSwim*)swimLapNumber:(NSUInteger)idx;
-(void)registerLaps:(NSArray<GCLap*>*)laps forName:(NSString*)name;
-(BOOL)useLaps:(NSString*)name;
-(void)focusOnLapIndex:(NSUInteger)lapIndex;//cheat/hint for lapcoumpound with several point in same lap
/**
 return a serie with the value of field for each lap
 */
-(GCStatsDataSerieWithUnit*)lapSerieForTrackField:(GCField*)field timeAxis:(BOOL)timeAxis;

-(void)purgeCache;
-(BOOL)validCoordinate;

-(BOOL)hasWeather;
-(void)recordWeather:(GCWeather*)dict;


/**
 Test wether should be ignored for stats based on the mode
 */
-(BOOL)ignoreForStats:(gcIgnoreMode)mode;
-(BOOL)isSkiActivity;

@end
