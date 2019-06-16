//  MIT Licence
//
//  Created on 08/09/2012.
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
#import "GCWebReverseGeocode.h"
#import "GCFieldsCalculated.h"
#import "GCActivityTypes.h"

extern NSString * kNotifyOrganizerLoadComplete;
extern NSString * kNotifyOrganizerListChanged;
extern NSString * kNotifyOrganizerReset;

typedef BOOL (^gcActivityOrganizerMatchBlock)(GCActivity*);

@class GCWeather;
@class GCHealthOrganizer;

@interface GCActivitiesOrganizer : RZParentObject<GCWebReverseGeocodeDelegate,RZChildObject>

@property (nonatomic,retain) FMDatabase * db;
/// set this with an array of activityId to delete and call deleteActivitiesInTrash
@property (nonatomic,retain) NSArray<NSString*> * activitiesTrash;

@property (nonatomic,assign) BOOL hasCompareActivity;
@property (nonatomic,assign) NSUInteger currentActivityIndex;
@property (nonatomic,assign) NSUInteger selectedCompareActivityIndex;
@property (nonatomic,retain) NSString * lastSearchString;
@property (nonatomic,retain) NSString * filteredActivityType;
@property (nonatomic,retain) GCHealthOrganizer * health;

-(GCActivitiesOrganizer*)init;
-(GCActivitiesOrganizer*)initWithDb:(FMDatabase*)aDb;
-(GCActivitiesOrganizer*)initWithDb:(FMDatabase*)aDb andThread:(dispatch_queue_t)thread NS_DESIGNATED_INITIALIZER;
-(GCActivitiesOrganizer*)initTestModeWithDb:(FMDatabase*)aDb NS_DESIGNATED_INITIALIZER;

-(BOOL)registerActivity:(GCActivity*)act forActivityId:(NSString*)aId;
-(void)registerActivity:(NSString*)aId withGarminData:(NSDictionary*)aData;
-(void)registerActivity:(NSString*)aId withStravaData:(NSDictionary*)aData;
-(void)registerTemporaryActivity:(GCActivity*)act forActivityId:(NSString*)aId;

-(void)reloadActivity:(NSString*)aId withGarminData:(NSDictionary*)aData;
-(void)registerActivityTypes:(NSDictionary*)aData;

-(void)registerActivity:(NSString*)aId withTrackpoints:(NSArray*)aTrack andLaps:(NSArray*)laps;
-(void)registerActivity:(NSString*)aId withTrackpointsSwim:(NSArray<GCTrackPointSwim*>*)aTrack andLaps:(NSArray<GCLapSwim*>*)laps;
-(void)registerActivity:(NSString *)aId withWeather:(GCWeather *)aData;

-(void)registerTennisActivity:(NSString *)aId withBabolatData:(NSDictionary *)aData;
-(void)registerTennisActivity:(NSString *)aId withFullSession:(NSDictionary *)aData;



-(GCActivity*)findDuplicate:(GCActivity*)act;
-(BOOL)isKnownDuplicate:(GCActivity*)act;

-(NSUInteger)countOfActivities;
-(NSArray<GCActivity*>*)activities;
-(NSArray<GCActivity*>*)activitiesWithin:(NSTimeInterval)time of:(NSDate*)date;
-(NSArray<GCActivity*>*)activitiesMatching:(gcActivityOrganizerMatchBlock)match withLimit:(NSUInteger)limit;
-(BOOL)loadCompleted;


-(void)setActivities:(NSArray*)activities;
-(GCActivity*)activityForId:(NSString*)aId;
-(GCActivity*)activityForIndex:(NSUInteger)idx;
-(NSArray<GCActivity*>*)activitiesFromDate:(NSDate*)aFrom to:(NSDate*)aTo;
-(GCActivity*)currentActivity;
-(GCActivity*)lastActivity;
-(GCActivity*)oldestActivity;
/**
 Return activity compare if selected and valid (same type/but not the same) as given activity or nil
 */
-(GCActivity*)validCompareActivityFor:(GCActivity*)activity;
/**
 return currently selected compare activity or nil if none selected
 */
-(GCActivity*)compareActivity;
-(void)setCurrentActivityId:(NSString*)aId;
-(NSArray*)listActivityTypes;
-(NSString*)lastGarminLoginUsername;

/**
 Find list of activities not in provided list.
 The logic will assume the inIds are sorted and will only look for activities
 in between the first object in inIds and the last.
 if isFirst is true, assume the first is already found (head of the list)
 */
-(NSArray*)findActivitiesNotIn:(NSArray<NSString*>*)inIds isFirst:(BOOL)isFirst;
-(NSArray*)activityIndexesMatchingString:(NSString*)str;

-(BOOL)isQuickFilterApplicable;
-(void)filterForSearchString:(NSString*)str;
-(void)filterForQuickFilter;
-(void)clearFilter;
-(BOOL)hasFilter;

-(FMDatabase*)tennisdb;

-(NSUInteger)countOfFilteredActivities;
-(GCActivity*)filteredActivityForIndex:(NSUInteger)idx;
-(NSUInteger)activityIndexForFilteredIndex:(NSUInteger)idx;
-(NSUInteger)filteredIndexForActivityIndex:(NSUInteger)idx;
-(NSArray<GCActivity*>*)filteredActivities;


-(void)calculateField:(GCFieldsCalculated*)field for:(NSArray*)activities;
-(void)calculateAllFieldsForActivity:(GCActivity*)act;
/**
 Return series with unit for the fields requested
 @param fields Can be an array of NSString fieldKeys or GCField fields
 @param  match can be nil or a block returning true for the activities to consider
 @param  useFilter if true use filteredActivities if false will always use all activities
 @param  ignoreMode decide whether to apply on fitness or days activities
 @return NSDictionary with Keys for the values in fields (NSString or GCField) and GCStatsDataSerieWithUnit as value
 */
-(NSDictionary*)fieldsSeries:(NSArray*)fields matching:(GCActivityMatchBlock)match useFiltered:(BOOL)useFilter ignoreMode:(gcIgnoreMode)ignoreMode;
-(GCStatsDataSerieFilter*)standardFilterForField:(GCField*)field;

-(void)purgeCache;
-(void)deleteActivityId:(NSString*)aId;
-(void)deleteActivitiesInTrash;
-(void)deleteAllActivities;
-(void)deleteActivityUpToIndex:(NSUInteger)idx;
-(void)deleteActivityFromIndex:(NSUInteger)idx;
-(void)deleteActivityAtIndex:(NSUInteger)idx;

-(void)recordSynchronized:(GCActivity*)act forService:(NSString*)service;
-(BOOL)isSynchronized:(GCActivity*)act forService:(NSString*)service;

+(void)ensureDbStructure:(FMDatabase*)aDb;
-(void)updateForNewProfile;

+(void)sanityCheckDb:(FMDatabase*)aDb;

-(void)notifyOnMainThread:(NSString*)stringOrNil;
@end
