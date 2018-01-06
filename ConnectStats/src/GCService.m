//  MIT Licence
//
//  Created on 16/03/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCService.h"
#import "GCAppGlobal.h"

#define GC_SERVICE_GARMIN       @"__garmin__"
#define GC_SERVICE_STRAVA       @"__strava__"
#define GC_SERVICE_BABOLAT      @"__babolat__"
#define GC_SERVICE_WITHINGS     @"__withings__"
#define GC_SERVICE_SPORTTRACKS  @"__sporttracks__"
#define GC_SERVICE_HEALTHKIT    @"__healthkit__"
#define GC_SERVICE_FITBIT       @"__fitbit__"


@interface GCPrivateServiceSyncCache : NSObject
@property (atomic,retain) NSMutableDictionary * cache;
@property (atomic,retain) NSDate * maxDate;
@property (nonatomic,retain) NSString * workingActivityId;
@property (nonatomic,assign) gcService service;

-(NSDate*)lastSync:(NSString*)aId service:(gcService)service;

@end

@implementation GCPrivateServiceSyncCache

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_workingActivityId release];
    [_maxDate release];
    [_cache release];

    [super dealloc];
}
#endif

+(NSString*)serviceKey:(gcService)service{
    switch (service) {
        case gcServiceBabolat:
            return @"babolat";
        case gcServiceGarmin:
            return @"garmin";
        case gcServiceStrava:
            return @"strava";
        case gcServiceWithings:
            return @"withings";
        case gcServiceSportTracks:
            return @"sportTracks";
        case gcServiceHealthKit:
            return @"healthkit";
        case gcServiceFitBit:
            return @"FitBit";
        case gcServiceEnd:
            return @"END";
    }
    return @"";
}


-(NSDate*)lastSync:(NSString*)aId service:(gcService)service{
    if (!self.cache) {
        dispatch_async([GCAppGlobal worker],^(){
            [self readSync];
        });

    }
    if (aId) {
        return (self.cache)[[GCPrivateServiceSyncCache serviceKey:service]][aId];
    }else{
        return self.maxDate;
    }
    return nil;
}

-(void)readSync{
    FMResultSet * res = [[GCAppGlobal db] executeQuery:@"SELECT activityId,date,service FROM gc_activities_sync ORDER BY date DESC LIMIT 100"];
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:100];
    NSDate * readMaxDate = nil;
    while ([res next]) {
        NSString * service = [res stringForColumn:@"service"];
        NSMutableDictionary * serviceDict = dict[service];
        if (serviceDict==nil) {
            serviceDict = [NSMutableDictionary dictionary];
            dict[service] = serviceDict;
        }
        NSDate * recDate = [res dateForColumn:@"date"];
        NSString * aId = [res stringForColumn:@"activityId"];
        if (recDate && aId) {
            serviceDict[aId] = recDate;
        }
        if (recDate) {
            if (readMaxDate==nil) {
                readMaxDate = recDate;
            }else if ([recDate compare:readMaxDate] == NSOrderedDescending){
                readMaxDate = recDate;
            }
        }
    }
    self.maxDate = readMaxDate;
    self.cache = dict;
}

-(void)recordSync{
    if (!self.cache) {
        [self readSync];
    }
    if (self.workingActivityId && ![self lastSync:self.workingActivityId service:self.service]) {
        [[GCAppGlobal db] executeUpdate:@"INSERT INTO gc_activities_sync (activityId,service,date) VALUES (?,?,?)",
         self.workingActivityId, [GCPrivateServiceSyncCache serviceKey:self.service],[NSDate date]];
        NSMutableDictionary * serviceDict = self.cache[ [GCPrivateServiceSyncCache serviceKey:self.service] ];
        if (!serviceDict) {
            serviceDict = [NSMutableDictionary dictionary];
            self.cache[ [GCPrivateServiceSyncCache serviceKey:self.service] ] = serviceDict;
        }
        serviceDict[self.workingActivityId] = [NSDate date];
        self.maxDate = [NSDate date];
    }
    self.workingActivityId = nil;
}
@end

static GCPrivateServiceSyncCache * _activitiesSync = nil;

@interface GCService ()
@property (nonatomic,retain) NSString * prefix;
@property (nonatomic,assign) gcService service;

@end

@implementation GCService

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_prefix release];
    [super dealloc];
}
#endif

