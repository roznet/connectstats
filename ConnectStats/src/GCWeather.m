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

#import "GCWeather.h"
#import "Flurry.h"
#import "GCAppGlobal.h"
#import "GCFields.h"

//"weather-not-recorded" = "...";
// or
//"weather-feels-like"  = "Feels like 13\U2103";
//"weather-humidity"    = "Humidity 72%";
//"weather-info-icon"   = "partly-cloudy";
//"weather-source"      = "Source: EGTC";
//"weather-temperature" = "13\U2103";
//"weather-wind"        = "14 km/h WSW wind";

//select weatherValue,count(weatherValue) from gc_activities_weather where weatherField='weather-info-icon' group by weatherValue;
//chance-of-showers|8
//fair|28
//mist|17
//partly-cloudy|41

NSString * kGCWeatherIconClearDay = @"clear-day";
NSString * kGCWeatherIconClearNight = @"clear-night";
NSString * kGCWeatherIconRain = @"rain";
NSString * kGCWeatherIconSnow = @"snow";
NSString * kGCWeatherIconSleet = @"sleet";
NSString * kGCWeatherIconWind = @"wind";
NSString * kGCWeatherIconFog = @"fog";
NSString * kGCWeatherIconCloudy = @"cloudy";
NSString * kGCWeatherIconPartlyCloudyDay = @"partly-cloudy-day";
NSString * kGCWeatherIconPartlyCloudyNight = @"partly-cloudy-night";
NSString * kGCWeatherIconHail = @"hail";
NSString * kGCWeatherIconThunderstorm = @"thunderstorm";
NSString * kGCWeatherIconTornado = @"tornado";
NSString * kGCWeatherIconHurricane = @"hurricane";

NS_INLINE double degreesToRadians(double x) { return (x * M_PI / 180.0); };
NS_INLINE double radiandsToDegrees(double x) { return(x * 180.0 / M_PI); };

static NSDictionary * _weatherIcons = nil;
static NSDictionary * _weatherTypes = nil;
static NSDictionary * _weatherIconToTypes = nil;

static void buildCache(){
    if(_weatherIcons==nil){
        _weatherTypes =  [[NSDictionary alloc] initWithDictionary:@{
                                                                    @(100): @[ @"Fair", @"fair" ],
                                                                    @(101): @[ @"Cloudy", @"cloudy" ],
                                                                    @(103): @[ @"Rain", @"chance-of-showers" ],
                                                                    @(105): @[ @"Fog", @"mist" ],
                                                                    @(106): @[ @"Drizzle", @"chance-of-showers" ],
                                                                    @(107): @[ @"Heavy Rain", @"chance-of-showers" ],

                                                                    @(200): @[ @"Light Rain", @"chance-of-showers" ],
                                                                    @(201): @[ @"Mist", @"mist" ],
                                                                    @(202): @[ @"Showers", @"chance-of-showers" ],
                                                                    @(203): @[ @"Thunderstorm", @"chance-of-thunderstorms" ],

                                                                    @(300): @[ @"Mostly Cloudy", @"partly-cloudy" ],
                                                                    @(301): @[ @"Mostly Clear", @"partly-cloudy" ],
                                                                    @(302): @[ @"Light Snow", @"chance-of-snow" ],
                                                                    @(303): @[ @"Partly Cloudy", @"partly-cloudy" ],
                                                                    @(305): @[ @"Haze", @"mist" ],
                                                                    }];

        _weatherIconToTypes = [[NSDictionary alloc] initWithDictionary:@{
            kGCWeatherIconClearDay : @(100),
            kGCWeatherIconClearNight : @(100),
            kGCWeatherIconRain : @(103),
            kGCWeatherIconSnow : @(302),
            kGCWeatherIconSleet : @(302),
            kGCWeatherIconWind : @(301),
            kGCWeatherIconFog : @(105),
            kGCWeatherIconCloudy : @(101),
            kGCWeatherIconPartlyCloudyDay : @(300),
            kGCWeatherIconPartlyCloudyNight : @(300),
            kGCWeatherIconHail :@(202),
            kGCWeatherIconThunderstorm : @(203),
            kGCWeatherIconTornado : @(203),
            kGCWeatherIconHurricane : @(203),
        }];
        
        _weatherIcons = [[NSDictionary alloc] initWithDictionary:@{
                          @"fair":                  @"861-sun-2",
                          @"partly-cloudy":         @"862-sun-cloud",
                          @"misty":                 @"863-cloud-2",
                          @"chance-of-showers":     @"864-rain-cloud"
                        }]  ;
    
    }
}

