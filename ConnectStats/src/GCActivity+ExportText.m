//  MIT Licence
//
//  Created on 13/01/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCActivity+ExportText.h"
#import "GCActivity+Fields.h"
#import "GCActivityType.h"

@implementation GCActivity (ExportText)

-(NSString*)exportPost{
    //NSMutableString * rv = [NSMutableString stringWithFormat:@"]
    // Thursday, ran 10.1km in 47:23 at 4:47 min/km in London, GB
    // March 10th, biked 10.2km in 31:23 at 12 km/h in New York, US
    //
    NSMutableString * rv = [NSMutableString stringWithString:[self.date dateFormatFromToday]];
    [rv appendString:@", "];
    if ([self.activityType isEqualToString:GC_TYPE_RUNNING]) {
        [rv appendString:NSLocalizedString(@"ran", @"Activity Text")];
    }else if([self.activityType isEqualToString:GC_TYPE_CYCLING]){
        [rv appendString:NSLocalizedString(@"biked", @"Activity Text")];
    }else if([self.activityType isEqualToString:GC_TYPE_SWIMMING]){
        [rv appendString:NSLocalizedString(@"swam", @"Activity Text")];
    }
    GCNumberWithUnit * dist = [[self numberWithUnitForFieldFlag:gcFieldFlagSumDistance] convertToGlobalSystem];
    GCNumberWithUnit * duration = [self numberWithUnitForFieldFlag:gcFieldFlagSumDuration];
    GCNumberWithUnit * speed = [[self numberWithUnitForFieldFlag:gcFieldFlagWeightedMeanSpeed] convertToGlobalSystem];

    [rv appendFormat:NSLocalizedString(@" %@ in %@ at %@", @"Activity Test"), [dist formatDouble], [duration formatDouble], [speed formatDouble]];
    if (self.location && ! [self.location isEqualToString:@""]) {
        [rv appendFormat:NSLocalizedString(@" in %@", @"Activity Text"), self.location];
    }

    return rv;
}

-(NSString*)exportTitle{
    NSString * loc = @"";
    if (self.location && ! [self.location isEqualToString:@""]) {
        loc= [NSString stringWithFormat:@" %@", self.location];
    }

    return [NSString stringWithFormat:@"%@ %@ %@%@", [self.date dateShortFormat], [GCActivityType activityTypeForKey:self.activityType].displayName,
            [[self numberWithUnitForFieldFlag:gcFieldFlagSumDistance] formatDouble], loc];
}
-(NSString*)exportFileName:(NSString*)extensionOrNil{

    NSMutableString * filename = [NSMutableString stringWithFormat:@"%@_%@",self.activityId, [self.date YYYYMMDD]];

    if (self.activityType) {
        [filename appendFormat:@"_%@", self.activityType];
    }
    GCNumberWithUnit * dist = [[self numberWithUnitForFieldFlag:gcFieldFlagSumDistance] convertToGlobalSystem];
    if (dist.value > 0.) {
        [filename appendFormat:@"_%@",[dist formatDouble]];
    }

    [filename replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, filename.length)];
    [filename replaceOccurrencesOfString:@"." withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, filename.length)];

    if (extensionOrNil) {
        [filename appendFormat:@".%@",extensionOrNil];
    }
    return filename;
}

-(NSString*)exportSource{
    NSMutableString * rv = [NSMutableString string];
    if (self.metaData && self.metaData[@"device"]) {
        GCActivityMetaValue * val = self.metaData[@"device"];
        [rv appendFormat:@"<p>Recorded with %@</p>", val.display];
    }
    [rv appendFormat:@"<p>View in <a href=\"http://connect.garmin.com/activity/%@\">Garmin Connect</a></p>",self.activityId];
    return rv;
}
-(NSString*)exportCsv{
    NSArray<GCField*> * fields = [self availableTrackFields];

    NSMutableString * rv = [NSMutableString string];
    NSMutableArray * line = [NSMutableArray arrayWithArray:@[@"Time",@"Elapsed",@"Latitude",@"longitude",@"GPS Distance",@"Recorded Distance"]];

    for (GCField * field in fields) {
        [line addObject:field.displayName];
    }
    [rv appendString:[line componentsJoinedByString:@","]];
    [rv appendString:@"\n"];

    GCTrackPoint * prev = nil;
    GCTrackPoint * first = nil;

    for (GCTrackPoint * point in self.trackpoints) {
        if (first == nil) {
            first = point;
        }
        [line removeAllObjects];
        [line addObject:[point.time formatAsRFC3339]];
        [line addObject:@([point.time timeIntervalSinceDate:first.time])];
        [line addObjectsFromArray:@[ @(point.latitudeDegrees), @(point.longitudeDegrees),
         @(prev ?  [point distanceMetersFrom:prev] : 0.),
         @(point.distanceMeters)
         ]];
        for (GCField * field  in fields) {
            GCNumberWithUnit * nu = [point numberWithUnitForField:field inActivity:self];
            [line addObject:nu ? nu.number : @(0)];
        }
        [rv appendString:[line componentsJoinedByString:@","]];
        [rv appendString:@"\n"];
        prev = point;

    }
    return rv;
}

@end