+(GCService*)serviceForActivityId:(NSString*)aId{
    GCService * rv = RZReturnAutorelease([[GCService alloc] init]);
    if (rv) {
        if (![aId hasPrefix:@"__"]) {
            rv.service = gcServiceGarmin;
            rv.prefix = GC_SERVICE_GARMIN;
        }else{
            if ([aId hasPrefix:GC_SERVICE_STRAVA]) {
                rv.service = gcServiceStrava;
                rv.prefix = GC_SERVICE_STRAVA;
            }else if ([aId hasPrefix:GC_SERVICE_BABOLAT]){
                rv.service = gcServiceBabolat;
                rv.prefix = GC_SERVICE_BABOLAT;
            }else if ([aId hasPrefix:GC_SERVICE_WITHINGS]){
                rv.service = gcServiceWithings;
                rv.prefix = GC_SERVICE_WITHINGS;
            }else if([aId hasPrefix:GC_SERVICE_HEALTHKIT]){
                rv.service = gcServiceHealthKit;
                rv.prefix = GC_SERVICE_HEALTHKIT;
            }else if([aId hasPrefix:GC_SERVICE_FITBIT]){
                rv.service = gcServiceFitBit;
                rv.prefix = GC_SERVICE_FITBIT;
            }else{
                rv = nil;
            }
        }
    }
    return rv;
}
+(GCService*)service:(gcService)serv{
    GCService * rv = RZReturnAutorelease([[GCService alloc] init]);
    if (rv) {
        rv.service = serv;
        switch (serv) {
            case gcServiceBabolat:
                rv.prefix = GC_SERVICE_BABOLAT;
                break;
            case gcServiceGarmin:
                rv.prefix = GC_SERVICE_GARMIN;
                break;
            case gcServiceStrava:
                rv.prefix = GC_SERVICE_STRAVA;
                break;
            case gcServiceWithings:
                rv.prefix = GC_SERVICE_WITHINGS;
                break;
            case gcServiceSportTracks:
                rv.prefix = GC_SERVICE_SPORTTRACKS;
                break;
            case gcServiceHealthKit:
                rv.prefix = GC_SERVICE_HEALTHKIT;
                break;
            case gcServiceFitBit:
                rv.prefix = GC_SERVICE_FITBIT;
                break;
            case gcServiceEnd:
                rv.prefix = @"__INVALID__";
        }
    }
    return rv;
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<GCService:%@>", self.displayName];
}
-(NSDate*)lastSync:(NSString*)aId{
    if (_activitiesSync==nil) {
        _activitiesSync = [[GCPrivateServiceSyncCache alloc] init];
    }
    return [_activitiesSync lastSync:aId service:self.service];
}
-(void)recordSync:(NSString*)aId{
    if (_activitiesSync==nil) {
        _activitiesSync = [[GCPrivateServiceSyncCache alloc] init];
    }
    // avoid collision, not the end of the world if we miss an update
    if (_activitiesSync.workingActivityId == nil) {
        _activitiesSync.workingActivityId = aId;
        _activitiesSync.service = self.service;
        dispatch_async([GCAppGlobal worker],^(){
            [_activitiesSync recordSync];
        });
    }
}

-(NSString*)activityIdFromServiceId:(NSString*)aId{
    // garmin was first so no prefix, and don't add prefix twice
    if (self.service == gcServiceGarmin || [aId hasPrefix:self.prefix]) {
        return aId;
    }
    return [self.prefix stringByAppendingString:aId];
}
-(NSString*)serviceIdFromActivityId:(NSString*)aId{
    if ([aId hasPrefix:self.prefix]) {
        return [aId substringFromIndex:(self.prefix).length];
    }
    return aId;
}
-(NSString*)statusDescription{
    if ([[GCAppGlobal profile] serviceEnabled:self.service]) {
        NSString * status = nil;
        if ([[GCAppGlobal profile] serviceIncomplete:self.service]) {
            status = [NSString stringWithFormat:NSLocalizedString(@"%@ Incomplete", @"Service Status"), self.displayName];
        }else if ([[GCAppGlobal profile] serviceSuccess:self.service]) {
            status = [NSString stringWithFormat:NSLocalizedString(@"%@ Success", @"Service Status"), self.displayName];
        }else{
            status = [NSString stringWithFormat:NSLocalizedString(@"%@ Setup", @"Service Status"), self.displayName];
        }
        return status;
    }else{
        return @"";
    }
}

-(NSString*)displayName{
    switch (self.service) {
        case gcServiceBabolat:
            return @"Babolat";
        case gcServiceGarmin:
            return @"Garmin";
        case gcServiceStrava:
            return @"Strava";
        case gcServiceWithings:
            return @"Withings";
        case gcServiceSportTracks:
            return @"SportTracks";
        case gcServiceHealthKit:
            return @"HealthKit";
        case gcServiceFitBit:
            return @"FitBit";
        case gcServiceEnd:
            return @"End";
    }
    return @"";
}
-(UIImage*)icon{
    return nil;
}
+(NSString*)serviceIdFromSportTracksUri:(NSString*)uri{
    return [uri componentsSeparatedByString:@"/"].lastObject;
}
@end
