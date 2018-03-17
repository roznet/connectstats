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

#import "GCAppGlobal.h"
#import "GCAppDelegate.h"

static NSCalendar * _cacheCalendar = nil;
static NSDictionary * _debugState = nil;
NSString *const kNotifySettingsChange = @"kNotifySettingsChange";
NSString * kPreservedSettingsName = @"test_services_settings.plist";

static GCAppDelegate * _cacheApplicationDelegate = nil;

NS_INLINE GCAppDelegate * _sharedApplicationDelegate(void){
    if( _cacheApplicationDelegate == nil){
        _cacheApplicationDelegate = (GCAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _cacheApplicationDelegate;
}


@implementation GCAppGlobal
+(void)setApplicationDelegate:(GCAppDelegate*)del{
    _cacheApplicationDelegate = del;
}

+(BOOL)trialVersion{
    return false;
}
+(BOOL)fullVersion{
    return true;
}

+(NSDictionary*)debugState{
    if (!_debugState) {
        _debugState = @{};
        [_debugState retain];
    }
    return _debugState;
}
+(void)debugStateClear{
    [_debugState release];
    _debugState = nil;
}
+(void)debugStateRecord:(NSDictionary*)dict{
    if (!_debugState) {
        _debugState = dict;
        [_debugState retain];
    }else{
        NSDictionary * newDict = [_debugState dictionaryByAddingEntriesFromDictionary:dict];
        [_debugState release];
        _debugState = newDict;
        [_debugState retain];
    }
}
+(NSCalendar*)calculationCalendar{
    if (_cacheCalendar == nil) {
        _cacheCalendar = [[NSCalendar currentCalendar] retain];
        _cacheCalendar.timeZone = [NSTimeZone timeZoneWithName:@"Europe/London"];
    }
    //
    [_cacheCalendar setFirstWeekday:1];

    return _cacheCalendar;
}

+(GCAppDelegate*)appDelegate{
    GCAppDelegate * app = _sharedApplicationDelegate();
    return app;
}

+(GCHealthOrganizer*)health{
    return [[GCAppGlobal appDelegate] health];
}
+(GCDerivedOrganizer*)derived{
    return [[GCAppGlobal appDelegate] derived];
}

+(GCActivitiesOrganizer*)organizer{
    return [[GCAppGlobal appDelegate] organizer];
}
+(FMDatabase*)db{
    return [[GCAppGlobal appDelegate] db];
}
+(NSMutableDictionary*)settings{
    return [[GCAppGlobal appDelegate] settings];
}

+(GCWebConnect*)web{
    return [[GCAppGlobal appDelegate] web];

}

+(GCAppProfiles*)profile{
    return [[GCAppGlobal appDelegate] profile];
}
+(void)selectTab:(int)aTab{
    // ignore
}
+(NSDate*)referenceDate{
    return nil;
}

+(void)setupEmptyState:(NSString*)name withSettingsName:(NSString*)settingName{
    [[GCAppGlobal appDelegate] setupEmptyState:(NSString*)name withSettingsName:settingName];
}
+(void)setupEmptyState:(NSString*)name{
    [[GCAppGlobal appDelegate] setupEmptyState:(NSString*)name];

}
+(void)setupEmptyStateWithDerived:(NSString*)name{
    [[GCAppGlobal appDelegate] setupEmptyStateWithDerived:(NSString*)name];
}

+(void)setupSampleState:(NSString*)name{
    [[GCAppGlobal appDelegate] setupSampleState:(NSString*)name];
}
+(void)setupSampleState:(NSString*)name config:(NSDictionary *)config{
    [[GCAppGlobal appDelegate] setupSampleState:(NSString*)name config:config];
}

+(void)reinitFromSampleState:(NSString*)name{
    [[GCAppGlobal appDelegate] reinitFromSampleState:name];
}
+(void)cleanWritableFiles{
    [[GCAppGlobal appDelegate] cleanWritableFiles];
}

+(void)saveSettings{

}
+(GCActivityTypes*)activityTypes{
    GCAppDelegate *appDelegate = _sharedApplicationDelegate();
    return appDelegate.activityTypes;
}

+(dispatch_queue_t)worker{
    return [[GCAppGlobal appDelegate] worker];
}

+(UINavigationController*)currentNavigationController{
    GCAppDelegate *appDelegate = _sharedApplicationDelegate();
    return [appDelegate currentNavigationController];
}

+(BOOL)healthStatsVersion{
    return false;
}
+(BOOL)connectStatsVersion{
    return true;
}
+(NSString*)simulatorUrl{
    return [_sharedApplicationDelegate() simulatorUrl];
}

@end
