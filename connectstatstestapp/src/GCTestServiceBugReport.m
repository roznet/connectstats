//  MIT License
//
//  Created on 13/01/2018 for ConnectStatsTestApp
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "GCTestServiceBugReport.h"
#import "GCAppGlobal.h"
#import "GCSettingsBugReport.h"

@interface GCTestServiceBugReport ()
@property (nonatomic,retain) RZRemoteDownload * remoteDownload;
@end

@implementation GCTestServiceBugReport
-(void)dealloc{
    [_remoteDownload release];
    [super dealloc];
}
-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testBugReport)),
                TK_DESC:@"Try to send a bug report",
                TK_SESS:@"GC BugReport"},
              
              ];
}

-(void)testBugReport{

    [self startSession:@"GC BugReport"];

    [GCAppGlobal setupSampleState:@"sample_activities.db"];

    GCSettingsBugReport * report = [GCSettingsBugReport bugReport];
    report.includeActivityFiles = true;
    report.includeErrorFiles = true;
    
    NSString * url = [NSString stringWithFormat:@"%@/connectstats/bugreport.php?dir=bugs", [GCAppGlobal simulatorUrl]];
    
    [self setRemoteDownload:[[[RZRemoteDownload alloc] initWithURLRequest:[report urlResquestFor:url] andDelegate:self] autorelease]];
}

-(void)testBugReportEnd{
    [self endSession:@"GC BugReport"];
}

-(void)downloadFailed:(id)connection{
    RZ_ASSERT(false, @"Upload failed");
    [self testBugReportEnd];
}

-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{
    RZ_ASSERT(false, @"Upload failed");
    [self testBugReportEnd];
}
-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
    NSError * e = nil;
    NSString * htmlPath = [RZFileOrganizer writeableFilePath:@"bugreport.html"];
    [self log:@" Bug Report HTML Saved to %@", htmlPath];
    [theString writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&e];
    BOOL success = [theString rangeOfString:@"<input type=\"submit\" class=\"buttonbox\" value=\"submit\" id=\"submit_button\"/>"].location != NSNotFound;
    RZ_ASSERT(success, @"BugReport success %@", [theString hasPrefix:@"error:"] ? theString : @"");
    [self testBugReportEnd];
}

@end
