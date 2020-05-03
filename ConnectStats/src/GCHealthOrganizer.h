//  MIT Licence
//
//  Created on 26/02/2013.
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
#import "GCHealthMeasure.h"
#import "GCFields.h"
#import "GCField.h"
#import "GCHealthZone.h"

@class GCHealthZoneCalculator;

@interface GCHealthOrganizer : NSObject

@property (nonatomic,retain) NSArray * measures;
@property (nonatomic,retain) NSDictionary * zones;
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) NSArray * sleepBlocks;
@property (nonatomic,retain) dispatch_queue_t worker;
@property (nonatomic,assign) gcHealthZoneSource preferredSource;

-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCHealthOrganizer*)initWithDb:(FMDatabase*)db andThread:(dispatch_queue_t)thread NS_DESIGNATED_INITIALIZER;

-(GCHealthOrganizer*)initForTest NS_DESIGNATED_INITIALIZER;

+(void)ensureDbStructure:(FMDatabase*)db;

-(BOOL)addHealthMeasure:(GCHealthMeasure*)one;
-(void)addSleepBlocks:(NSArray*)blocks;
-(GCHealthMeasure*)measureForId:(NSString*)aId andField:(GCField*)field;
-(GCStatsDataSerieWithUnit*)dataSerieWithUnitForHealthField:(GCField*)field;

-(NSArray<GCHealthMeasure*>*)measuresForDate:(NSDate*)aDate;
-(GCHealthMeasure*)measureOnSpecificDate:(NSDate*)aDate forField:(GCField*)aField andCalendar:(NSCalendar*)calendar;
-(GCHealthMeasure*)measureForDate:(NSDate*)aDate andField:(GCField*)aField;

-(void)updateForNewProfile;
-(void)clearAllMeasures;


/**
 Find zone calculator for field. Will try matching type or ALL type
 and use first preferred source
 */
-(GCHealthZoneCalculator*)zoneCalculatorForField:(GCField*)field;

/**
 Find zone calculator matching field and source only.
 */
-(GCHealthZoneCalculator*)zoneCalculatorForField:(GCField *)field andSource:(gcHealthZoneSource)source;
/**
 Register new zone data and save to db
 The keys of the dictionary needs to be build with [GCHealthZoneCalculator keyForField]
 */
-(void)registerZoneCalculators:(NSDictionary<NSString*,GCHealthZoneCalculator*>*)data;
-(NSArray<NSString*>*)availableZoneCalculatorsSources;
-(NSArray<GCHealthZoneCalculator*>*)availableZoneCalculatorsForSource:(gcHealthZoneSource)source;

-(BOOL)hasHealthData;
-(BOOL)hasZoneData;

-(void)clearAllZones;
-(void)forceZoneRefresh;

//-(void)defaultZoneCalculatorFromHistory;
-(void)addDefaultZoneCalculatorTo:(NSMutableDictionary*)dict;

@end
