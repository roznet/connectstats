//  MIT Licence
//
//  Created on 02/04/2013.
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
#import <RZUtils/GCStatsDataSerie.h>
#import <RZUtils/GCStatsDataSerieWithUnit.h>

@interface GCStatsDataSerieFilter : NSObject

@property (nonatomic,assign) BOOL filterMaxValue;
@property (nonatomic,assign) double maxValue;

@property (nonatomic,assign) BOOL filterMinValue;
@property (nonatomic,assign) double minValue;

@property (nonatomic,assign) BOOL filterHighAcceleration;
@property (nonatomic,assign) double maxAcceleration;
@property (nonatomic,assign) double maxAccelerationSpeedThreshold;

@property (nonatomic,assign) double ignore_dt;
@property (nonatomic,retain) GCUnit * unit;

-(GCStatsDataSerie*)filteredSerieFrom:(GCStatsDataSerie*)aSerie;
-(GCStatsDataSerieWithUnit*)filteredSerieWithUnitFrom:(GCStatsDataSerieWithUnit*)aSerie;

-(void)disableAll;

@end
