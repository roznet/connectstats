//  MIT Licence
//
//  Created on 30/09/2012.
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

#import <Foundation/Foundation.h>
@import RZExternal;
#import "GCViewActivityTypeButton.h"


typedef NS_ENUM(NSUInteger, gcCalendarDayDisplay) {
    gcCalendarDayDisplayMarker,
    gcCalendarDayDisplayDistancePercent,
    gcCalendarDayDisplayDistance,
    gcCalendarDayDisplayStepsPercent,
    gcCalendarDayDisplaySteps,
    gcCalendarDayDisplayActive,
    gcCalendarDayDisplayEnd
};

typedef NS_ENUM(NSUInteger, gcCalendarDisplay) {
    gcCalendarDisplayMarker,
    gcCalendarDisplayDistancePercent,
    gcCalendarDisplayDistance,
    gcCalendarDisplayDurationPercent,
    gcCalendarDisplayDuration,
    gcCalendarDisplaySpeed,
    gcCalendarDisplayEnd
};

typedef NS_ENUM(NSUInteger, gcCalendarTableDisplay) {
    gcCalendarTableDisplayActivities,
    gcCalendarTableDisplaySummary,
    gcCalendarTableDisplayEnd
};

@class GCHistoryAggregatedStats;

@interface GCCalendarDataSource : NSObject<KalDataSource,GCCellGridDelegate,UITableViewDelegate,GCViewActivityTypeButtonDelegate,RZChildObject>

@property (nonatomic,assign) gcCalendarDisplay display;
@property (nonatomic,assign) gcCalendarTableDisplay tableDisplay;
@property (nonatomic,readonly) BOOL extendedDisplay;

@property (nonatomic,weak) UIViewController * presentingViewController;

-(void)toggleDisplay;
-(void)toggleTableDisplay;

@end
