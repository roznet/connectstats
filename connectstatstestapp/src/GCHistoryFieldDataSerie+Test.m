//  MIT Licence
//
//  Created on 21/07/2013.
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

#import "GCHistoryFieldDataSerie+Test.h"
#import "GCHealthMeasure.h"
#import "GCFields.h"

@implementation GCHistoryFieldDataSerie (Test)
//select * from gc_activities a, gc_activities_meta m where a.activityId = m.activityId and field = 'activityType' and key='resort_skiing_snowboarding' limit 10;
//

// return uom
-(GCStatsDataSerieWithUnit*)addFromDb:(GCField*)field toSerie:(GCStatsDataSerieWithUnit*)serie filter:(GCHistoryTestFilterBlock)filter{
    NSString * query = @"SELECT v.*, activityType, BeginTimestamp FROM gc_activities_values v, gc_activities a WHERE a.activityId=v.activityId AND v.field=? AND a.activityType = ? ORDER BY BeginTimestamp DESC";
    FMResultSet * res = nil;
    if ([field isHealthField]) {
        NSString * col = [field.key substringFromIndex:[GC_HEALTH_PREFIX length]];
        query = @"select measureDate as BeginTimeStamp, measureValue as value,'kilogram' as uom from gc_health_measures where measureType=? order by measureDate DESC;";
        res = [self.db executeQuery:query,col];
    }else if ([self.config.activityTypeDetail isEqualToActivityType:GCActivityType.all]) {
        query = @"SELECT v.*, activityType, BeginTimestamp FROM gc_activities_values v, gc_activities a WHERE a.activityId=v.activityId AND v.field=? ORDER BY BeginTimestamp DESC";
        res = [self.db executeQuery:query,field.key];
    }else{
        res = [self.db executeQuery:query,field.key, self.config.activityTypeDetail.primaryActivityType.key];
    }

    while ([res next]) {
        GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnitName:[res stringForColumn:@"uom"] andValue:[res doubleForColumn:@"value"]];
        NSDate * date = [res dateForColumn:@"BeginTimestamp"];
        if( !filter || filter( date )){
            NSLog(@"%@ in", date);
            [serie addNumberWithUnit:nu forDate:date];
        }else{
            NSLog(@"%@ out", date);
        }
    }
    return serie;
}

-(void)loadFromDb:(GCHistoryTestFilterBlock)filter{
    self.dataLock = true;
    [self setHistory:[[[GCStatsDataSerieWithUnit alloc] init] autorelease]];
    [self addFromDb:self.config.activityField toSerie:self.history filter:filter];
    if (self.config.x_activityField) {
        GCStatsDataSerieWithUnit * xSerie = [[[GCStatsDataSerieWithUnit alloc] init] autorelease];
        [self addFromDb:self.config.x_activityField toSerie:xSerie filter:filter];

        if ([self.config.x_activityField isHealthField]) {
            GCStatsInterpFunction * f = [GCStatsInterpFunction interpFunctionWithSerie:xSerie.serie];
            xSerie.serie = [f valueForXIn:self.history.serie];
        }

        [GCStatsDataSerie reduceToCommonRange:self.history.serie and:xSerie.serie];
        [self setGradientSerie:self.history];
        [self setGradientFunction:[GCStatsScaledFunction scaledFunctionWithSerie:self.gradientSerie.serie]];
        [self.gradientFunction setScale_x:true];

        GCStatsInterpFunction * interp = [GCStatsInterpFunction interpFunctionWithSerie:xSerie.serie];
        GCStatsDataSerie * xy = [interp xySerieWith:self.history.serie];
        self.history.serie = xy;
        self.history.xUnit = xSerie.unit;

    }else{
        [self setGradientFunction:nil];
        [self setGradientSerie:nil];
    }
    self.dataLock = false;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self notify];
    });
}


@end
