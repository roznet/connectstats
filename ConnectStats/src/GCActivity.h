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
#import "GCTrackPointExtraIndex.h"
#import "GCAppConstants.h"

@class GCLapSwim;
@class GCTrackPointSwim;
@class GCActivity;
@class GCService;
@class GCActivitySummaryValue;
@class GCActivityCalculatedValue;
@class GCCalculatedCachedTrackInfo;
@class GCCalculatedCachedTrackKey;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^GCActivityMatchBlock)(GCActivity*act);

#define GC_ALL_LAPS -1
#define GC_LAPS_RECORDED        @"__LapsRecorded__"
#define GC_LAPS_SPLIT_DISTHALF  @"__LapsDistanceHalf__"
#define GC_LAPS_SPLIT_DISTQTER  @"__LapsDistanceQuarter__"
#define GC_LAPS_SPLIT_TIMEHALF  @"__LapsTimeHalf__"
#define GC_LAPS_SPLIT_TIMEQTER  @"__LapsTimeQuarter__"
#define GC_LAPS_ACCUMULATED     @"__LapsAccumulated__"

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

@interface GCActivity : RZParentObject<RZChildObject,GCTrackPointDelegate>{
    // Private Flags
    BOOL _summaryDataLoading;
}

@property (nonatomic,retain) NSString * activityId;

@property (nonatomic,readonly) NSDictionary<GCField*,GCActivitySummaryValue*> * summaryData;

/**
 @brief public interface is read only, should be set with updateMetaData as some flag need to be sync'd
 */
@property (nonatomic,readonly) NSDictionary<NSString*,GCActivityMetaValue*> * metaData;
/**
    All implementation detail should be hidden in GCActivity+CachedTracked.h
 */
@property (nullable,nonatomic,retain) NSDictionary<GCField*,GCCalculatedCachedTrackInfo*> * cachedCalculatedTracks;


@property (nonatomic,readonly) NSString * activityType;// DEPRECATED_MSG_ATTRIBUTE("use GCActivityType.");
@property (nonatomic,readonly) GCActivityType * activityTypeDetail;// DEPRECATED_MSG_ATTRIBUTE("use detail of GCActivityType.");
@property (nonatomic,retain) NSString * activityName;

@property (nonatomic,retain) NSString * location;
@property (nonatomic,retain) NSDate * date;
/**
 @brief convenience functions
 */
@property (nonatomic,readonly) NSDate * startTime;
@property (nonatomic,readonly) NSDate * endTime;
@property (nonatomic,assign) CLLocationCoordinate2D beginCoordinate;

@property (nonatomic,assign) NSUInteger flags;
@property (nonatomic,assign) NSUInteger trackFlags;
@property (nonatomic,assign) BOOL garminSwimAlgorithm;
@property (nonatomic,assign) gcDownloadMethod downloadMethod;

@property (nonatomic,retain) NSString * calculatedLapName;
@property (nullable,nonatomic,retain) GCWeather * weather;

@property (nonatomic,retain,nullable) FMDatabase * db;
@property (nonatomic,retain) FMDatabase * trackdb;

@property (nonatomic,retain) GCActivitySettings * settings;

@property (nonatomic,readonly) BOOL pendingUpdate;
/**
 * flag to indicate the activity has unsaved Changes
 */
@property (nonatomic,assign) BOOL hasUnsavedChanges;

#pragma mark - Readonly

@property (nonatomic,readonly) NSString* trackDbFileName;

/**
 @brief the activityId on the external service if differetn from the activityId in the database (for example 1234 when the activityId is __service__1234)
 */
@property (nonatomic,readonly) NSString * externalActivityId;
@property (nonatomic,readonly) GCService * service;

@property (nonatomic,readonly) GCUnit * speedDisplayUnit;
@property (nonatomic,readonly) GCUnit * distanceDisplayUnit;

/**
 Array of trackpoints. Note it maybe lazy loaded so
 can return nil, but asking for this will trigger attempt to load from db
 or download from web if applicable
 */
@property (nullable,nonatomic,retain) NSArray<GCTrackPoint*> * trackpoints;

/**
 @brief For multi-sport activities, the parent activityId
 */
@property (nullable,nonatomic,retain) NSString * parentId;

/**
 @brief For multi-sport activities, Arrays of child activityIds
 */
@property (nullable,nonatomic,retain) NSArray<NSString*> * childIds;
/**
 @brief To maintain an activityId in an external system. For example an activity from ConnectStats Service should have a activityID on the garmin service
 */
@property (nullable,nonatomic,retain) NSString*externalServiceActivityId;

/**
 Avoid to use directly, should be used via GCActivity+Assets functions
 */
@property (nullable,nonatomic,retain) NSDictionary * assetsInfo;

