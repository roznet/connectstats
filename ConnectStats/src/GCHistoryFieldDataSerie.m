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

#import "GCHistoryFieldDataSerie.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizer.h"

@interface GCHistoryFieldDataSerie ()

@end

@implementation GCHistoryFieldDataSerie


-(instancetype)init{
    return [self initFromConfig:nil];
}

-(GCHistoryFieldDataSerie*)initAndLoadFromConfig:(GCHistoryFieldDataSerieConfig*)config withThread:(dispatch_queue_t)worker{
    self = [super init];
    if (self) {
        self.config = config;
        if (worker) {
            dispatch_async(worker,^(){
                [self loadFromOrganizer];
            });
        }else{
            [self loadFromOrganizer];
        }
    }
    return self;
}
-(GCHistoryFieldDataSerie*)initFromConfig:(GCHistoryFieldDataSerieConfig*)config{
    self = [super init];
    if (self) {
        self.config = config;
    }
    return self;

}

-(void)dealloc{

    [_db release];
    [_gradientSerie release];
    [_gradientFunction release];
    [_history release];
    [_organizer release];

    [_config release];

    [super dealloc];
}

#pragma mark - New Series

-(GCHistoryFieldDataSerie*)serieWithCutOff:(NSDate*)cutOff inCalendarUnit:(NSCalendarUnit)aUnit withReferenceDate:(NSDate*)refOrNil{

    GCHistoryFieldDataSerieConfig * config = [GCHistoryFieldDataSerieConfig configWithConfig:self.config];
    config.cutOff = cutOff;
    config.cutOffUnit = aUnit;

    GCHistoryFieldDataSerie * rv = [GCHistoryFieldDataSerie historyFieldDataSerieFrom:self];
    if (rv) {
        rv.config = config;
        rv.history = [self.history serieWithCutOff:cutOff
                                          withUnit:aUnit
                                     referenceDate:refOrNil
                                       andCalendar:[GCAppGlobal calculationCalendar]];
        rv.gradientSerie = [self.gradientSerie serieWithCutOff:cutOff
                                                      withUnit:aUnit
                                                 referenceDate:refOrNil
                                                   andCalendar:[GCAppGlobal calculationCalendar]];
    }

    return rv;
}

+(GCHistoryFieldDataSerie*)historyFieldDataSerieFrom:(GCHistoryFieldDataSerie*)other{
    GCHistoryFieldDataSerie * rv = [[[GCHistoryFieldDataSerie alloc] init] autorelease];
    if (rv) {
        rv.db = other.db;
        rv.config = other.config;
        rv.history = other.history;
        rv.gradientFunction = other.gradientFunction;
        rv.gradientSerie =other.gradientSerie;
    }
    return rv;
}

#pragma mark - Setup

-(void)setupAndLoadForConfig:(GCHistoryFieldDataSerieConfig*)config withThread:(dispatch_queue_t)worker{

    self.config = config;
    self.history = nil;
    if (worker) {
        dispatch_async(worker,^(){
            [self loadFromOrganizer];
        });
    }else{
        [self loadFromOrganizer];
    }
}

-(void)setupForConfig:(GCHistoryFieldDataSerieConfig*)config{
    self.config = config;
    self.history = nil;
}

-(NSString*)uom{
    return self.history.unit.key;
}

-(NSString*)x_uom{
    return self.history.xUnit.key;
}

-(NSString*)fieldDisplayName{
    return [self.config.activityField displayName];
}

-(NSString*)x_fieldDisplayName{
    return [self.config.x_activityField displayName];
}
#pragma mark - Load

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (theParent == self.organizer && [self ready]) {
        // reload
        dispatch_async([GCAppGlobal worker],^(){
            [self loadFromOrganizer];
        });
    }
}

-(BOOL)ready{
    return self.history != nil && !self.dataLock;
}

