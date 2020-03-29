//  MIT License
//
//  Created on 22/03/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCActivity+TrackTransform.h"


#define MAX_FILL_POINTS 28800
#define X_FOR(p) (timeAxis ? p.elapsed : p.distanceMeters)

@implementation GCActivity (TrackTransform)

-(NSArray<GCTrackPoint*>*)removedStoppedTimer:(nonnull NSArray<GCTrackPoint*>*)points{
    //don't bother if not enough points
    if( points.count < 2){
        return points;
    }

    NSDate * current_time = nil;
    double current_elapsed = 0;
    double current_distance = 0;

    GCTrackPoint * last_point = nil;
    GCTrackPoint * last_adjusted_point = nil;
    
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:points.count];

    for (GCTrackPoint * current_point in points) {
        gcTrackEventType event = current_point.trackEventType;
        
        if( last_point ){
            // If start : last point must have been stop, so ignore
            // and keep the last value
            if( event != gcTrackEventTypeStart ){
                current_time =  [last_adjusted_point.time dateByAddingTimeInterval:[current_point.time timeIntervalSinceDate:last_point.time]];
                current_elapsed += current_point.elapsed - last_point.elapsed;
                current_distance += current_point.distanceMeters - last_point.distanceMeters;
            }
        }else{
            // first point likely start but we are starting sometime
            current_time = current_point.time;
            current_elapsed = current_point.elapsed;
            current_distance = current_point.distanceMeters;
        }
        
        GCTrackPoint * adjusted_point = [[GCTrackPoint alloc] initWithTrackPoint:current_point];
        adjusted_point.time = current_time;
        adjusted_point.elapsed = current_elapsed;
        adjusted_point.distanceMeters = current_distance;
        
        [rv addObject:adjusted_point];
        last_adjusted_point = adjusted_point; // retained by the array
        [adjusted_point release];
        last_point = current_point;
    }
    
    return rv;
}

-(nonnull NSArray<GCTrackPoint*>*)recalculatedSpeed:(nonnull NSArray<GCTrackPoint*>*)points
                                     minimumDistance:(CLLocationDistance)minDistance
                                      minimumElapsed:(NSTimeInterval)minElapsed
                                             useGPS:(BOOL)useGPS
{
    NSMutableArray<GCTrackPoint*> * rv = [NSMutableArray arrayWithCapacity:points.count];
    NSMutableArray<GCTrackPoint*> * trailing = [NSMutableArray array];
    
    GCTrackPoint * last_point = nil;
    
    CLLocationDistance runningDistance = 0.0;
    NSTimeInterval runningElapsed = 0.0;
    
    double mps = 0.0;
    
    BOOL started = false;
    
    for (GCTrackPoint * current_point in points) {
        CLLocationDistance thisDistance = 0.0;
        NSTimeInterval thisElapsed = 0.0;
        
        [trailing addObject:current_point];

        if( last_point ){
            thisDistance = [current_point distanceMetersFrom:last_point];
            thisElapsed = last_point.elapsed;  // applies betwen lastpoint and currentpoint
            
            runningDistance += thisDistance;
            runningElapsed += thisElapsed;
            
            if( runningElapsed > minElapsed && runningDistance > minDistance){
                started = true;
                
                if( runningElapsed > 0){
                    mps = runningDistance/runningElapsed;
                }
                
                while( trailing.count > 2 && ( runningElapsed > minElapsed && runningDistance > minDistance )){
                    
                    GCTrackPoint * first = trailing.firstObject;
                    GCTrackPoint * second = trailing[1];
                    
                    CLLocationDistance firstDistance = [second distanceMetersFrom:first];
                    NSTimeInterval firstElapsed  = first.elapsed;
                    
                    runningElapsed -= firstElapsed;
                    runningDistance -= firstDistance;
                
                    [trailing removeObjectAtIndex:0];
                }
            }
            if( ! started ){
                mps = current_point.speed;
            }
        }else{
            mps = current_point.speed;
        }
        if( last_point){
            GCTrackPoint * newPoint = [[GCTrackPoint alloc] initWithTrackPoint:last_point];
            newPoint.speed = mps;
            [rv addObject:newPoint];
            [newPoint release];
        }
        last_point = current_point;
    }
    return rv;
}



