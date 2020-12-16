//  MIT Licence
//
//  Created on 26/01/2014.
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
#import "GCFields.h"
#import "sqlite3.h"
@class GCActivity;
@class GCField;
@class GCDerivedDataSerie;

typedef BOOL (^GCDerivedDataSerieMatchBlock)(GCDerivedDataSerie*ds);

typedef NS_ENUM(NSUInteger, gcDerivedPeriod) {
    gcDerivedPeriodAll,
    gcDerivedPeriodMonth,
    gcDerivedPeriodYear
};

typedef NS_ENUM(NSUInteger, gcDerivedType) {
    gcDerivedTypeBestRolling,
    gcDerivedTypeTimeInZone
};

extern sqlite3_int64 kInvalidSerieId;

@interface GCDerivedDataSerie : NSObject<NSSecureCoding>
@property (nonatomic,readonly) gcDerivedType derivedType;
@property (nonatomic,readonly) gcDerivedPeriod derivedPeriod;

@property (nonatomic,readonly) NSString * activityType;
@property (nonatomic,readonly) gcFieldFlag fieldFlag;
@property (nonatomic,readonly) GCField * field;
@property (nonatomic,readonly) NSDate* bucketStart;
@property (nonatomic,readonly) NSString * key;
@property (nonatomic,readonly) NSString * bucketKey;
@property (nonatomic,readonly) GCStatsDataSerieWithUnit * serieWithUnit;
@property (nonatomic,retain) NSString * fileNamePrefix;

+(GCDerivedDataSerie*)derivedDataSerie:(gcDerivedType)type
                                 field:(GCField*)field
                                period:(gcDerivedPeriod)period
                               forDate:(NSDate*)date;

+(GCDerivedDataSerie*)derivedDataSerieFromResultSet:(FMResultSet*)res;

-(void)reset;
-(void)operate:(gcStatsOperand)operand with:(GCStatsDataSerieWithUnit*)other from:(GCActivity*)activity;

-(BOOL)dependsOnSerie:(GCDerivedDataSerie*)other;
-(BOOL)containsActivity:(GCActivity*)act;
-(NSArray<GCActivity*>*)containedActivitiesIn:(NSArray<GCActivity*>*)activities;

-(BOOL)saveToDb:(FMDatabase*)db;

-(void)loadFromFileIfNeeded;
-(BOOL)saveToFile;
-(void)clearDataAndFile;

+(void)ensureDbStructure:(FMDatabase*)db;

-(BOOL)isEmpty;

@end

