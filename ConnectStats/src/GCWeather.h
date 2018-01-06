//  MIT Licence
//
//  Created on 27/10/2013.
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define GC_WEATHER_ICON         @"weather-info-icon"
#define GC_WEATHER_FEELS_LIKE   @"weather-feels-like"
#define GC_WEATHER_INFO_ICON    @"weather-info-icon"
#define GC_WEATHER_HUMIDITY     @"weather-humidity"
#define GC_WEATHER_SOURCE       @"weather-source"
#define GC_WEATHER_WIND         @"weather-wind"
#define GC_WEATHER_TEMPERATURE  @"weather-temperature"

#define GC_WEATHER_NOT_RECORDED @"weather-not-recorded"

@class FMResultSet;
@class FMDatabase;

@interface GCWeather : NSObject

@property (nonatomic,assign) NSInteger weatherType;
@property (nonatomic,retain) NSDate * weatherDate;

@property (nonatomic,retain) GCNumberWithUnit * temperature;
@property (nonatomic,retain) GCNumberWithUnit * apparentTemperature;
@property (nonatomic,retain) GCNumberWithUnit * relativeHumidity;

@property (nonatomic,retain) NSNumber * windDirection;
@property (nonatomic,retain) GCNumberWithUnit * windSpeed;
@property (nonatomic,retain) NSString * windDirectionCompassPoint;

@property (nonatomic,retain) NSString * weatherStationId;
@property (nonatomic,retain) NSString * weatherStationName;
@property (nonatomic,assign) CLLocationCoordinate2D weatherStationLocation;

@property (nonatomic,retain) NSString * weatherTypeDesc;

+(GCWeather*)weatherWithData:(NSDictionary*)dict;
+(GCWeather*)weatherWithResultSet:(FMResultSet*)res;
+(void)ensureDbStructure:(FMDatabase*)db;
-(void)saveToDb:(FMDatabase*)db forActivityId:(NSString*)aId;

-(BOOL)valid;
-(RZImage*)weatherIcon;
-(NSString*)weatherDisplayField:(NSString*)key;
-(BOOL)weatherCompleteForDisplay;
-(BOOL)newFormat;

-(GCNumberWithUnit*)weatherStationDistanceFromCoordinate:(CLLocationCoordinate2D)coord;

@end