NSString * windDirectionToCompassPoint(double bearing){
    static NSArray * _windDirectionToCompass = nil;
    if( _windDirectionToCompass == nil){
        _windDirectionToCompass = [[NSArray alloc] initWithArray:@[
                       @"N",@0,@11.25,
                       @"NNE",@11.25,@33.75,
                       @"NE",@33.75,@56.25,
                       @"ENE",@56.25,@78.75,
                       @"E",@78.75,@101.25,
                       @"ESE",@101.25,@123.75,
                       @"SE",@123.75,@146.25,
                       @"SSE",@146.25,@168.75,
                       @"S",@168.75,@191.25,
                       @"SSW",@191.25,@213.75,
                       @"SW",@213.75,@236.25,
                       @"WSW",@236.25,@258.75,
                       @"W",@258.75,@281.25,
                       @"WNW",@281.25,@303.75,
                       @"NW",@303.75,@326.25,
                       @"NNW",@326.25,@348.75,
                       @"N",@348.75,@360,
      ] ];
    }
    
    for( NSUInteger i=0;i<_windDirectionToCompass.count;i+=3){
        NSString * dir = _windDirectionToCompass[i];
        double from = [_windDirectionToCompass[i+1] doubleValue];
        double to   = [_windDirectionToCompass[i+2] doubleValue];
        
        if( bearing >= from && bearing <= to){
            return dir;
        }
    }
    return @"N/A";
}

@interface GCWeather ()
@property (nonatomic,retain) NSMutableDictionary * weatherData;


@end

@implementation GCWeather

/*
 {
 "activityId" : 422317143,
 "weatherPk" : 15931133,
 "issueDate" : 1388062500000,
 "temp" : 9,
 "apparentTemp" : -13,
 "dewPoint" : 7,
 "relativeHumidity" : 92,
 "windDirection" : 60,
 "windDirectionCompassPoint" : "ene",
 "windSpeed" : 25,
 "latitude" : 45.9333,
 "longitude" : 7.6999998,
 "weatherStationDTO" : {
 "weatherStationPk" : 1132,
 "id" : "LIMH",
 "name" : "Pian Rosa",
 "timezone" : null
 },
 "weatherTypeDTO" : {
 "weatherTypePk" : 302,
 "desc" : "Light Snow",
 "image" : "007.png"
 }
 }
 
 {
 "latitude" : 51.47168,
 "longitude" : -0.19566,
 "timezone" : "Europe/London",
 "currently" : {
   "time" : 1566033386,
   "summary" : "Partly Cloudy",
   "icon" : "partly-cloudy-day",
   "precipIntensity" : 0,
   "precipProbability" : 0,
   "temperature" : 18.78,
   "apparentTemperature" : 18.78,
   "dewPoint" : 12.89,
   "humidity" : 0.69,
   "pressure" : 1005.21,
   "windSpeed" : 5.26,
   "windGust" : 10.05,
   "windBearing" : 232,
   "cloudCover" : 0.35,
   "uvIndex" : 3,
   "visibility" : 10.013,
   "ozone" : 315.2
 },

 */



