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
#import <CoreLocation/CoreLocation.h>
#import "GCWebConnect.h"
#import "GCAppConstants.h"
#import "GCActivitiesOrganizer.h"
#import "GCAppProfiles.h"
#import "GCHealthOrganizer.h"
#import "GCDerivedOrganizer.h"

extern NSString *const kNotifySettingsChange;

@class GCActivitiesOrganizer;
@class GCAppDelegate;
@class GCActivity;
@class HKHealthStore;
@class GCSegmentOrganizer;
@class GCAppProfiles;
@class GCHealthOrganizer;
@class GCDerivedOrganizer;
@class GCActivityTypes;

@interface GCAppGlobal : RZAppConfig

// Access State
+(GCActivitiesOrganizer*)organizer;
+(GCHealthOrganizer*)health;
+(FMDatabase*)db;
+(NSMutableDictionary*)settings;
+(GCWebConnect*)web;
+(dispatch_queue_t)worker;
+(GCAppProfiles*)profile;
+(GCDerivedOrganizer*)derived;
+(GCSegmentOrganizer*)segments;
+(GCActivityTypes*)activityTypes;

// Actions
+(void)focusOnActivityAtIndex:(NSUInteger)idx;
+(void)focusOnActivityId:(NSString*)aId;
+(void)focusOnStatsSummary;
+(void)focusOnActivityList;
+(void)focusOnListWithFilter:(NSString*)aFilter;
+(void)saveSettings;

+(void)addOrSelectProfile:(NSString*)pName;
+(void)startSuccessful;

+(void)login;
+(void)logout;
+(void)beginRefreshing;
+(void)searchAllActivities;
+(void)startupRefreshIfNeeded;
+(void)setupFieldCache;

+(UINavigationController*)currentNavigationController;

+(NSCalendar*)calculationCalendar;
+(void)ensureCalculationCalendarTimeZone:(NSTimeZone*)tz;// Mostly used for testing
+(NSDate*)referenceDate;

+(BOOL)connectStatsVersion;
+(BOOL)healthStatsVersion;
+(BOOL)trialVersion;

+(HKHealthStore*)healthKitStore;

+(NSDictionary*)debugState;
+(void)debugStateRecord:(NSDictionary*)dict;
+(void)debugStateClear;

+(void)setApplicationDelegate:(GCAppDelegate*)del;
+(NSString*)simulatorUrl;

+(NSString*)credentialsForService:(NSString*)service andKey:(NSString*)key;
@end
