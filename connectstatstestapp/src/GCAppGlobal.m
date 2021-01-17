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

static UIUserInterfaceStyle _cacheUserInterfaceStyle = UIUserInterfaceStyleUnspecified;

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
+(NSInteger)currentYear{
    static NSInteger currentYear = 0;
    if( currentYear == 0){
        currentYear = [[GCAppGlobal calculationCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]];
    }
    return currentYear;
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


+(NSString*)credentialsForService:(NSString*)service andKey:(NSString*)key{
    return [[GCAppGlobal appDelegate]  credentialsForService:service andKey:key];
}

+(void)saveSettings{

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
+(gcWebConnectStatsConfig)webConnectsStatsConfig{
    gcWebConnectStatsConfig config = [[self profile] configGetInt:CONFIG_CONNECTSTATS_CONFIG defaultValue:gcWebConnectStatsConfigProductionConnectStatsApp];
    return config;
}

+(UIUserInterfaceStyle)userInterfaceStyle{
    if( _cacheUserInterfaceStyle == UIUserInterfaceStyleUnspecified ){
        _cacheUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
    }
    return _cacheUserInterfaceStyle;
}

+(void)setUserInterfaceStyle:(UIUserInterfaceStyle)newStyle{
    _cacheUserInterfaceStyle = newStyle;
}

+(NSString*)appURLScheme{
    return @"connectstatstestapp";
}
+(void)versionSummary{
    RZLog(RZLogInfo,@"Version Summary would go here - this is a test version");
}
@end