-(void)parseConnectStats:(NSDictionary*)dict{
    buildCache();
    NSNumber * innumber = nil;
    NSString * instring = nil;

    NSDictionary * currently = dict[@"currently"];
    
    if ([currently isKindOfClass:[NSDictionary class]]) {
        instring = currently[@"icon"];
        self.weatherType = [_weatherIconToTypes[instring] integerValue];
        instring = currently[@"summary"];
        if (instring && [instring isKindOfClass:[NSString class]]) {
            self.weatherTypeDesc = instring;
        }
    }else{
        self.weatherType = 0;
        self.weatherTypeDesc = nil;
    }

    innumber = currently[@"time"];
    if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
        self.weatherDate = [NSDate dateWithTimeIntervalSince1970:innumber.doubleValue];
    }

    innumber = currently[@"temperature"];
    if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
        self.temperature = [[GCNumberWithUnit numberWithUnitName:@"celcius" andValue:innumber.doubleValue] convertToUnitName:STOREUNIT_TEMPERATURE];
    }

    innumber = currently[@"apparentTemperature"];
    if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
        self.apparentTemperature = [[GCNumberWithUnit numberWithUnitName:@"celcius" andValue:innumber.doubleValue] convertToUnitName:STOREUNIT_TEMPERATURE];
    }

    innumber = currently[@"windBearing"];
    if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
        self.windDirection = innumber;
        self.windDirectionCompassPoint = windDirectionToCompassPoint(innumber.doubleValue);
    }

    innumber = currently[@"windSpeed"];
    if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
        self.windSpeed = [[GCNumberWithUnit numberWithUnitName:@"mph" andValue:innumber.doubleValue] convertToUnitName:STOREUNIT_SPEED];
    }

    innumber = dict[@"humidity"];
    if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
        self.relativeHumidity = [GCNumberWithUnit numberWithUnitName:@"percent" andValue:innumber.doubleValue];
    }

    CLLocationCoordinate2D coord;
    innumber = dict[@"latitude"];
    if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
        coord.latitude = innumber.doubleValue;
        innumber = dict[@"longitude"];
        if (innumber && [innumber isKindOfClass:[NSNumber class]]) {
            coord.longitude = innumber.doubleValue;
            self.weatherStationLocation = coord;
        }
    }
}

+(GCWeather*)weatherWithData:(NSDictionary*)dict{
    GCWeather * rv = [[[GCWeather alloc] init] autorelease];
    if (rv) {
        if (dict[GC_WEATHER_ICON] != nil) {
            rv.weatherData = [NSMutableDictionary dictionaryWithDictionary:dict];
        }else{
            [rv parseConnectStats:dict];
        }
    }
    return rv;
}

-(void)dealloc{
    [_weatherDate release];
    [_temperature release];
    [_apparentTemperature release];
    [_relativeHumidity release];
    [_windDirection release];
    [_windSpeed release];
    [_windDirectionCompassPoint release];
    [_weatherTypeDesc release];
    [_weatherData release];
    [super dealloc];
}
+(GCWeather*)weatherWithResultSet:(FMResultSet*)res{
    GCWeather * rv = [[[GCWeather alloc] init] autorelease];
    if (rv) {
        rv.weatherDate = [res dateForColumn:@"weatherDate"];
        rv.weatherType = [res intForColumn:@"weatherType"];
        rv.weatherTypeDesc = [res stringForColumn:@"weatherTypeDesc"];
        rv.temperature = [GCNumberWithUnit numberWithUnitName:STOREUNIT_TEMPERATURE andValue:[res doubleForColumn:@"temperature"]];
        rv.apparentTemperature = [GCNumberWithUnit numberWithUnitName:STOREUNIT_TEMPERATURE andValue:[res doubleForColumn:@"apparentTemperature"]];
        rv.relativeHumidity = [GCNumberWithUnit numberWithUnitName:@"percentage" andValue:[res doubleForColumn:@"relativeHumidity"]];
        if ([res columnIsNull:@"windDirection"]) {
            rv.windDirection = nil;
        }else{
            rv.windDirection = @([res doubleForColumn:@"windDirection"]);
        }
        if ([res columnIsNull:@"windSpeed"]) {
            rv.windSpeed = nil;
        }else{
            rv.windSpeed = [GCNumberWithUnit numberWithUnitName:STOREUNIT_SPEED andValue:[res doubleForColumn:@"windSpeed"]];
        }
        rv.windDirectionCompassPoint = [res stringForColumn:@"windDirectionCompassPoint"];
        CLLocationCoordinate2D coord;
        coord.latitude = [res doubleForColumn:@"latitude"];
        coord.longitude = [res doubleForColumn:@"longitude"];
        rv.weatherStationLocation = coord;

    }
    return rv;
}

