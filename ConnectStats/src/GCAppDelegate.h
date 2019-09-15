//  MIT Licence
//
//  Created on 02/09/2012.
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

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GCTabBarController.h"
#import "GCActivitiesOrganizer.h"
#import "GCWebConnect.h"
#import "GCAppProfiles.h"
#import "GCSplitViewController.h"
#import "GCHealthOrganizer.h"
#import "GCDerivedOrganizer.h"
#import "GCWatchSessionManager.h"
#import "GCAppActionDelegate.h"
#import "GCActivityTypes.h"

@class GCSegmentOrganizer;

@interface GCAppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) GCTabBarController * tabBarController;
@property (nonatomic, retain) GCSplitViewController * splitViewController;
@property (nonatomic, retain) GCActivitiesOrganizer * organizer;
@property (nonatomic, retain) FMDatabase * db;
@property (nonatomic, retain) NSMutableDictionary * settings;
@property (nonatomic, retain) GCWebConnect * web;
@property (nonatomic, retain) dispatch_queue_t worker;
@property (nonatomic, retain) GCAppProfiles * profiles;
@property (nonatomic, retain) GCHealthOrganizer * health;
@property (nonatomic, retain) GCDerivedOrganizer * derived;
@property (nonatomic, retain) GCWatchSessionManager * watch;
@property (nonatomic, retain) GCSegmentOrganizer * segments;
@property (nonatomic, retain) GCActivityTypes * activityTypes;
@property (nonatomic,retain) NSURL * urlToOpen;


-(void)saveSettings;
-(void)addOrSelectProfile:(NSString*)pName;
+(void)publishEvent:(NSString*)name;
+(BOOL)trialVersion;
+(BOOL)connectStatsVersion;
+(BOOL)healthStatsVersion;

-(void)startSuccessful;

-(void)startupRefreshIfNeeded;
-(void)searchAllActivities;

-(NSObject<GCAppActionDelegate>*)actionDelegate;
-(BOOL)handleUniveralLink:(NSURL *) url;
-(void)setupFieldCache;

-(NSDictionary<NSString*,NSString*>*)credentialsForService:(NSString*)service;
-(NSString*)credentialsForService:(NSString*)service andKey:(NSString*)key;


@end
