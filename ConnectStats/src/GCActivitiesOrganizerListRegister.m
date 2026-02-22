//  MIT Licence
//
//  Created on 04/10/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCActivitiesOrganizerListRegister.h"
#import "GCActivitiesOrganizer.h"
#import "GCService.h"
#import "GCAppGlobal.h"

NSUInteger kDownloadTrackPointCount = 5;

@interface GCActivitiesOrganizerListRegister ()
@property (nonatomic,retain) NSArray<GCActivity*>*activities;
@property (nonatomic,assign) NSUInteger reachedExisting;
@property (nonatomic,retain) NSArray<NSString*>*childIds;
@property (nonatomic,retain) GCService * service;
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) BOOL syncDeleteWithPreferred;
@property (nonatomic,retain) NSArray<GCActivity*>*addedActivities;

@end

@implementation GCActivitiesOrganizerListRegister

-(instancetype)initFor:(NSArray<GCActivity*>*)activities from:(GCService*)service isFirst:(BOOL)isFirst{
    self = [super init];
    if( self ){
        self.activities = activities;
        self.service = service;
        self.isFirst = isFirst;
        self.syncDeleteWithPreferred = [[GCAppGlobal profile] configGetBool:CONFIG_SYNC_WITH_PREFERRED defaultValue:true];
        self.loadTracks = isFirst?kDownloadTrackPointCount:0;
    }
    return self;
}
+(instancetype)activitiesOrganizerListRegister:(NSArray<GCActivity*>*)activities from:(GCService*)service isFirst:(BOOL)isFirst{
    return RZReturnAutorelease([[GCActivitiesOrganizerListRegister alloc] initFor:activities from:service isFirst:isFirst]);
}

-(void)dealloc{
    [_activities release];
    [_childIds release];
    [_service release];
    [_addedActivities release];

    [super dealloc];
}

-(void)identifyActivitiesToAddTo:(GCActivitiesOrganizer*)organizer{
    NSMutableArray * existingInService = [NSMutableArray array];
    NSMutableArray * newActivities = nil;
    self.addedActivities = nil;
    
    self.reachedExisting = 0;
    
    if (self.activities) {
        for (GCActivity * activity in self.activities) {
            [existingInService addObject:activity.activityId];
            BOOL knownDuplicate = [organizer isKnownDuplicate:activity];
            BOOL foundInOrganizer = [organizer containsActivityId:activity.activityId] || knownDuplicate;
            if (foundInOrganizer || knownDuplicate) {
                _reachedExisting++;
            }else{
                if( newActivities == nil){
                    newActivities = [NSMutableArray array];
                    self.addedActivities = newActivities;
                }
                [newActivities addObject:activity];
            }
        }
        RZLog(RZLogInfo,@"Hello");
        if( self.activities.count > 0){
            RZLog(RZLogInfo, @"Identified %@ [%@-%@]=%lu new=%lu existing=%lu", self.service.displayName, [self.activities.firstObject activityId], [self.activities.lastObject activityId],
                  (unsigned long)self.activities.count,(unsigned long)newActivities.count,(unsigned long)self.reachedExisting);
        }else{
            RZLog(RZLogInfo, @"Idenfitied %@ [empty]", self.service.displayName);            
        }
    }
}

