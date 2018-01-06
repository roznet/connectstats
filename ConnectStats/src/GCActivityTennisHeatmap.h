//  MIT Licence
//
//  Created on 17/05/2014.
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

typedef NS_ENUM(NSUInteger, gcHeatmapLocation) {
    gcHeatmapLocationCenter,
    gcHeatmapLocationUp,
    gcHeatmapLocationDown,
    gcHeatmapLocationLeft,
    gcHeatmapLocationRight,
    gcHeatmapLocationEnd,
};

@class FMResultSet;
@class FMDatabase;

#define GC_HEATMAP_ALL @"all"

@interface GCActivityTennisHeatmap : NSObject
@property (nonatomic,retain) NSArray * heatmap;

+(GCActivityTennisHeatmap*)heatmapForJson:(NSDictionary*)dict;
+(GCActivityTennisHeatmap*)heatmapForResultSet:(FMResultSet*)res;
-(void)saveToDb:(FMDatabase*)db forId:(NSString*)aId andType:(NSString*)aType;

-(GCNumberWithUnit*)valueForLocation:(gcHeatmapLocation)loc;

//type: forehand|backhand|...
//loc:  left|up|...
+(BOOL)isHeatmapField:(NSString*)field;
+(NSString*)heatmapField:(NSString*)type location:(gcHeatmapLocation)location;
+(NSString*)heatmapFieldType:(NSString*)field;
+(gcHeatmapLocation)heatmapFieldLocation:(NSString*)field;

@end
