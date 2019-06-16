//  MIT Licence
//
//  Created on 13/09/2012.
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
#import "GCTestViewController.h"
#import "GCWebConnect.h"
#import "GCActivitiesOrganizer.h"
#import "GCTestUIGraphViewController.h"
#import "GCTestUICellsViewController.h"
#import "GCAppProfiles.h"
#import "GCHealthOrganizer.h"
#import "GCDerivedOrganizer.h"
#import "GCTestServicesViewController.h"


@interface GCAppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) GCTestViewController * testViewController;
@property (retain, nonatomic) GCTestUIGraphViewController * testUIGraphViewController;
@property (retain, nonatomic) GCTestUICellsViewController * testUICellViewController;
@property (nonatomic, retain) GCTestServicesViewController * testServicesViewController;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) GCActivitiesOrganizer * organizer;
@property (nonatomic, retain) FMDatabase * db;
@property (nonatomic, retain) NSMutableDictionary * settings;
@property (nonatomic, retain) GCWebConnect * web;
@property (nonatomic, retain) dispatch_queue_t worker;
@property (nonatomic, retain) GCAppProfiles * profile;
@property (nonatomic, retain) GCHealthOrganizer * health;
@property (nonatomic, retain) GCDerivedOrganizer * derived;
@property (nonatomic, retain) GCActivityTypes * activityTypes;

-(void)setupEmptyState:(NSString*)name withSettingsName:(NSString*)settingName;
-(void)setupEmptyState:(NSString*)name;
-(void)setupEmptyStateWithDerived:(NSString*)name;
-(void)setupSampleState:(NSString*)name config:(NSDictionary*)config;
-(void)setupSampleState:(NSString*)name;
-(void)reinitFromSampleState:(NSString*)name;

-(void)cleanWritableFiles;

-(NSString*)simulatorUrl;

-(UINavigationController*)currentNavigationController;

-(NSDictionary<NSString*,NSString*>*)credentialsForService:(NSString*)service;
-(NSString*)credentialsForService:(NSString*)service andKey:(NSString*)key;


@end
