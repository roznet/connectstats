//  MIT Licence
//
//  Created on 20/12/2012.
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

#import "GCGarminActivityRequest.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityXMLParser.h"
#import "GCActivitiesOrganizer.h"
#import "GCActivitiesOrganizer.h"

#pragma mark -
@implementation GCGarminActivityRequest
@synthesize activityId;

-(instancetype)init{
    return [super init];
}
-(GCGarminActivityRequest*)initWithId:(NSString *)aId{
    self = [super init];
    if (self) {
        self.activityId = aId;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
    }
    return self;
}

-(void)dealloc{
    [activityId release];
    [super dealloc];
}

-(NSString*)description{
    switch (self.stage) {
        case gcRequestStageDownload:
            return NSLocalizedString(@"Downloading track points", @"Request Description");
            break;
        case gcRequestStageParsing:
            return NSLocalizedString( @"Parsing track points", @"Request Description");
            break;
        case gcRequestStageSaving:
            return NSLocalizedString( @"Saving track points", @"Request Description");
            break;
    }
}

-(NSString*)url{
    return GCWebActivityURL(self.activityId);
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"activity_%@.tcx", self.activityId];
    if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
    };
#endif
    self.stage = gcRequestStageParsing;
    [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
    dispatch_async([GCAppGlobal worker],^(){
        [self processParse];
    });
}

-(void)processParse{
    if ([self checkNoErrors]) {
        GCGarminActivityXMLParser * parser = [[[GCGarminActivityXMLParser alloc] initWithString:self.theString andEncoding:self.encoding] autorelease];
        if (parser.success) {
            self.stage = gcRequestStageSaving;
            [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
            self.status = GCWebStatusOK;
            [[GCAppGlobal organizer] registerActivity:self.activityId withTrackpoints:parser.trackPoints andLaps:parser.laps];
        }else{
            NSError * e = nil;
            NSString * fn = [NSString stringWithFormat:@"error_activity_%@.tcx", self.activityId];
            if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
                RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
            }
            self.status = GCWebStatusParsingFailed;
        }
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

@end
