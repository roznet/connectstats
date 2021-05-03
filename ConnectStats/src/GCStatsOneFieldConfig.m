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
@property (nonatomic,retain) GCStatsMultiFieldConfig * multiFieldConfig;
@end

@implementation GCStatsOneFieldConfig

+(GCStatsOneFieldConfig*)configFromMultiFieldConfig:(GCStatsMultiFieldConfig*)multiFieldConfig forY:(GCField*)field andX:(GCField*)xfield{
    GCStatsOneFieldConfig * rv  = [[[GCStatsOneFieldConfig alloc] init] autorelease];
    if(rv){
        rv.multiFieldConfig = [GCStatsMultiFieldConfig   fieldListConfigFrom:multiFieldConfig];
        rv.field = field;
        rv.x_field = xfield;
    }
    return rv;
}
-(void)dealloc{
    [_x_field release];
    [_field release];
    [_multiFieldConfig release];
    
    [super dealloc];
}
-(NSArray<GCField*>*)fieldsForAggregation{
    NSArray<GCField*> * base = nil;;
    if( self.x_field == nil){
        base = @[ self.field, [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType], [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityType]];
    }else{
        base = @[ self.field, self.x_field, [GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:self.activityType], [GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:self.activityType]];
    }
    return [base arrayByAddingObjectsFromArray:self.field.relatedFields];
}

-(GCStatsCalendarAggregationConfig *)calendarConfig{
    return self.multiFieldConfig.calendarConfig;
}
-(NSString *)viewDescription{
    return self.multiFieldConfig.viewDescription;
}

-(NSString*)activityType{
    return self.multiFieldConfig.activityType;
}
-(GCActivityType*)activityTypeDetail{
    return self.multiFieldConfig.activityTypeDetail;
}

-(BOOL)isEqualToConfig:(GCStatsOneFieldConfig*)other{
    return [self.field isEqualToField:other.field] && [self.x_field isEqualToField:other.x_field] &&
    self.secondGraphChoice == other.secondGraphChoice && self.viewChoice == other.viewChoice &&
    [self.multiFieldConfig isEqualToConfig:other.multiFieldConfig];
}
-(bool)nextView{
    BOOL done = [self.calendarConfig nextCalendarUnit];
    return done;
}

-(GCHistoryFieldDataSerieConfig*)historyConfig{
    return [GCHistoryFieldDataSerieConfig configWithField:self.field xField:nil filter:self.multiFieldConfig.useFilter fromDate:nil];
}
-(GCHistoryFieldDataSerieConfig*)historyConfigXY{
    return [GCHistoryFieldDataSerieConfig configWithField:self.field xField:self.x_field filter:self.multiFieldConfig.useFilter fromDate:nil];

}


@end
