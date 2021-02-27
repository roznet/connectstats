//  MIT Licence
//
//  Created on 06/08/2015.
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

#import "GCActivity+CSSearch.h"
#import "GCFields.h"
@import CoreSpotlight;
#import "GCActivity+Fields.h"

NSString * kNSUserActivityTypeViewOne = @"app.connectstats.viewOne";
NSString * kNSUserActivityUserInfoActivityIdKey = @"activityId";

@implementation GCActivity (CSSearch)

-(NSString*)spotLightTitle{

    NSMutableArray * comp = [NSMutableArray array];
    NSString * atype = [self spotLightActivityType];

    if (atype) {
        [comp addObject:atype];
    }
    GCNumberWithUnit * dist = [[self numberWithUnitForFieldFlag:gcFieldFlagSumDistance] convertToGlobalSystem];
    //GCNumberWithUnit * duration = [self summaryFieldNumberWithUnit:gcFieldFlagSumDuration];
    GCNumberWithUnit * speed = [[self numberWithUnitForFieldFlag:gcFieldFlagWeightedMeanSpeed] convertToGlobalSystem];

    if (dist) {
        [comp addObject:[dist formatDouble]];
    }
    if (speed) {
        [comp addObject:[speed formatDouble]];
    }

    if (self.location && ! [self.location isEqualToString:@", "]) {
        [comp addObject:self.location];
    }

    return [comp componentsJoinedByString:@" "];
}

-(NSString*)spotLightActivityType{
    return self.activityTypeDetail.displayName;
}

-(void)updateUserActivity:(NSUserActivity*)activity{
    if ([activity.activityType isEqualToString:kNSUserActivityTypeViewOne]) {
        NSUserActivity * rv = activity;
        if( self.activityId == nil){
            return;
        }
        rv.title = [self spotLightTitle];
        rv.userInfo = @{ kNSUserActivityUserInfoActivityIdKey:self.activityId};
        //iOS9 Check
        if ([rv respondsToSelector:@selector(requiredUserInfoKeys)]) {
            rv.requiredUserInfoKeys = [NSSet setWithArray:@[kNSUserActivityUserInfoActivityIdKey]];
        }

        if ([rv respondsToSelector:@selector(contentAttributeSet)]) {
            CSSearchableItemAttributeSet * attr = [[[CSSearchableItemAttributeSet alloc] init] autorelease];
            attr.identifier = self.activityId;
            attr.startDate = self.date;
            attr.endDate = self.endTime;
            NSMutableArray * alt = [NSMutableArray array];
            if (self.activityName) {
                [alt addObject:self.activityName];
            }
            NSString * aType = [self spotLightActivityType];
            if (aType != nil) {
                [alt addObject:aType];
            }
            //[alt addObject:[GCFields activityTypeDisplay:self.activityTypeDetail]];
            attr.alternateNames = alt;
            attr.displayName =rv.title;
            attr.longitude = @(self.beginCoordinate.longitude);
            attr.latitude = @(self.beginCoordinate.latitude);
            attr.namedLocation = self.location;

            rv.contentAttributeSet =attr;
            rv.eligibleForSearch = true;
        }

    }
}

-(NSUserActivity*)spotLightUserActivity{
    NSUserActivity * rv = [[[NSUserActivity alloc] initWithActivityType:kNSUserActivityTypeViewOne] autorelease];
    [self updateUserActivity:rv];
    return rv;
}
@end
