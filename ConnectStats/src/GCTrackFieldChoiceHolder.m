//  MIT Licence
//
//  Created on 11/08/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCTrackFieldChoiceHolder.h"
#import "GCAppGlobal.h"
#import "GCHealthOrganizer.h"

@interface GCTrackFieldChoiceHolder ()

@property (nonatomic,retain) GCActivity * compareActivity;
@property (nonatomic,assign) BOOL timeAxis;
@end

@implementation GCTrackFieldChoiceHolder

+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField *)field xField:(GCField *)xField {
    GCTrackFieldChoiceHolder * rv = [[[GCTrackFieldChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.field = field;
        rv.x_field = xField;
        rv.zoneCalculator = nil;
        rv.movingAverage = 0;
    }
    return rv;
}

+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField*)f xField:(GCField*)xf movingAverage:(NSUInteger)ma{
    GCTrackFieldChoiceHolder * rv = [[[GCTrackFieldChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.field = f;
        rv.x_field = xf;
        rv.zoneCalculator = nil;
        rv.movingAverage = ma;
    }
    return rv;
}
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField*)f zone:(GCHealthZoneCalculator*)z{
    GCTrackFieldChoiceHolder * rv = [[[GCTrackFieldChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.field = f;
        rv.x_field = nil;
        rv.zoneCalculator = z;
        rv.movingAverage = 0;
        [[NSNotificationCenter defaultCenter] addObserver:rv selector:@selector(updateZoneCalculator:) name:kNotifySettingsChange object:nil];
    }
    return rv;
}

+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField*)f style:(gcTrackStatsStyle)style{
    GCTrackFieldChoiceHolder * rv = [[[GCTrackFieldChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.field = f;
        rv.x_field = nil;
        rv.zoneCalculator = nil;
        rv.statsStyle = style;
        rv.movingAverage = 0;
    }
    return rv;
}

+(GCTrackFieldChoiceHolder*)trackFieldChoiceComparing:(GCActivity*)compare timeAxis:(BOOL)timeAxis{
    GCTrackFieldChoiceHolder * rv = [[[GCTrackFieldChoiceHolder alloc] init] autorelease];
    if (rv) {
        rv.compareActivity = compare;
        rv.statsStyle = gcTrackStatsCompare;
        rv.timeAxis = timeAxis;
    }
    return rv;
}

+(GCTrackFieldChoiceHolder*)trackFieldChoice:(gcFieldFlag)f xField:(gcFieldFlag)xf movingAverage:(NSUInteger)ma type:(NSString*)aT{
    return [GCTrackFieldChoiceHolder trackFieldChoice:[GCField fieldForFlag:f andActivityType:aT]
                                               xField:[GCField fieldForFlag:f andActivityType:aT]
                                        movingAverage:ma];
}
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(gcFieldFlag)f zone:(GCHealthZoneCalculator*)z type:(NSString*)aT{
    return  [GCTrackFieldChoiceHolder trackFieldChoice:[GCField fieldForFlag:f andActivityType:aT] zone:z];
}
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(gcFieldFlag)f style:(gcTrackStatsStyle)style type:(NSString*)aT{
    return [GCTrackFieldChoiceHolder trackFieldChoice:[GCField fieldForFlag:f andActivityType:aT] style:style];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_zoneCalculator release];
    [_field release];
    [_compareActivity release];
    [_x_field release];
    [super dealloc];
}

// Setting Change can result in new zone calculator,
-(void)updateZoneCalculator:(NSNotification*)o{
    GCHealthZoneCalculator * newCalc = [[GCAppGlobal health] zoneCalculatorForField:self.zoneCalculator.field];
    if( newCalc){
        self.zoneCalculator = newCalc;
    }
}

-(NSString*)description{
    NSString * rv = @"<GCTrackFieldChoiceHolder>";
    if (self.x_field) {
        rv = [NSString stringWithFormat:@"<GCTrackFieldChoiceHolder: %@ x %@>",
              [self.field displayName], [self.x_field displayName]];
    }else if (self.zoneCalculator){
        rv = [NSString stringWithFormat:@"<GCTrackFieldChoiceHolder: %@ in zones>", [self.field displayName] ];
    }else{
        rv = [NSString stringWithFormat:@"<GCTrackFieldChoiceHolder: %@>", [self.field displayName] ];
    }
    return rv;
}

-(void)setupTrackStats:(GCTrackStats*)trackStats{
    if (self.zoneCalculator) {
        trackStats.zoneCalculator = self.zoneCalculator;
    }else{
        trackStats.zoneCalculator = nil;
    }
    trackStats.statsStyle = self.statsStyle;
    if (self.statsStyle == gcTrackStatsCompare) {
        trackStats.compareActivity = self.compareActivity;
        trackStats.timeAxis = self.timeAxis;
    }

    [trackStats setupForField:self.field xField:self.x_field andLField:nil];

}

@end
