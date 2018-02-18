//  MIT Licence
//
//  Created on 05/04/2014.
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

#import "GCSportTracksActivityDetailParser.h"
#import "GCFields.h"
#import "GCTrackPoint.h"
#import "GCActivity.h"
#import <CoreLocation/CoreLocation.h>


@interface GCSportTracksDetailWalker : NSObject
@property (nonatomic,assign) double elapsed;
@property (nonatomic,assign) NSUInteger index;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,assign) double value;
@property (nonatomic,retain) NSArray * data;
@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) GCActivity*activity;
@end

@implementation GCSportTracksDetailWalker

+(GCSportTracksDetailWalker*)detailWalker:(NSArray*)adata for:(GCField*)flag inActivity:(GCActivity*)act{
    GCSportTracksDetailWalker * rv = [[[GCSportTracksDetailWalker alloc] init] autorelease];
    if (rv) {
        rv.data  = adata;
        rv.field = flag;
        rv.index = 0;
        rv.activity = act;
        [rv readValue];

    }
    return rv;
}

-(void)dealloc{
    [_activity release];
    [_field release];
    [_data release];
    [super dealloc];
}

-(void)readValue{
    if (_index+1 < _data.count) {
        _elapsed = [_data[_index] doubleValue];
        id one = _data[_index+1];
        if ([one isKindOfClass:[NSArray class]]) {
            NSArray * oneA = one;
            _coordinate = CLLocationCoordinate2DMake([oneA[0] doubleValue], [oneA[1] doubleValue]);
        }else{
            _value = [one doubleValue];
        }
    }

}

-(BOOL)nextForElapsed:(double)elapsed{
    if (_elapsed <= elapsed && _index < _data.count) {
        _index += 2;
        [self readValue];
    }
    return _index < _data.count;
}

-(BOOL)hasMoreData{
    return _index < _data.count;
}

-(void)update:(GCTrackPoint*)point{
    if (_field.fieldFlag == gcFieldFlagNone) {
        point.longitudeDegrees = _coordinate.longitude;
        point.latitudeDegrees = _coordinate.latitude;
    }else{
        GCUnit * unit = nil;
        /*@[@"elevation",  @(gcFieldFlagAltitudeMeters)          ],
        @[@"heartrate",  @(gcFieldFlagWeightedMeanHeartRate)   ],
        @[@"distance",   @(gcFieldFlagSumDistance)             ],
        @[@"cadence",    @(gcFieldFlagCadence)                 ]*/
        switch (_field.fieldFlag) {
            case gcFieldFlagCadence:
                unit = GCUnit.stepsPerMinute;
                break;
            case gcFieldFlagWeightedMeanHeartRate:
                unit = GCUnit.bpm;
                break;
            case gcFieldFlagAltitudeMeters:
            case gcFieldFlagSumDistance:
                unit = GCUnit.meter;
                break;
            default:
                break;
        }
        if(unit){
            [point setNumberWithUnit:[GCNumberWithUnit numberWithUnit:unit andValue:_value] forField:self.field inActivity:self.activity];
        }
    }
}


@end

@implementation GCSportTracksActivityDetailParser

-(void)dealloc{
    [_points release];
    [_laps release];
    [_activity release];
    [super dealloc];
}
+(GCSportTracksActivityDetailParser*)activityDetailParser:(NSDictionary*)input  forActivity:(GCActivity*)act{
    GCSportTracksActivityDetailParser * rv = [[[GCSportTracksActivityDetailParser alloc] init] autorelease];
    if (rv) {
        [rv parse:input];
    }
    return rv;
}

-(void)parse:(NSDictionary*)json{
    if (json.count>0 && [json isKindOfClass:[NSDictionary class]]) {
        NSArray * defs  = @[ @[@"location",   @(gcFieldFlagNone)                    ],
                             @[@"elevation",  @(gcFieldFlagAltitudeMeters)          ],
                             @[@"heartrate",  @(gcFieldFlagWeightedMeanHeartRate)   ],
                             @[@"distance",   @(gcFieldFlagSumDistance)             ],
                             @[@"cadence",    @(gcFieldFlagCadence)                 ]
                             ];


        NSMutableArray * walkers = [NSMutableArray arrayWithCapacity:defs.count];
        gcFieldFlag trackflags = gcFieldFlagNone;
        NSUInteger maxpoints=0;
        for (NSArray * def in defs) {
            NSString * field = def[0];
            gcFieldFlag flag = [def[1] intValue];
            NSArray * data = json[field];
            if (data) {
                maxpoints = MAX(maxpoints, data.count);
                trackflags |= flag;
                [walkers addObject:[GCSportTracksDetailWalker detailWalker:data
                                                                       for:[GCField fieldForFlag:flag andActivityType:self.activity.activityType]
                                                                inActivity:self.activity]];
            }
        }
        NSDate  * start = [NSDate dateForSportTracksTimeString:json[@"start_time"]];
        double current_elapsed = 0.;
        BOOL more = true;
        NSMutableArray * mpoints = [NSMutableArray arrayWithCapacity:maxpoints];
        NSUInteger safeguard=0;
        while (more && safeguard < maxpoints +2) {
            safeguard+=2;
            if (safeguard > maxpoints) {
                RZLog(RZLogWarning, @"Parsed too many points");
            }
            GCTrackPoint * point = [[GCTrackPoint alloc] init];
            [mpoints addObject:point];
            point.trackFlags = trackflags;
            point.elapsed = current_elapsed;
            point.time = [start dateByAddingTimeInterval:current_elapsed];
            for (GCSportTracksDetailWalker * walker in walkers) {
                [walker update:point];
            }
            [point release];
            more = false;
            double next_elapsed = 1e10;
            for (GCSportTracksDetailWalker * walker in walkers) {
                more |=[walker nextForElapsed:current_elapsed];
                if ([walker hasMoreData]) {
                    next_elapsed = MIN(next_elapsed, walker.elapsed);
                }
            }
            current_elapsed = next_elapsed;
        }
        self.points = mpoints;

    }

}

@end
