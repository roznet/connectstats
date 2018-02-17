//  MIT Licence
//
//  Created on 16/12/2012.
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

#import "GCTrackPoint.h"
#import "GCFields.h"

@interface GCTrackPointSwim : GCTrackPoint

@property (nonatomic,assign) gcSwimStrokeType directSwimStroke;
@property (nonatomic,retain) NSMutableDictionary<GCField*,GCNumberWithUnit*> * values;
@property (nonatomic,assign) NSUInteger lengthIdx;

-(instancetype)init NS_DESIGNATED_INITIALIZER;
-(GCTrackPointSwim*)initWithResultSet:(FMResultSet*)res NS_DESIGNATED_INITIALIZER;
-(GCTrackPoint*)initWithDictionary:(NSDictionary*)aDict forActivity:(GCActivity*)act NS_DESIGNATED_INITIALIZER;
-(GCTrackPointSwim*)initWithTrackPoint:(GCTrackPoint*)other NS_DESIGNATED_INITIALIZER;

-(void)updateValueFromResultSet:(FMResultSet*)res inActivity:(GCActivity*)act;

//-(NSDictionary*)extra;

-(BOOL)active;

-(void)fixupDrillData:(NSDate*)time inActivity:(GCActivity*)act;

@end
