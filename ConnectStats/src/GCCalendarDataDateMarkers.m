//  MIT Licence
//
//  Created on 17/01/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCCalendarDataDateMarkers.h"
#import "GCActivity.h"
#import "GCCalendarDataMarkerInfo.h"
@import RZExternal;
#import "GCViewIcons.h"
#import "GCViewConfig.h"
#import "GCActivity+UI.h"

@interface GCCalendarDataDateMarkers ()
@property (nonatomic,retain) NSDictionary * markersInfoByType;


@end

@implementation GCCalendarDataDateMarkers

-(void)dealloc{
    [_markersInfoByType release];
    [_infoTotals release];
    [_dateKey release];

    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@>%@", NSStringFromClass([self class]),self.markersInfoByType];
}

-(BOOL)addActivity:(GCActivity*)act{
    NSDate * actDateKey = [[KalDate dateFromNSDate:act.date] NSDate];
    if (self.dateKey==nil) {
        self.dateKey = actDateKey;
    }
    if (self.dateKey != actDateKey) {
        return false;
    }

    NSString * activityTypeKey = [act activityTypeKey:self.primaryActivityTypesOnly];
    GCCalendarDataMarkerInfo * info = self.markersInfoByType[activityTypeKey];
    if (!info) {
        info = [GCCalendarDataMarkerInfo markerInfo];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithObject:info forKey:activityTypeKey];
        if (self.markersInfoByType) {
            [dict addEntriesFromDictionary:self.markersInfoByType];
        }
        self.markersInfoByType = dict;
    }

    [info addActivity:act];

    if (!self.infoTotals) {
        self.infoTotals = [GCCalendarDataMarkerInfo markerInfo];
    }
    [self.infoTotals addActivity:act];

    return true;
}


-(NSArray*)orderedActivityTypes{
    NSArray * rv = self.markersInfoByType.allKeys;
    return rv;
}
-(GCCalendarDataMarkerInfo*)inforForType:(NSString*)typeKey{
    return self.markersInfoByType[typeKey];
}
-(NSUInteger)totalCount{
    return self.infoTotals.count;
}

-(GCUnit*)displaySpeedUnit{
    NSArray * types = self.markersInfoByType.allKeys;
    if (types.count == 1) { // if only one type: easy...
        return [[GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:types[0]] unit];
    }

    return [[GCField fieldForFlag:gcFieldFlagWeightedMeanSpeed andActivityType:GC_TYPE_CYCLING] unit] ?: [GCUnit unitForKey:@"kph"];
}
-(UIColor*)displayTextColor{
    NSArray * types = self.markersInfoByType.allKeys;
    UIColor * rv = nil;
    if (types.count == 1) { // if only one type: easy...
        return [GCViewConfig textColorForActivity:types[0]];

    }else{
        return [GCViewConfig textColorForActivity:GC_TYPE_ALL];
    }

    return  rv;

}
@end
