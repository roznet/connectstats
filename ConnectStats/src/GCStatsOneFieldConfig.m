//  MIT Licence
//
//  Created on 25/08/2014.
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

#import "GCStatsOneFieldConfig.h"
#import "GCStatsMultiFieldConfig.h"
@interface GCStatsOneFieldConfig ()
@end

@implementation GCStatsOneFieldConfig

+(GCStatsOneFieldConfig*)configFromMultiFieldConfig:(GCStatsMultiFieldConfig*)multiFieldConfig forY:(GCField*)field andX:(GCField*)xfield{
    GCStatsOneFieldConfig * rv  = [[[GCStatsOneFieldConfig alloc] init] autorelease];
    if(rv){
        rv.calendarConfig = multiFieldConfig.calendarConfig;
        rv.useFilter = multiFieldConfig.useFilter;
        rv.viewChoice = gcViewChoiceFields;
        rv.activityType = multiFieldConfig.activityType;
        rv.useFilter = multiFieldConfig.useFilter;
        rv.field = field;
        rv.x_field = xfield;
    }
    return rv;
}
-(void)dealloc{
    [_activityType release];
    [_x_field release];
    [_field release];
    [_calendarConfig release];
    
    [super dealloc];
}
-(NSString *)viewDescription{
    return [GCViewConfig viewChoiceDesc:self.viewChoice calendarConfig:self.calendarConfig];
}

-(BOOL)isEqualToConfig:(GCStatsOneFieldConfig*)other{
    return [self.field isEqualToField:other.field] && [self.x_field isEqualToField:other.x_field] &&
    self.secondGraphChoice == other.secondGraphChoice && self.viewChoice == other.viewChoice &&
    [self.calendarConfig isEqualToConfig:other.calendarConfig];
}
-(bool)nextView{
    if( self.viewChoice == gcViewChoiceFields){
        self.viewChoice = gcViewChoiceCalendar;
    }else if( self.viewChoice == gcViewChoiceCalendar){
        if( [self.calendarConfig nextCalendarUnit] ){
            self.viewChoice = gcViewChoiceFields;
        }
    }else{
        self.viewChoice = gcViewChoiceFields;
    }
    return self.viewChoice == gcViewChoiceFields;
}
-(GCHistoryFieldDataSerieConfig*)historyConfig{
    return [GCHistoryFieldDataSerieConfig configWithField:_field xField:nil filter:_useFilter fromDate:nil];
}
-(GCHistoryFieldDataSerieConfig*)historyConfigXY{
    return [GCHistoryFieldDataSerieConfig configWithField:_field xField:_x_field filter:_useFilter fromDate:nil];

}
@end