-(nonnull NSArray<GCTrackPoint*>*)resample:(nonnull NSArray<GCTrackPoint*>*)points forUnit:(double)unit useTimeAxis:(BOOL)timeAxis{
    //don't bother if no points
    if( points.count == 0){
        return points;
    }
    GCTrackPoint * first_p = points[0];
    size_t last_i   = 0;
    double first_x  =  X_FOR(first_p);

    BOOL inconsistentPoint=false;

    NSUInteger n = points.count;

    double accrued = 0.;

    GCTrackPoint * currentPoint = [[GCTrackPoint alloc] init];

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:n];
    [rv addObject:currentPoint];

    for (NSUInteger idx_p = 1;idx_p <= n;idx_p++) {
        GCTrackPoint * from_p = points[idx_p-1];
        GCTrackPoint * to_p   = idx_p < n ? points[idx_p] : nil;

        //double elapsed  = [to_p.time timeIntervalSinceDate:from_p.time];
        //double distance = to_p.validCoordinate && from_p.validCoordinate ? [to_p distanceMetersFrom:from_p] : to_p.distanceMeters-from_p.distanceMeters;

        double from_x  = X_FOR(from_p)-first_x;
        double to_x    = to_p ? X_FOR(to_p)-first_x : from_x;

        NSUInteger from_i = MIN(from_x/unit,MAX_FILL_POINTS-1);
        NSUInteger to_i   = MIN(to_x/unit,MAX_FILL_POINTS-1);

        if (from_i!=last_i) {
            inconsistentPoint = true;
        }

        //last_i = to_i;

        if (to_p == nil) {
            // last point allocated to last
            [currentPoint add:from_p withAccrued:(unit-accrued)/unit timeAxis:timeAxis];
            // values[from_i] += from_p.y_data * (unit - accrued)/unit;
        }else if ( to_i==from_i) {
            // didn't cross to next point yet, weighted allocation to current i
            //      f     t
            // I: --|aa---|---
            // P: ----X-X-----
            //        f t
            [currentPoint add:from_p withAccrued:(to_x-from_x)/unit timeAxis:timeAxis];
            // values[from_i] += from_p.y_data * (to_x-from_x)/unit;
            accrued += (to_x-from_x);
        }else{
            // got to next
            //
            //    f     t
            // I: |aaa--|-----|-----|-----|
            // P:  --X-----X----------
            //       f     t
            //
            //    f     s     s     t
            // I: |aaa--|-----|-----|-----|
            // P:  --X----------------X---
            //       f                t

            for (size_t step_i = from_i; step_i<to_i; step_i++) {
                size_t next_i = step_i+1;
                double next_x = unit*next_i;

                double step_x = step_i == from_i ? from_x : unit*step_i;

                double weight =(next_x-step_x)/unit;
                // fill steps to far from last with zero (else with last value)
                // could impose limit: fill w zero when more than L since last
                /* if (step_i!=from_i && fill == gcStatsZero) {
                 step_v = 0.;
                 }*/

                [currentPoint add:from_p withAccrued:weight timeAxis:timeAxis];
                last_i = step_i;

                if (next_i < MAX_FILL_POINTS && next_i == to_i) {
                    [currentPoint release];
                    currentPoint = [[GCTrackPoint alloc] init];
                    [rv addObject:currentPoint];
                    [currentPoint add:from_p withAccrued:(to_x-next_x)/unit timeAxis:timeAxis];
                    last_i = to_i;
                    accrued = (to_x-next_x);
                }
            }
        }
    }
    [currentPoint release];
    if (inconsistentPoint) {
        RZLog(RZLogError, @"Logic Error: Inconsistent x");
    }

    return rv;
}

-(NSArray<GCTrackPoint*>*)matchDistance:(CLLocationDistance)target withPoints:(NSArray<GCTrackPoint*>*)points{
    CLLocationDistance x_a = 0.0;
    CLLocationDistance x_b = 5.0;
    
    CLLocationDistance  y_a = 0.0;
    CLLocationDistance  y_b = 0.0;

    CLLocationDistance x_c = 0.0;
    CLLocationDistance y_c = 0.0;

    y_a = [self filterTrackpoints:points with:x_a addTo:nil];
    y_b = [self filterTrackpoints:points with:x_b addTo:nil];

    while( (y_a - target) * (y_b - target) < 0 && fabs(y_b-target) > 1.0 && fabs(y_a-target) > 1.0 && fabs(x_a-x_b) > 0.001){
        x_c = (x_a+x_b)/2.0;
        y_c = [self filterTrackpoints:points with:x_c  addTo:nil];
        
        if( (y_a - target) * (y_c - target) < 0){
            x_b = x_c;
            y_b = y_c;
        }else{
            x_a = x_c;
            y_a = y_c;
        }
    }
    NSMutableArray * rv = [NSMutableArray array];
    if( fabs(y_a -target ) < fabs(y_b-target)){
        y_c = [self filterTrackpoints:points with:x_a  addTo:rv];
        x_c = x_a;
    }else{
        y_c = [self filterTrackpoints:points with:x_b  addTo:rv];
        x_c = x_b;
    }
    RZLog(RZLogInfo, @"trackpoints(<%f)[%lu] = %fm, orig[%lu] = %fm",x_c,(unsigned long)rv.count, y_c, (unsigned long)points.count, target );
    return rv;
}

-(CLLocationDistance)filterTrackpoints:(NSArray<GCTrackPoint*>*)trackpoints with:(CLLocationDistance)minimumDistance addTo:(NSMutableArray*)rv{
    CLLocationDistance finalDistance = 0.0;
    CLLocationDistance baseDistance = 0.0;
    NSUInteger n = 0;
    GCTrackPoint * last = nil;
    for (GCTrackPoint * next in trackpoints) {
        if( last != nil){
            CLLocationDistance dist = last != nil ? [next distanceMetersFrom:last] : 0.0;
            baseDistance += dist;

            if( next.validCoordinate && dist > minimumDistance ){
                finalDistance += dist;
                [rv addObject:next];
                n+=1;
            }
        }
        last = next;
    }
    return finalDistance;
}

-(NSString*)csvTrackPoints:(NSArray<GCTrackPoint*>*)trackpoints{
    if( trackpoints.count == 0){
        return @"";
    }
    NSMutableString * rv = [NSMutableString string];
    NSMutableSet * fields = [NSMutableSet set];
    for (GCTrackPoint * point in trackpoints) {
        [fields unionSet:[point csvFieldsInActivity:self]];
    }
    
    NSArray * allFields = fields.allObjects;
    
    NSArray<NSString*>*labels = [trackpoints.firstObject csvLabelsForFields:allFields InActivity:self];
    
    [rv appendString:[labels componentsJoinedByString:@","]];
    [rv appendString:@"\n"];
    
    for (GCTrackPoint * point in trackpoints) {
        NSArray * values = [point csvValuesForFields:allFields InActivity:self];
        if( values.count != labels.count){
            NSLog(@"oops");
        }
        
        [rv appendString:[values componentsJoinedByString:@","]];
        [rv appendString:@"\n"];
    }
    return rv;
}


@end
