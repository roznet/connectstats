//
//  GCTestsHelper.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 15/10/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import "GCTestsHelper.h"
#import "GCAppDelegate.h"
#import "GCAppGlobal.h"

@interface GCTestsHelper ()
@property (nonatomic,retain) NSMutableDictionary * savedSettings;
@property (nonatomic,retain) NSTimeZone * rememberTimeZone;
@end

@implementation GCTestsHelper

+(GCTestsHelper*)helper{
    GCTestsHelper * rv = [[[GCTestsHelper alloc] init] autorelease];
    if (rv) {
        [rv setUp];
    }
    return rv;
}

-(void)setUp{
    GCAppDelegate * app = (GCAppDelegate*)[UIApplication sharedApplication].delegate;
    
    static BOOL started = false;
    if (!started) {
        [app startSuccessful];
        started = true;
    }

    if(!self.savedSettings){
        self.savedSettings = app.settings;
    }
    app.settings = [NSMutableDictionary dictionary];
    app.profiles = [GCAppProfiles profilesFromSettings:app.settings];

    if( self.rememberTimeZone == nil){
        self.rememberTimeZone = [NSTimeZone defaultTimeZone];
    }
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];
    [GCAppGlobal ensureCalculationCalendarTimeZone:[NSTimeZone defaultTimeZone]];
}

-(void)tearDown{
    if(self.savedSettings){
        GCAppDelegate * app = (GCAppDelegate*)[UIApplication sharedApplication].delegate;
        app.settings = self.savedSettings;
        app.profiles = [GCAppProfiles profilesFromSettings:app.settings];
        self.savedSettings = nil;
    }
    if(self.rememberTimeZone){
        [NSTimeZone setDefaultTimeZone:self.rememberTimeZone];
        [GCAppGlobal ensureCalculationCalendarTimeZone:self.rememberTimeZone];
        self.rememberTimeZone = nil;
    }
}
-(void)dealloc{
    [self tearDown];
    
    [_rememberTimeZone release];
    [_savedSettings release];
    [super dealloc];
}
@end
