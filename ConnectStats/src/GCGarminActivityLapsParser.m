//  MIT Licence
//
//  Created on 29/09/2013.
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

#import "GCGarminActivityLapsParser.h"
#import "GCActivity.h"
#import "GCLap.h"
#import "GCActivity+Import.h"

@interface GCGarminActivityLapsParser ()
@property (nonatomic,retain) NSArray<GCLap*> * laps;
@property (nonatomic,retain) NSArray<GCTrackPoint*> * trackPointSwim;
@property (nonatomic,retain) NSArray<GCLap*> * lapsSwim;
@property (nonatomic,retain) GCActivity * activity;
@end

@implementation GCGarminActivityLapsParser

-(instancetype)init{
    return [self initWithData:nil forActivity:nil];
}
-(void)dealloc{
    [_laps release];
    [_trackPointSwim release];
    [_lapsSwim release];
    [_activity release];
    [super dealloc];
}

-(GCGarminActivityLapsParser*)initWithData:(NSData *)jsonData forActivity:(GCActivity *)act{
    self = [super init];
    if (self) {
        NSError * e=nil;

        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];

        if (json==nil) {
            self.laps = nil;
            self.status = GCWebStatusParsingFailed;
            RZLog(RZLogError, @"parsing failed %@", e);
        }else{
            NSArray * foundLaps = json[@"lapDTOs"];
            if ([foundLaps isKindOfClass:[NSArray class]]) {
                NSMutableArray * laps = [NSMutableArray arrayWithCapacity:foundLaps.count];
                NSMutableArray * lapsSwim = nil;
                NSMutableArray * swimPoints = nil;

                NSUInteger lapIdx = 0;
                
                for (NSDictionary * one in foundLaps) {
                    if([one isKindOfClass:[NSDictionary class]]){
                        NSArray * lengths = one[@"lengthDTOs"];
                        if ([lengths isKindOfClass:[NSArray class]] && lengths.count > 0) {
                            GCLap * lap = [[GCLap alloc] initWithDictionary:one forActivity:act];
                            lap.lapIndex = lapIdx;

                            if(lapsSwim == nil){
                                lapsSwim = [NSMutableArray array];
                            }
                            if (swimPoints==nil) {
                                swimPoints = [NSMutableArray array];
                            }
                            for (NSDictionary * length in lengths) {
                                if ([length isKindOfClass:[NSDictionary class]]) {
                                    GCTrackPoint * swim = [[GCTrackPoint alloc] initWithDictionary:length forActivity:act];
                                    swim.lapIndex = lapIdx;
                                    [swimPoints addObject:swim];
                                    [swim release];                                    
                                }
                            }
                            [lapsSwim addObject:lap];
                            [lap release];
                        }else{
                            GCLap * lap = [[GCLap alloc] initWithDictionary:one forActivity:act];
                            lap.lapIndex = lapIdx;
                            [laps addObject:lap];
                            [lap release];
                        }
                        lapIdx++;
                    }
                }
                self.laps = laps;
                self.lapsSwim = lapsSwim.count > 0 ? lapsSwim : nil;
                self.trackPointSwim = swimPoints.count > 0 ? swimPoints : nil;
                self.status = GCWebStatusOK;
            }
        }
    }
    return self;
}


@end
