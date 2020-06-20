//  MIT License
//
//  Created on 14/06/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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
#import "GCDerivedDataSerie.h"
#import "GCDerivedGroupedSeries.h"
#import "GCDerivedOrganizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCStatsDerivedAnalysisConfig : NSObject
@property (nonatomic,retain) GCDerivedOrganizer * derived;
/// Activity type used to filer series
@property (nonatomic,retain) NSString * activityType;
@property (nonatomic,retain,nullable) GCDerivedDataSerie * currentDerivedDataSerie;


+(GCStatsDerivedAnalysisConfig*)configForActivityType:(NSString*)activityType;

/// Goes to the next derivedSerie, stepping one by one
-(void)nextDerivedSerie;
/// Goes to the derivedSerie for the next field
-(void)nextDerivedSerieField;
-(NSArray<GCDerivedGroupedSeries*>*)availableDataSeries;

@end

NS_ASSUME_NONNULL_END
