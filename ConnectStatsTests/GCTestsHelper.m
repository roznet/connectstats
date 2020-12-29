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
#import "GCFields.h"
#import "GCFieldCache.h"

@interface GCTestsHelper ()
@property (nonatomic,retain) NSMutableDictionary * savedSettings;
@property (nonatomic,retain) NSTimeZone * rememberTimeZone;
@property (nonatomic,retain) GCFieldCache * fieldCache;
@property (nonatomic,retain) GCHealthOrganizer * rememberHealth;

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
    self.rememberHealth = app.health;
    app.health = RZReturnAutorelease([[GCHealthOrganizer alloc] initForTest]);
    
    if( self.rememberTimeZone == nil){
        self.rememberTimeZone = [NSTimeZone defaultTimeZone];
    }
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Europe/London"]];
    [GCAppGlobal ensureCalculationCalendarTimeZone:[NSTimeZone defaultTimeZone]];
    [GCUnit setGlobalSystem:gcUnitSystemMetric];
    self.fieldCache = [GCField fieldCache];
    [RZFileOrganizer removeEditableFile:@"field_cache.db"];
    FMDatabase * cacheDb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:@"field_cache.db"]];
    [cacheDb open];
    GCFieldCache * cache = [GCFieldCache cacheWithDb:cacheDb andLanguage:@"en"];
    [GCField setFieldCache: cache];
    [GCFields setFieldCache:cache];
    [GCActivityType setFieldCache:cache];
    
}

-(void)tearDown{
    GCAppDelegate * app = (GCAppDelegate*)[UIApplication sharedApplication].delegate;
    if(self.savedSettings){
        app.settings = self.savedSettings;
        app.profiles = [GCAppProfiles profilesFromSettings:app.settings];
        self.savedSettings = nil;
    }
    if(self.rememberTimeZone){
        [NSTimeZone setDefaultTimeZone:self.rememberTimeZone];
        [GCAppGlobal ensureCalculationCalendarTimeZone:self.rememberTimeZone];
        self.rememberTimeZone = nil;
    }
    if( self.rememberHealth ){
        app.health = self.rememberHealth;
    }
    [GCField setFieldCache:self.fieldCache];
    [GCFields setFieldCache:self.fieldCache];
    [GCActivityType setFieldCache:self.fieldCache];
}

-(void)dealloc{
    [self tearDown];
    
    [_rememberTimeZone release];
    [_savedSettings release];
    [super dealloc];
}
@end