-(void)addToOrganizer:(GCActivitiesOrganizer*)organizer{
    NSMutableArray * existingInService = [NSMutableArray array];

    NSMutableArray * newActivities = nil;
    // reset record of new activities;
    self.addedActivities = nil;
    
    // Find childIds not in organizer yet
    NSMutableDictionary * childIds = [NSMutableDictionary dictionary];

    for (GCActivity * one in _activities) {
        if( one.childIds.count > 0){
            for (NSString * childId in one.childIds) {
                [existingInService addObject:childId];
                BOOL foundInOrganizer = [organizer activityForId:childId] != nil;
                if(!foundInOrganizer){
                    childIds[childId] = one.activityId;
                }
            }
        }else if( [one.activityType isEqualToString:GC_TYPE_MULTISPORT]){
            // If it's a multispot and there are no childIds, then force load detail
            // for that activity
            childIds[one.activityId] = one.activityId;
        }
    }
    self.childIds = childIds.count > 0 ? childIds.allKeys : nil;

    _reachedExisting = 0;
    NSUInteger newActivitiesCount = 0;
    NSUInteger actuallyAdded = 0;
    NSUInteger skipped = 0;
    NSUInteger trackpoints = 0;
    if (self.activities) {
        for (GCActivity * activity in _activities) {
            [existingInService addObject:activity.activityId];
            BOOL knownDuplicate = [organizer isKnownDuplicate:activity];
            BOOL foundInOrganizer = [organizer activityForId:activity.activityId] != nil || knownDuplicate;
            if (foundInOrganizer || knownDuplicate) {
                _reachedExisting++;
            }else{
                newActivitiesCount++;
            }
            if( !self.updateNewOnly || !foundInOrganizer){
                if( [organizer registerActivity:activity forActivityId:activity.activityId] ){
                    if( newActivities == nil){
                        newActivities = [NSMutableArray array];
                        self.addedActivities = newActivities;
                    }
                    [newActivities addObject:activity];
                    actuallyAdded += 1;
                }else{
                    // If it wasn't register it could be it was a duplicate
                    // But during the first check that wasn't known
                    // so check again to avoid doing track load later
                    knownDuplicate = [organizer isKnownDuplicate:activity];
                    skipped += 1;
                }
                if( self.loadTracks > 0 && ! knownDuplicate){
                    if( activity.trackPointsRequireDownload ){
                        [activity trackpoints];
                        trackpoints+=1;
                        self.loadTracks--;
                    }
                }
            }
        }
        if( self.activities.count > 0){
            RZLog(RZLogInfo, @"Parsed %@ [%@-%@]=%lu new=%lu added=%lu existing=%lu newtotal=%lu details=%lu",
                  self.service.displayName,
                  [self.activities.firstObject activityId],
                  [self.activities.lastObject activityId],
                  (unsigned long)self.activities.count,
                  (unsigned long)newActivitiesCount,
                  (unsigned long)actuallyAdded,
                  (unsigned long)self.reachedExisting,
                  (unsigned long)[organizer countOfActivities],
                  (unsigned long)trackpoints
                  );
        }else{
            RZLog(RZLogInfo, @"Parsed %@ [empty] existing total=%lu",
                  self.service.displayName,
                  (unsigned long)[organizer countOfActivities]
                  );
        }

        if (existingInService.count ) {
            NSArray * deleteCandidate = [organizer findActivitiesNotIn:existingInService isFirst:self.isFirst];

            // don't delete if didn't found last.
            if (deleteCandidate && deleteCandidate.count) {
                NSMutableArray * toTrash = [NSMutableArray arrayWithCapacity:deleteCandidate.count];
                for (NSString * one in deleteCandidate) {
                    // Only delete if it's coming from same service, never delete cross-service activities
                    if ([GCService serviceForActivityId:one].service == self.service.service){
                        [toTrash addObject:one];
                    }else{
                        RZLog(RZLogInfo, @"Skipping delete of cross-service activity: %@ from %@ (syncing %@)", one, [GCService serviceForActivityId:one], self.service);
                    }
                }
                if (toTrash.count>0) {
                    RZLog(RZLogWarning, @"Found %d activities to delete from %@", (int)[toTrash count], self.service.displayName);
                    organizer.activitiesTrash = toTrash;
                    [organizer deleteActivitiesInTrash];
                }
            }
        }
    }
}

-(BOOL)shouldSearchForMoreWith:(NSUInteger)requestCount reloadAll:(BOOL)mode{
    // if we got zero new activities, we can stop
    // Otherwise if we want to reload all or we still found
    // some new activities (not all are existing) we search for more.
    return ( self.activities.count > 0 &&
            (mode || _reachedExisting < requestCount)
             );
}
@end
