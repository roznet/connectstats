//  MIT License
//
//  Created on 01/01/2020 for ConnectStats
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



#import "GCConnectStatsActivityTCXParser.h"
#import "GCActivity+Import.h"

@interface GCConnectStatsActivityTCXParser ()
@property (nonatomic,retain) GCXMLElement * element;
@end

@implementation GCConnectStatsActivityTCXParser

-(void)dealloc{
    [_element release];
    [_activity release];
    [super dealloc];
}
+(instancetype)activityTCXParserWithActivityId:(NSString*)aId andData:(NSData*)thedata{
    GCConnectStatsActivityTCXParser * rv = RZReturnAutorelease([[self alloc] init]);
    if( rv ){
        rv.element = [GCXMLReader elementForData:thedata];
        for (GCXMLElement * activityElement in [rv.element findElements:@"Activity"]) {
            
            NSString * sport = [activityElement valueForParameter:@"Sport"];
            
            NSMutableArray * laps = [NSMutableArray array];
            NSMutableArray * trackpoints = [NSMutableArray array];
            
            for( GCXMLElement * lapElement in [activityElement findElements:@"Lap"]) {
                GCLap * lap = [[GCLap alloc] initWithTCXElement:lapElement];
                [laps addObject:lap];
                RZRelease(lap);
            }
            GCTrackPoint * prev = nil;
            for (GCXMLElement * pointElement in [activityElement findElements:@"Trackpoint"]) {
                GCTrackPoint * point = [[GCTrackPoint alloc] initWithTCXElement:pointElement];
                [trackpoints addObject:point];
                if( prev ){
                    [prev updateWithNextPoint:point];
                }
                RZRelease(prev);
                prev = point;
            }
            RZRelease(prev);
            
            GCActivity * one = RZReturnAutorelease([[GCActivity alloc] initWithId:aId]);
            if( [sport isEqualToString:@"Running"]){
                one.activityType = GC_TYPE_RUNNING;
            }else if ([sport isEqualToString:@"Biking"]){
                one.activityType = GC_TYPE_CYCLING;
            }

            if( one.activityType != nil ){
                one.activityTypeDetail = [GCActivityType activityTypeForKey:one.activityType];
                [one updateWithTrackpoints:trackpoints andLaps:laps];
                [one updateSummaryFromTrackpoints:trackpoints missingOnly:NO];
                rv.activity = one;
            }
        }
    }
    return rv;
}
@end