-(void)saveToDb:(FMDatabase*)db forActivityId:(NSString*)aId{
    if (aId) {
        if ([self newFormat]) {
            [db executeUpdate:@"DELETE FROM gc_activities_weather WHERE activityId = ?",aId];

            RZEXECUTEUPDATE(db, @"INSERT OR REPLACE INTO gc_activities_weather_detail (activityId, weatherDate, weatherType, weatherTypeDesc, temperature, apparentTemperature, relativeHumidity, windDirection, windSpeed, windDirectionCompassPoint, weatherStationId, weatherStationName, latitude, longitude) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                            aId,
                            self.weatherDate ? self.weatherDate : [NSNull null],
                            @(self.weatherType),
                            self.weatherTypeDesc,
                            self.temperature ? [self.temperature number] : [NSNull null],
                            self.apparentTemperature ? [self.apparentTemperature number] : [NSNull null],
                            self.relativeHumidity ? [self.relativeHumidity number] : [NSNull null],
                            self.windDirection ? self.windDirection : [NSNull null],
                            self.windSpeed ? [self.windSpeed number] : [NSNull null],
                            self.windDirectionCompassPoint ? self.windDirectionCompassPoint : [NSNull null],
                            [NSNull null],
                            [NSNull null],
                            @(self.weatherStationLocation.latitude),
                            @(self.weatherStationLocation.longitude)

                            );

        }else{
            [db executeUpdate:@"DELETE FROM gc_activities_weather WHERE activityId = ?",aId];
            [db beginTransaction];
            for (NSString * key in self.weatherData) {
                id val = (self.weatherData)[key];
                if ([val isKindOfClass:[NSString class]]) {
                    NSString * valstr = (NSString*)val;
                    if (![db executeUpdate:@"INSERT INTO gc_activities_weather (activityId,weatherField,weatherValue) VALUES(?,?,?)", aId,key,valstr]){
                        RZLog(RZLogError, @"db error %@", [db lastErrorMessage]);
                    }
                }
            }
            if (![db commit]) {
                RZLog(RZLogError, @"db error %@", [db lastErrorMessage]);
            }
        }
    }
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_activities_weather_detail"]) {
        RZEXECUTEUPDATE(db, @"CREATE TABLE gc_activities_weather_detail (activityId TEXT PRIMARY KEY, weatherDate REAL, weatherType INT DEFAULT 0, weatherTypeDesc TEXT, temperature REAL, apparentTemperature REAL, relativeHumidity REAL, windDirection REAL, windSpeed REAL, windDirectionCompassPoint TEXT, weatherStationId TEXT, weatherStationName TEXT, latitude REAL, longitude REAL)");

    }
}

-(BOOL)newFormat{
    return self.weatherData == nil && self.weatherType != 0;
}

-(BOOL)valid{
    if (self.weatherData == nil && self.weatherType != 0) {
        return true; // new format
    }
    return self.weatherData && (self.weatherData)[GC_WEATHER_ICON];
}

