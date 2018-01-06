//  MIT Licence
//
//  Created on 26/08/2014.
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

#import "GCHistoryFieldDataSerieConfig.h"

@implementation GCHistoryFieldDataSerieConfig


+(GCHistoryFieldDataSerieConfig*)configWithField:(GCField*)aField xField:(GCField*)xField{
    GCHistoryFieldDataSerieConfig * rv = [[[GCHistoryFieldDataSerieConfig alloc] init] autorelease];
    if (rv) {
        rv.activityField = aField;
        rv.activityType = aField.activityType;
        rv.x_activityField = xField;
        rv.fromDate = nil;
        rv.useFilter = false;


    }
    return rv;
}
+(GCHistoryFieldDataSerieConfig*)configWithField:(GCField*)yField xField:(GCField*)xField fromDate:(NSDate*)fromD{
    GCHistoryFieldDataSerieConfig * rv = [[[GCHistoryFieldDataSerieConfig alloc] init] autorelease];
    if (rv) {
        rv.activityField = yField;
        rv.x_activityField = xField;
        rv.activityType = yField.activityType;
        rv.fromDate = fromD;
        rv.useFilter = false;


    }
    return rv;
}
+(GCHistoryFieldDataSerieConfig*)configWithField:(GCField*)yField xField:(GCField*)xField
                                          filter:(BOOL)useFilter fromDate:(NSDate*)fromD{
    GCHistoryFieldDataSerieConfig * rv = [[[GCHistoryFieldDataSerieConfig alloc] init] autorelease];
    if (rv) {
        rv.activityField = yField;
        rv.activityType = yField.activityType;
        rv.x_activityField = xField;
        rv.fromDate = fromD;
        rv.useFilter = useFilter;

    }
    return rv;
}

+(GCHistoryFieldDataSerieConfig*)configWithFilter:(BOOL)filter field:(GCField*)aField{
    GCHistoryFieldDataSerieConfig * rv = [[[GCHistoryFieldDataSerieConfig alloc] init] autorelease];
    if (rv) {
        rv.activityField = aField;
        rv.activityType = aField.activityType;
        rv.x_activityField = nil;
        rv.fromDate = nil;
        rv.useFilter = filter;


    }
    return rv;
}
+(GCHistoryFieldDataSerieConfig*)configWithFilter:(BOOL)filter field:(GCField*)aField fromDate:(NSDate*)date{
    GCHistoryFieldDataSerieConfig * rv = [[[GCHistoryFieldDataSerieConfig alloc] init] autorelease];
    if (rv) {
        rv.activityField = aField;
        rv.activityType = aField.activityType;
        rv.x_activityField = nil;
        rv.fromDate = date;
        rv.useFilter = filter;

    }
    return rv;
}
+(GCHistoryFieldDataSerieConfig*)configWithFilter:(BOOL)filter yField:(GCField*)yField xField:(GCField*)xField{
    GCHistoryFieldDataSerieConfig * rv = [[[GCHistoryFieldDataSerieConfig alloc] init] autorelease];
    if (rv) {
        rv.activityField = yField;
        rv.activityType = yField.activityType;
        rv.x_activityField = xField;
        rv.fromDate = nil;
        rv.useFilter = filter;

    }
    return rv;
}

+(GCHistoryFieldDataSerieConfig*)configWithConfig:(GCHistoryFieldDataSerieConfig*)other{
    GCHistoryFieldDataSerieConfig * rv = [[[GCHistoryFieldDataSerieConfig alloc] init] autorelease];
    if (rv) {
        rv.activityField = other.activityField;
        rv.x_activityField = other.x_activityField;
        rv.fromDate = other.fromDate;
        rv.useFilter = other.useFilter;
        rv.cutOff = other.cutOff;
        rv.activityType = other.activityType;
        rv.cutOffUnit = other.cutOffUnit;
        rv.healthLookbackUnit = other.healthLookbackUnit;
    }
    return rv;
}
-(BOOL)isEqualToConfig:(GCHistoryFieldDataSerieConfig*)other{
    return (RZNilOrEqualToField(self.activityField, other.activityField) &&
            RZNilOrEqualToField(self.x_activityField, other.x_activityField) &&
            RZNilOrEqualToDate(self.fromDate, other.fromDate) &&
            RZNilOrEqualToDate(self.cutOff, other.cutOff) &&
            RZNilOrEqualToString(self.activityType, other.activityType) &&
            self.useFilter == other.useFilter &&
            self.cutOffUnit == other.cutOffUnit &&
            self.healthLookbackUnit == other.healthLookbackUnit);
}
-(void)dealloc{
    [_cutOff release];
    [_activityField release];
    [_x_activityField release];
    [_fromDate release];
    [_activityType release];
    [super dealloc];
}

-(BOOL)isXY{
    return _x_activityField != nil;
}
-(BOOL)isYOnly{
    return _x_activityField == nil;
}


@end
