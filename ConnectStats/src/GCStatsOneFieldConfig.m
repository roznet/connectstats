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
#import "GCViewIcons.h"

@interface GCStatsOneFieldConfig ()
@property (nonatomic,retain) GCStatsMultiFieldConfig * multiFieldConfig;
@end

@implementation GCStatsOneFieldConfig

+(GCStatsOneFieldConfig*)configFromMultiFieldConfig:(GCStatsMultiFieldConfig*)multiFieldConfig forY:(GCField*)field andX:(GCField*)xfield{
    GCStatsOneFieldConfig * rv  = [[[GCStatsOneFieldConfig alloc] init] autorelease];
    if(rv){
        rv.multiFieldConfig = [GCStatsMultiFieldConfig   fieldListConfigFrom:multiFieldConfig];
        rv.multiFieldConfig.viewChoice = gcViewChoiceCalendar;
        // We should always be set different than unused for one field config
        if( multiFieldConfig.viewConfig == gcStatsViewConfigUnused){
            rv.multiFieldConfig.viewConfig = gcStatsViewConfigAll;
        }
        rv.field = field;
        rv.x_field = xfield;
    }
    return rv;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@ %@>",
            NSStringFromClass([self class]),
            self.field,
            self.x_field ?: @"<XField Nil>",
            self.multiFieldConfig
    ];
}

+(GCStatsOneFieldConfig*)fieldListConfigFrom:(GCStatsOneFieldConfig*)other{
    GCStatsOneFieldConfig * rv = [GCStatsOneFieldConfig configFromMultiFieldConfig:other.multiFieldConfig forY:other.field andX:other.x_field];
    rv.secondGraphChoice = other.secondGraphChoice;
    return rv;
}
-(GCStatsOneFieldConfig*)sameFieldListConfig{
    return [GCStatsOneFieldConfig fieldListConfigFrom:self];
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

#pragma mark - fiels indirection

-(GCStatsCalendarAggregationConfig *)calendarConfig{
    return self.multiFieldConfig.calendarConfig;
}

-(NSString*)activityType{
    return self.multiFieldConfig.activityType;
}
-(GCActivityType*)activityTypeDetail{
    return self.multiFieldConfig.activityTypeDetail;
}

-(gcGraphChoice)graphChoice{
    return self.multiFieldConfig.graphChoice;
}

-(void)setGraphChoice:(gcGraphChoice)graphChoice{
    self.multiFieldConfig.graphChoice = graphChoice;
}

-(BOOL)isEqualToConfig:(GCStatsOneFieldConfig*)other{
    return [self.field isEqualToField:other.field] && [self.x_field isEqualToField:other.x_field] &&
    self.secondGraphChoice == other.secondGraphChoice && self.viewChoice == other.viewChoice &&
    [self.multiFieldConfig isEqualToConfig:other.multiFieldConfig];
}

#pragma mark - View choices and config
/*
 * View choice will be monthly/weekly/yearly, should use icon for month/week/year
 * View Config will be last 3m, last 6m, last 1y, all, in text
 */
-(gcViewChoice)viewChoice{
    return self.multiFieldConfig.viewChoice;
}

-(NSString *)viewDescription{
    // Only cycle through calendar for view Choice in single field
    
    return [GCViewConfig viewChoiceDesc:gcViewChoiceCalendar calendarConfig:self.calendarConfig];
}

/**
 *  Viewchoice will be equivalent of calendar and only rotating through calendar unit
 */
-(bool)nextView{
    BOOL done = [self.calendarConfig nextCalendarUnit];
    if( self.calendarConfig.calendarUnit == kCalendarUnitNone){
        self.calendarConfig.calendarUnit = NSCalendarUnitWeekOfYear;
        done = true;
    }
    // Year should always use all
    if( self.calendarConfig.calendarUnit == NSCalendarUnitYear ){
        self.multiFieldConfig.viewConfig = gcStatsViewConfigAll;
    }
    
    return done;
}

/**
 *  Switch from
 *
 */

-(BOOL)nextViewConfig{
    return [self.multiFieldConfig nextViewConfigOnly];
}

-(UIBarButtonItem*)viewChoiceButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel{
    return [self.multiFieldConfig standardButtonSetupWithImage:nil orTitle:self.viewDescription target:target action:sel longPress:longPressSel];
}

-(UIBarButtonItem*)viewConfigButtonForTarget:(id)target action:(SEL)sel longPress:(SEL)longPressSel{
    UIImage * image = nil;
    NSString * title = nil;
    
    switch (self.multiFieldConfig.viewConfig) {
        case gcStatsViewConfigLast3M:
            image = [GCViewIcons navigationIconFor:gcIconNavQuarterly];
            break;
        case gcStatsViewConfigLast6M:
            image = [GCViewIcons navigationIconFor:gcIconNavSemiAnnually];
            break;
        case gcStatsViewConfigLast1Y:
            image = [GCViewIcons navigationIconFor:gcIconNavYearly];
            break;
        case gcStatsViewConfigAll:
        case gcStatsViewConfigUnused:
            image = nil;
            title = NSLocalizedString(@"All", @"View config");
            break;
    }
    
    // Same as multiConfig for now
    return [self.multiFieldConfig standardButtonSetupWithImage:image orTitle:title target:target action:sel longPress:longPressSel];
}

#pragma  mark - history data series

-(GCHistoryFieldDataSerieConfig*)historyConfig{
    GCHistoryFieldDataSerieConfig * rv = [GCHistoryFieldDataSerieConfig configWithField:self.field xField:nil filter:self.multiFieldConfig.useFilter fromDate:nil];
    //rv.fromDate = [self.multiFieldConfig selectAfterDateFrom:(NSDate *)]
    return rv;
}
-(GCHistoryFieldDataSerieConfig*)historyConfigXY{
    return [GCHistoryFieldDataSerieConfig configWithField:self.field xField:self.x_field filter:self.multiFieldConfig.useFilter fromDate:nil];

}



@end
