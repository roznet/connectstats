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

#import <Foundation/Foundation.h>
#import "GCField.h"

/**
 Configuration option for extracting time series from activities.
 GCHistoryFieldDataSerie will use below.
 */
@interface GCHistoryFieldDataSerieConfig : NSObject

/**
 Main Field for the y values
 */
@property (nonatomic,retain) GCField * activityField;
/**
 If not nil, serie will use for x values from that field, else the date of the activity
 is the x axis.
 */
@property (nonatomic,retain) GCField * x_activityField;
/**
 if not nil, will restrict to activity of that type
 */
@property (nonatomic,retain) NSString * activityType;
/**
 If not nil, limit series for activities more recent than date
 */
@property (nonatomic,retain) NSDate   * fromDate;
/**
 YES if only process filtered activities, NO for all activities
 */
@property (nonatomic,assign) BOOL useFilter;
/**
 For health series, decide time to look back sum. If non zero the value for y will become
 The sum or average of the field for the last healthLookbackUnit amount of seconds
 */
@property (nonatomic,assign) NSTimeInterval healthLookbackUnit;

/**
 CutOff date for Year/Month to date calculations
 */
@property (nonatomic,retain) NSDate   * cutOff;
/**
 cutOffUnit for Year/Month to date calculations
 */
@property (nonatomic,assign) NSCalendarUnit cutOffUnit;

+(GCHistoryFieldDataSerieConfig*)configWithField:(GCField*)aField xField:(GCField*)xField;
+(GCHistoryFieldDataSerieConfig*)configWithField:(GCField*)yField xField:(GCField*)xField fromDate:(NSDate*)fromD;
+(GCHistoryFieldDataSerieConfig*)configWithField:(GCField*)yField xField:(GCField*)xField
                                          filter:(BOOL)useFilter fromDate:(NSDate*)fromD;

+(GCHistoryFieldDataSerieConfig*)configWithFilter:(BOOL)filter field:(GCField*)aField;
+(GCHistoryFieldDataSerieConfig*)configWithFilter:(BOOL)filter field:(GCField*)aField fromDate:(NSDate*)date;
+(GCHistoryFieldDataSerieConfig*)configWithFilter:(BOOL)filter yField:(GCField*)yField xField:(GCField*)xField;

+(GCHistoryFieldDataSerieConfig*)configWithConfig:(GCHistoryFieldDataSerieConfig*)other;

-(BOOL)isXY;
-(BOOL)isYOnly;

-(BOOL)isEqualToConfig:(GCHistoryFieldDataSerieConfig*)other;
@end
