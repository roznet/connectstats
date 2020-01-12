//  MIT Licence
//
//  Created on 15/01/2013.
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

#import "GCGarminRequestActivityReload.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCGarminActivitySummaryParser.h"
#import "GCActivity+Import.h"
#import "GCActivitiesOrganizer.h"

@implementation GCGarminRequestActivityReload
@synthesize activityId;

-(instancetype)init{
    return [super init];
}

-(GCGarminRequestActivityReload*)initWithId:(NSString *)aId{
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
-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: %@ %@>",
            NSStringFromClass([self class]),
            self.activityId,
            [self.urlDescription truncateIfLongerThan:192 ellipsis:@"..."] ];
}

-(NSString*)description{
    switch (self.stage) {
        case gcRequestStageDownload:
            return NSLocalizedString( @"Downloading activity data", @"Request Description");
            break;
        case gcRequestStageParsing:
            return NSLocalizedString(@"Parsing activity data", @"Request Description");
            break;
        case gcRequestStageSaving:
            return NSLocalizedString(@"Saving activity data", @"Request Description");
            break;
    }
}

-(NSString*)url{
    return GCWebActivityURLSummary(self.activityId);
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"activity_%@.json", self.activityId];
    if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:kRequestDebugFileEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
    }
#endif
    self.stage = gcRequestStageParsing;
    [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
    dispatch_async([GCAppGlobal worker],^(){
        [self processParse];
    });
}

-(void)processParse{
    if ([self checkNoErrors]) {
        GCGarminActivitySummaryParser * parser = [[[GCGarminActivitySummaryParser alloc] initWithData:[self.theString dataUsingEncoding:self.encoding]] autorelease];
        if (parser.success) {
            self.stage = gcRequestStageSaving;
            [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
            self.status = GCWebStatusOK;
            [[GCAppGlobal organizer] registerActivity:parser.activity forActivityId:parser.activity.activityId];
        }else{
            NSError * e = nil;
            NSString * fn = [NSString stringWithFormat:@"error_activity_%@.json", self.activityId];
            if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
                RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
            }
            self.status = GCWebStatusParsingFailed;
        }
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

+(GCActivity*)testForActivity:(id)actOrId withFilesIn:(NSString*)path{
    NSString * activityId = nil;
    GCActivity * act = nil;

    if ([actOrId isKindOfClass:[GCActivity class]]) {
        act = actOrId;
        activityId = act.activityId;
    }else{
        activityId = actOrId;
    }

    NSString * fn = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"activity_%@.json", activityId]];

    NSData * info = [NSData dataWithContentsOfFile:fn];
    if( info ){
        GCGarminActivitySummaryParser * parser = [[[GCGarminActivitySummaryParser alloc] initWithData:info] autorelease];
        act = parser.activity;
    }
    
    return act;
}

@end
