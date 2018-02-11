//  MIT Licence
//
//  Created on 19/10/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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
#import "GCTrackPoint.h"

#define GC_BEARING_FIELD @"Bearing"

@interface GCLap : GCTrackPoint

@property (nonatomic,readonly) NSDictionary<GCField*,GCNumberWithUnit*> * extra;
@property (nonatomic,assign) BOOL useMovingElapsed;
@property (nonatomic,assign) double movingElapsed;
@property (nonatomic,retain) NSString*label;

-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCLap*)initWithDictionary:(NSDictionary*)aDict forActivity:(GCActivity*)act NS_DESIGNATED_INITIALIZER;
-(GCLap*)initWithResultSet:(FMResultSet*)res NS_DESIGNATED_INITIALIZER;
-(GCLap*)initWithLap:(GCLap*)other NS_DESIGNATED_INITIALIZER;
-(GCLap*)initWithTrackPoint:(GCTrackPoint*)other NS_DESIGNATED_INITIALIZER;

-(void)addExtraFromResultSet:(FMResultSet*)res andActivityType:(NSString*)aType;

-(void)saveToDb:(FMDatabase*)trackdb;

-(void)accumulateLap:(GCLap*)other;
-(void)accumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to;
-(void)decumulateFrom:(GCTrackPoint*)from to:(GCTrackPoint*)to;
-(void)interpolate:(double)delta within:(GCLap*)diff;

-(void)difference:(GCTrackPoint*)from minus:(GCTrackPoint*)to;

-(void)augmentElapsed:(NSDate*)start inActivity:(GCActivity*)act;

-(void)updateExtra:(NSDictionary<GCField*,GCNumberWithUnit*>*)extra inActivity:(GCActivity*)act;
@end