/**
 @brief Display name, if none, will use location.
 @return Non-nil NSString
 */
@property (nonatomic,readonly) NSString * displayName;

/**
 @brief Disable an activity for all stats
 */
@property (nonatomic,assign) BOOL skipAlways;

@property (nonatomic,assign) NSUInteger serviceStatus;
@property (nonatomic,readonly) NSString*serviceStatusDescription;

#pragma mark - Methods

-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCActivity*)initWithId:(NSString*)aId NS_DESIGNATED_INITIALIZER;
-(GCActivity*)initWithResultSet:(FMResultSet*)res NS_DESIGNATED_INITIALIZER;

-(BOOL)updateWithTrackpoints:(NSArray<GCTrackPoint*>*)trackpoints andLaps:(nullable NSArray<GCLap*>*)laps;
-(BOOL)saveTrackpoints:(NSArray<GCTrackPoint*>*)aTrack andLaps:(nullable NSArray<GCLap*>*)laps;

/// Logic to change activity type
/// @param newActivityType if nil will do nothing
/// @return true if activityType actually changed
-(BOOL)changeActivityType:(GCActivityType*)newActivityType;

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
//-(void)registerTrackpoints:(NSArray<GCTrackPoint*>*)points forName:(NSString*)name;
//-(BOOL)useTrackpoints:(NSString*)name;

/**
 Check if activities has trackfield available. Note it may not be available
 immediately and require a load from the database or web
 */
-(BOOL)hasTrackForField:(GCField*)field;

/**
 Return the next Field which has a track serie.
 If one is nil or not a valid field, the first available field will be returned
 */
-(nullable GCField*)nextAvailableTrackField:(nullable GCField*)one;

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
-(nullable GCNumberWithUnit*)numberWithUnitForField:(GCField*)field;
/**
 @brief Set number for field
 @return true if changed or new, false if unchanged
*/
-(BOOL)setNumberWithUnit:(GCNumberWithUnit*)nu forField:(GCField*)field;
/**
 *  @brief set summary field
 *  @return true if value changed
 */
-(BOOL)setSummaryField:(gcFieldFlag)which with:(GCNumberWithUnit*)nu;
-(NSArray<GCField*>*)validStoredSummaryFields;

-(double)summaryFieldValueInStoreUnit:(gcFieldFlag)fieldFlag;
-(void)setSummaryField:(gcFieldFlag)fieldFlag inStoreUnitValue:(double)value;
-(nullable GCNumberWithUnit*)numberWithUnitForFieldInStoreUnit:(GCField *)field;

-(BOOL)hasField:(GCField*)field;
-(BOOL)isEqualToActivity:(GCActivity*)other;

/**
 Returns all available summary fields as GCField. Includes calculated fields.
 */
-(NSArray<GCField*>*)allFields;

-(nullable GCActivityMetaValue*)metaValueForField:(NSString*)field;
/**
 @brief method to update the dictionary of meta data
 */
-(void)updateMetaData:(NSDictionary<NSString*,GCActivityMetaValue*>*)meta;
/**
 @brief method to update the dictionary of summary data
 */
-(void)updateSummaryData:(NSDictionary<GCField*,GCActivitySummaryValue*>*)summary;

-(BOOL)isCompleted:(gcServicePhase)phase for:(gcService)service;
-(BOOL)markCompleted:(gcServicePhase)phase for:(gcService)service;

/**
 @brief Add a dictionary of metavalue entries
 */
-(void)addEntriesToMetaData:(NSDictionary<NSString*,GCActivityMetaValue*> *)dict;
-(void)addEntriesToCalculatedFields:(NSDictionary<GCField*,GCActivityCalculatedValue*> *)dict;

#pragma mark - Laps

-(nullable NSArray<GCLap*>*)laps;
-(NSUInteger)lapCount;
-(nullable GCLap*)lapNumber:(NSUInteger)idx;
-(void)registerLaps:(NSArray<GCLap*>*)laps forName:(NSString*)name;
-(BOOL)useLaps:(NSString*)name;
-(void)clearCalculatedLaps;
-(void)focusOnLapIndex:(NSUInteger)lapIndex;//cheat/hint for lapcoumpound with several point in same lap

-(void)purgeCache;
-(BOOL)validCoordinate;

-(BOOL)hasWeather;
-(void)recordWeather:(GCWeather*)dict;

/// Check if the activity is the same as an activityId whether from the origianl service or from another
/// Sync'd service (externalActivityId)
/// @param activityId THe activity id to check, can be from a sync'd service
-(BOOL)isSameAsActivityId:(NSString*)activityId;
/**
 Test wether should be ignored for stats based on the mode
 */
-(BOOL)ignoreForStats:(gcIgnoreMode)mode;
-(BOOL)isSkiActivity;

@end

NS_ASSUME_NONNULL_END
