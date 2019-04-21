//  MIT Licence
//
//  Created on 11/08/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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
#import "GCHealthZoneCalculator.h"
#import "GCTrackStats.h"
#import "GCField.h"

@interface GCTrackFieldChoiceHolder : NSObject<NSSecureCoding>
@property (nonatomic,retain) GCField * field;
@property (nonatomic,retain) GCField * x_field;
@property (nonatomic,assign) NSUInteger movingAverage;
@property (nonatomic,retain) GCHealthZoneCalculator * zoneCalculator;
@property (nonatomic,assign) gcTrackStatsStyle statsStyle;

+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField*)field xField:(GCField*)xField;
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField*)f xField:(GCField*)xf movingAverage:(NSUInteger)ma;
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField*)f zone:(GCHealthZoneCalculator*)z;
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(GCField*)f style:(gcTrackStatsStyle)style ;

+(GCTrackFieldChoiceHolder*)trackFieldChoice:(gcFieldFlag)f xField:(gcFieldFlag)xf movingAverage:(NSUInteger)ma type:(NSString*)aT;
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(gcFieldFlag)f zone:(GCHealthZoneCalculator*)z type:(NSString*)aT;
+(GCTrackFieldChoiceHolder*)trackFieldChoice:(gcFieldFlag)f style:(gcTrackStatsStyle)style type:(NSString*)aT;

+(GCTrackFieldChoiceHolder*)trackFieldChoiceComparing:(GCActivity*)compare timeAxis:(BOOL)timeAxis;

-(void)setupTrackStats:(GCTrackStats*)trackStats;

@end

