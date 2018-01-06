//  MIT Licence
//
//  Created on 14/02/2014.
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

#import "GCTestTennis.h"
#import "GCActivityTennis.h"
#import "GCAppGlobal.h"
#import "GCActivityTennis.h"
#import "GCBabolatSessionsListRequest.h"
#import "GCBabolatSessionRequest.h"
#import "GCService.h"

@implementation GCTestTennis

-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testTennis)),
                TK_DESC:@"Test import of tennis session from babolat",
                TK_SESS:@"GC Tennis"}
              ];
}

-(void)testTennis{
	[self startSession:@"GC Tennis"];
    [GCAppGlobal cleanWritableFiles];
    [GCAppGlobal setupSampleState:@"sample_activities.db"];

    [self testParsing];

	[self endSession:@"GC Tennis"];

}


-(void)testParsing{
    NSError * err = nil;
    NSString * theString = [NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"babolat_sessions.json"] encoding:NSUTF8StringEncoding error:&err];

    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err ];
    if (!err) {
        GCBabolatSessionsListRequest * reqlist = [[GCBabolatSessionsListRequest alloc] init];
        [reqlist processJson:json];
        [reqlist release];


        GCActivity * foundact = [[GCAppGlobal organizer] activityForId:[[GCService service:gcServiceBabolat] activityIdFromServiceId:@"8669"]];
        GCActivityTennis * found = [foundact isKindOfClass:[GCActivityTennis class]] ? (GCActivityTennis*)foundact : nil;
        [self assessTrue:found!=nil msg:@"Registered tennis activity"];

        theString = [NSString stringWithContentsOfFile:[RZFileOrganizer bundleFilePath:@"babolat_session_8669.json"] encoding:NSUTF8StringEncoding error:&err];
        json = [NSJSONSerialization JSONObjectWithData:[theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err ];
        GCBabolatSessionRequest * reqses = [[GCBabolatSessionRequest alloc] init];
        reqses.sessionId = @"8669";
        [reqses processJson:json];
        [self assessTrue:[found availableShotTypes]!=nil msg:@"parsed shot types"];

        GCStatsDataSerieWithUnit * serie = [found cuePointDataSerie:@"totalStrokes"];
        NSLog(@"serie %@", serie);

        [reqses release];
    }

}
@end
