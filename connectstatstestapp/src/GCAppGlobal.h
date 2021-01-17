//  MIT Licence
//
//  Created on 15/09/2012.
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
#import "GCActivitiesOrganizer.h"
#import "GCWebConnect.h"
#import "GCAppProfiles.h"
#import "GCAppConstants.h"
#import "GCHealthOrganizer.h"
#import "GCDerivedOrganizer.h"
#import "GCWebUrl.h"

extern NSString *const kNotifySettingsChange;
extern NSString * kPreservedSettingsName;

@class GCAppDelegate;

@interface GCAppGlobal : RZAppConfig

+(GCActivitiesOrganizer*)organizer;
+(FMDatabase*)db;
+(NSMutableDictionary*)settings;
+(GCWebConnect*)web;
+(dispatch_queue_t)worker;
+(void)selectTab:(int)aTab;
+(GCAppProfiles*)profile;
+(GCHealthOrganizer*)health;
+(GCDerivedOrganizer*)derived;

+(void)saveSettings;
+(BOOL)connectStatsVersion;

+(NSDictionary*)debugState;
+(void)debugStateRecord:(NSDictionary*)dict;

+(NSCalendar*)calculationCalendar;
+(NSDate*)referenceDate DEPRECATED_MSG_ATTRIBUTE("Use Calendar Config");
+(NSInteger)currentYear;
+(UINavigationController*)currentNavigationController;

+(BOOL)healthStatsVersion;

+(void)setApplicationDelegate:(GCAppDelegate*)del;
+(NSString*)simulatorUrl;
+(NSString*)credentialsForService:(NSString*)service andKey:(NSString*)key;

+(gcWebConnectStatsConfig)webConnectsStatsConfig;

+(UIUserInterfaceStyle)userInterfaceStyle;

// Global override for forcing testing of dark/light mode
+(void)setUserInterfaceStyle:(UIUserInterfaceStyle)newStyle;
+(NSString*)appURLScheme;
+(void)versionSummary;
@end
