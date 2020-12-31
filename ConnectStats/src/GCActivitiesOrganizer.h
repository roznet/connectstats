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

NS_ASSUME_NONNULL_BEGIN

extern NSString * kNotifyOrganizerLoadComplete;
extern NSString * kNotifyOrganizerListChanged;
extern NSString * kNotifyOrganizerReset;

typedef BOOL (^gcActivityOrganizerMatchBlock)(GCActivity*);

@class GCWeather;
@class GCHealthOrganizer;
@class GCService;

@interface GCActivitiesOrganizer : RZParentObject<GCWebReverseGeocodeDelegate,RZChildObject>

@property (nonatomic,retain) FMDatabase * db;
/// set this with an array of activityId to delete and call deleteActivitiesInTrash
@property (nonatomic,retain,nullable) NSArray<NSString*> * activitiesTrash;

@property (nonatomic,assign) BOOL hasCompareActivity;
@property (nonatomic,assign) NSUInteger currentActivityIndex;
@property (nonatomic,assign) NSUInteger selectedCompareActivityIndex;
@property (nonatomic,retain,nullable) NSString * lastSearchString;
@property (nonatomic,retain,nullable) NSString * filteredActivityType;
@property (nonatomic,retain) GCHealthOrganizer * health;
@property (nonatomic,readonly,nullable) CLLocation * currentActivityLocation;

-(GCActivitiesOrganizer*)initWithDb:(FMDatabase*)aDb;
-(GCActivitiesOrganizer*)initWithDb:(FMDatabase*)aDb andThread:(nullable dispatch_queue_t)thread NS_DESIGNATED_INITIALIZER;
-(GCActivitiesOrganizer*)initTestModeWithDb:(FMDatabase*)aDb NS_DESIGNATED_INITIALIZER;

-(BOOL)registerActivity:(GCActivity*)act forActivityId:(NSString*)aId;
-(void)registerTemporaryActivity:(GCActivity*)act forActivityId:(NSString*)aId;

-(void)registerActivityTypes:(NSDictionary*)aData;

-(void)registerActivity:(NSString*)aId withTrackpoints:(nullable NSArray*)aTrack andLaps:(nullable NSArray*)laps;
-(void)registerActivity:(NSString*)aId withWeather:(nullable GCWeather *)aData;

-(NSUInteger)countOfKnownDuplicates;
-(nullable GCActivity*)findDuplicate:(GCActivity*)act;
-(BOOL)isKnownDuplicate:(GCActivity*)act;
-(nullable NSString*)hasKnownDuplicate:(GCActivity*)act;

-(NSUInteger)countOfActivities;
-(NSArray<GCActivity*>*)activities;
-(NSArray<GCActivity*>*)activitiesWithin:(NSTimeInterval)time of:(NSDate*)date;
-(NSArray<GCActivity*>*)activitiesMatching:(gcActivityOrganizerMatchBlock)match withLimit:(NSUInteger)limit;
-(BOOL)loadCompleted;


-(void)setActivities:(NSArray*)activities;
-(nullable GCActivity*)activityForId:(NSString*)aId;
-(nullable GCActivity*)activityForIndex:(NSUInteger)idx;
-(NSArray<GCActivity*>*)activitiesFromDate:(NSDate*)aFrom to:(NSDate*)aTo;
-(nullable GCActivity*)currentActivity;
-(nullable GCActivity*)lastActivity;
-(nullable GCActivity*)oldestActivity;
/**
 * Return summary of activities for each service.
 * @return dictionary with key GCService.displayName to { @"earliest", @"latest", @"count" }
 */
-(NSDictionary*)serviceSummary;
/**
 * Return summary of activities for each service, similar to serviceSummary but also report missing tracks
 * @return dictionary with key GCService.displayName to { @"earliest", @"latest", @"count" }
 */
-(NSDictionary*)serviceSummaryMissingTracks;
/**
 Return activity compare if selected and valid (same type/but not the same) as given activity or nil
 */
-(nullable GCActivity*)validCompareActivityFor:(GCActivity*)activity;
/**
 return currently selected compare activity or nil if none selected
 */
-(nullable GCActivity*)compareActivity;
-(void)setCurrentActivityId:(NSString*)aId;
-(NSArray<NSString*>*)listActivityTypes;
-(nullable NSString*)lastGarminLoginUsername;

/**
 Find list of activities not in provided list.
 The logic will assume the inIds are sorted and will only look for activities
 in between the first object in inIds and the last.
 if isFirst is true, assume the first is already found (head of the list)
 */
-(nullable NSArray<NSString*>*)findActivitiesNotIn:(NSArray<NSString*>*)inIds isFirst:(BOOL)isFirst;
-(nullable NSArray<NSNumber*>*)activityIndexesMatchingString:(NSString*)str;

-(BOOL)isQuickFilterApplicable;
-(void)filterForSearchString:(nullable NSString*)str;
// Force refresh if something changed, for example location
-(void)filterForLastSearchString;
-(void)filterForQuickFilter;
-(void)clearFilter;
-(BOOL)hasFilter;

-(NSUInteger)countOfFilteredActivities;
-(nullable GCActivity*)filteredActivityForIndex:(NSUInteger)idx;
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
-(NSDictionary*)fieldsSeries:(NSArray*)fields matching:(nullable GCActivityMatchBlock)match useFiltered:(BOOL)useFilter ignoreMode:(gcIgnoreMode)ignoreMode;
-(nullable GCStatsDataSerieFilter*)standardFilterForField:(GCField*)field;

-(void)purgeCache;
-(void)deleteActivityId:(NSString*)aId;
-(void)deleteActivitiesInTrash;
-(void)deleteAllActivities;
-(void)deleteActivityUpToIndex:(NSUInteger)idx;
-(void)deleteActivityFromIndex:(NSUInteger)idx;
-(void)deleteActivityAtIndex:(NSUInteger)idx;

-(void)recordSynchronized:(GCActivity*)act forService:(NSString*)service;
-(BOOL)isSynchronized:(GCActivity*)act forService:(NSString*)service;
-(nullable GCActivity*)mostRecentActivityFromService:(GCService*)service;

+(void)ensureDbStructure:(FMDatabase*)aDb;
-(void)updateForNewProfile;

+(void)sanityCheckDb:(FMDatabase*)aDb;

-(void)notifyOnMainThread:(nullable NSString*)stringOrNil;
@end

NS_ASSUME_NONNULL_END