-(NSString*)weatherDisplayField:(NSString*)key{
    NSString * val = nil;
    if ([self newFormat]) {
        gcUnitSystem system = [GCFields fieldUnitSystem];
        if ([key isEqualToString:GC_WEATHER_TEMPERATURE]) {
            val = [self.temperature convertToSystem:system].description;
        }else if ([key isEqualToString:GC_WEATHER_WIND]){
            if (self.windDirection == nil || [self.windDirectionCompassPoint isEqualToString:@"N/A"]) {
                val = [NSString stringWithFormat:@"%@ wind", [[self.windSpeed convertToUnitName:@"kph"] convertToSystem:system]
                       ];

            }else{
                val = [NSString stringWithFormat:@"%@ %@ wind", [[self.windSpeed convertToUnitName:@"kph"] convertToSystem:system], (self.windDirectionCompassPoint).uppercaseString
                   ];
            }
        }else if([key isEqualToString:GC_WEATHER_ICON]){
            return self.weatherTypeDesc;
        }
    }else{
        val = self.weatherData[key];
    }
    return val;
}

-(BOOL)weatherCompleteForDisplay{
    if ([self newFormat]) {
        return self.weatherType != 0;
    }else{
        return (self.weatherData)[GC_WEATHER_TEMPERATURE] &&
        (self.weatherData)[GC_WEATHER_WIND] &&
        (self.weatherData)[GC_WEATHER_ICON];
    }

}

-(UIImage*)weatherIcon{
    buildCache();
    UIImage * rv = nil;
    if ([self newFormat]) {
        NSUInteger ntype = self.weatherType;
        NSArray * defs = _weatherTypes[@(ntype)];
        if (defs) {
            rv = [UIImage imageNamed:defs[1]];
        }else{
            NSString * missing = [NSString stringWithFormat:@"%d(%@)", (int)self.weatherType, self.weatherTypeDesc];
            RZLog(RZLogInfo, @"Missing weather icon type %@", missing);
#ifdef GC_USE_FLURRY
            [Flurry logEvent:@"missingWeatherIcon" withParameters:@{GC_WEATHER_ICON:missing}];
#endif

        }

    }else{
        NSString * key = (self.weatherData)[GC_WEATHER_ICON];
        if (key) {
            rv = [UIImage imageNamed:key];
            if (!rv) {
                NSString * desc = _weatherIcons[key];
                if (desc) {
                    rv = [UIImage imageNamed:desc];
                }
            }
        }
        if (rv == nil) {
            RZLog(RZLogInfo, @"Missing weather icon %@", key);
#ifdef GC_USE_FLURRY
            [Flurry logEvent:@"missingWeatherIcon" withParameters:@{GC_WEATHER_ICON:key?:@"unknown"}];
#endif
        }

    }
    return rv;
}

-(float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);

    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));

    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

-(NSString*)description{
    if (self.newFormat) {
        return [NSString stringWithFormat:@"<GCWeather: %@ %@ Wind %@ %@>",
                self.weatherTypeDesc,
                self.temperature,
                [self.windSpeed convertToUnitName:@"kph"],
                 (self.windDirectionCompassPoint).uppercaseString
                ];
    }else{
        return [NSString stringWithFormat:@"<GCWeather: %@ %@ %@>", self.weatherData[GC_WEATHER_INFO_ICON],
                self.weatherData[GC_WEATHER_TEMPERATURE],
                self.weatherData[GC_WEATHER_WIND]
                ];
    }
}

-(GCNumberWithUnit*)weatherStationDistanceFromCoordinate:(CLLocationCoordinate2D)coord{
    CLLocation * from = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
    CLLocation * to   = [[CLLocation alloc] initWithLatitude:self.weatherStationLocation.latitude longitude:self.weatherStationLocation.longitude];
    GCNumberWithUnit * rv = [GCNumberWithUnit numberWithUnitName:@"meter" andValue:[from distanceFromLocation:to]];
    [from release];
    [to release];

    return rv;
}
@end