-(void)loadFromOrganizer{
    self.dataLock = true;
    if (self.organizer==nil) {
        self.organizer = [GCAppGlobal organizer];
    }
    NSMutableArray * fields = [NSMutableArray arrayWithObject:self.config.activityField];
    if (self.config.x_activityField) {
        [fields addObject:self.config.x_activityField];
    }
    GCActivityMatchBlock filter = nil;
    BOOL checkActivityType = ![self.config.activityType isEqualToString:GC_TYPE_ALL];
    gcIgnoreMode ignoreMode = [self.config.activityType isEqualToString:GC_TYPE_DAY] ? gcIgnoreModeDayFocus : gcIgnoreModeActivityFocus;
    GCField * activityField = self.config.activityField;
    NSString * activityType = self.config.activityType;
    GCField * x_activityField = self.config.x_activityField;

    NSDate * fromDate = self.config.fromDate;

    if (checkActivityType || fromDate!=nil) {
        filter = ^(GCActivity*act){
            BOOL keep = !checkActivityType || [act.activityType isEqualToString:activityType];
            if (fromDate) {
                keep = keep && ([fromDate compare:act.date] == NSOrderedAscending);
            }
            return keep;
        };
    }

    NSDictionary * series = [self.organizer fieldsSeries:fields
                                                matching:filter
                                             useFiltered:self.config.useFilter
                                              ignoreMode:ignoreMode];

    GCStatsDataSerieWithUnit*(^processSerie)(GCField*field,GCStatsDataSerieWithUnit*serie) = ^(GCField*field,GCStatsDataSerieWithUnit*serie){
        GCStatsDataSerieWithUnit * rv = serie;
        GCStatsDataSerieFilter * seriefilter = [self.organizer standardFilterForField:field];
        if (seriefilter) {
            rv = [seriefilter filteredSerieWithUnitFrom:rv];
        }
        if (self.config.cutOff) {
            rv = [rv serieWithCutOff:self.config.cutOff withUnit:self.config.cutOffUnit referenceDate:nil andCalendar:[GCAppGlobal calculationCalendar]];
        }

        return rv;
    };
    if (series.count) {
        GCStatsDataSerieWithUnit * hist = processSerie(self.config.activityField,series[self.config.activityField]);
        self.history = hist;
    }else{
        self.history = nil;
    }

    if (x_activityField) {
        GCStatsDataSerieWithUnit * xSerie = processSerie(x_activityField,series[x_activityField]);

        //self.x_fieldDisplayName = [x_activityField displayName];
        //self.x_uom = (xSerie.unit).key;

        // Health Measure runs against week, for example weight against the prev week dist.
        self.config.healthLookbackUnit = 3600.*24.*7.;//1week
        if ([x_activityField isHealthField]) {
            if (self.config.healthLookbackUnit!=0.) {
                [GCStatsDataSerie reduceToCommonInterval:xSerie.serie and:self.history.serie];
                self.history.serie = [xSerie.serie movingAverageOrSumOf:self.history.serie forUnit:self.config.healthLookbackUnit offset:0. average:![self.config.activityField canSum]];
            }else{
                GCStatsInterpFunction * f = [GCStatsInterpFunction interpFunctionWithSerie:xSerie.serie];
                xSerie.serie = [f valueForXIn:self.history.serie];
            }
        }else if([activityField isHealthField]){
            if (self.config.healthLookbackUnit!=0.) {
                [GCStatsDataSerie reduceToCommonInterval:xSerie.serie and:self.history.serie];
                xSerie.serie = [self.history.serie movingAverageOrSumOf:xSerie.serie forUnit:self.config.healthLookbackUnit offset:0. average:![self.config.x_activityField canSum]];
            }else{
                GCStatsInterpFunction * f = [GCStatsInterpFunction interpFunctionWithSerie:self.history.serie];
                self.history.serie = [f valueForXIn:xSerie.serie];
            }
        }

        [GCStatsDataSerie reduceToCommonRange:self.history.serie and:xSerie.serie];
        // Make a copy, as history will be changed later to become the xy serie
        self.gradientSerie = [GCStatsDataSerieWithUnit dataSerieWithOther:self.history];
        self.gradientFunction = [GCStatsScaledFunction scaledFunctionWithSerie:_gradientSerie.serie];
        [_gradientFunction setScale_x:true];

        GCStatsInterpFunction * interp = [GCStatsInterpFunction interpFunctionWithSerie:xSerie.serie];
        GCStatsDataSerie * xy = [interp xySerieWith:_history.serie];
        self.history.serie = xy;
        self.history.xUnit = xSerie.unit;

    }else{
        [self setGradientFunction:nil];
        [self setGradientSerie:nil];
    }

    self.dataLock = false;
    [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
}


#pragma mark - Access

-(GCField*)activityField{
    return self.config.activityField;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"%@ %@ %d points", self.config.activityType, self.config.activityField, (int)[_history count]];
}

-(NSString*)formattedValue:(double)aVal{
    return [self.history.unit formatDouble:aVal];
}
-(NSUInteger)count{
    return [_history count];
}

-(BOOL)isEmpty{
    return [_history count] == 0;
}

-(NSDate*)lastDate{
    if (_history.count>0) {
        return [[_history dataPointAtIndex:0] date];
    }
    return nil;
}

#pragma mark - DataSource

-(NSUInteger)nDataSeries{
    return 1;
}
-(GCStatsDataSerie * )dataSerie:(NSUInteger)idx{
    return _history.serie;
}
-(gcStatsRange)rangeForSerie:(NSUInteger)idx{
    return [_history.serie range];
}
-(GCUnit*)yUnit:(NSUInteger)idx{
    return _history.unit;
}
-(GCUnit*)xUnit{
    return _history.xUnit;
}
-(CGPoint)currentPoint:(NSUInteger)idx{
    return CGPointMake(0., 0.);
}
-(NSString*)title{
    if (self.config.x_activityField) {
        return [NSString stringWithFormat:@"%@ x %@", [self.config.activityField displayNameWithUnits:[self yUnit:0]],
                [self.config.x_activityField displayNameWithUnits:[self xUnit]]];
    }
    return [self.config.activityField displayNameWithUnits:[self yUnit:0]];
}
-(NSString*)legend:(NSUInteger)idx{
    return nil;
}

@end
