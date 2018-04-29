//  MIT Licence
//
//  Created on 08/10/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCGarminRequestModernSearch.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCActivitiesOrganizerListRegister.h"
#import "GCGarminSearchModernJsonParser.h"
#import "GCActivity.h"
#import "GCService.h"
#import "GCGarminRequestActivityList.h"

const NSUInteger kActivityRequestCount = 20;

@interface GCGarminRequestModernSearch ()

@property (nonatomic,assign) NSUInteger reachedExisting;
@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,assign) NSUInteger start;
@property (nonatomic,retain) NSArray<NSString*>*childIds;
@property (nonatomic,retain) NSArray<GCActivity*>*activities;

@property (nonatomic,retain) NSDate * lastFoundDate;

@end

@implementation GCGarminRequestModernSearch

-(GCGarminRequestModernSearch*)init{
    self = [super init];
    if (self) {
        self.stage = gcRequestStageDownload;
    }
    return self;
}

-(GCGarminRequestModernSearch*)initWithStart:(NSUInteger)aStart andMode:(BOOL)aMode{
    self = [super init];
    if (self) {
        self.reloadAll = aMode;
        self.start  =aStart;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
        self.lastFoundDate = [NSDate date];
    }
    return self;
}

-(GCGarminRequestModernSearch*)initNextWith:(GCGarminRequestModernSearch*)current{
    self = [super init];
    if (self) {
        self.start = current.start + kActivityRequestCount;
        self.reloadAll = current.reloadAll;
        self.childIds = current.childIds;
        self.lastFoundDate = current.lastFoundDate;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
    }
    return self;
}

-(void)dealloc{
    [_childIds release];
    [_activities release];
    [_lastFoundDate release];

    [super dealloc];
}

-(NSString*)url{
    return GCWebModernSearchURL(self.start, kActivityRequestCount);
}

-(NSString*)description{

    switch (self.stage) {
        case gcRequestStageDownload:
            return [NSString stringWithFormat:NSLocalizedString(@"Downloading History... %@",@"Request Description"),[self.lastFoundDate dateFormatFromToday]];
            break;
        case gcRequestStageParsing:
            return [NSString stringWithFormat:NSLocalizedString( @"Parsing History... ", @"Request Description"),[self.lastFoundDate dateFormatFromToday]];
            break;
        case gcRequestStageSaving:
            return [NSString stringWithFormat:NSLocalizedString( @"Saving History... %@", @"Request Description"),[self.lastFoundDate dateFormatFromToday]];
            break;
    }
    return NSLocalizedString( @"Processing History...", @"Request Description" );
}

-(NSString*)searchFileNameForPage:(int)page{
    return  [NSString stringWithFormat:@"last_modern_search_%d.json", page];
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSError * e;
    NSString * fname = [self searchFileNameForPage:(int)_start];
    if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:kRequestDebugFileEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
#endif
    self.stage = gcRequestStageParsing;
    [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
    dispatch_async([GCAppGlobal worker],^(){
        [self processParse];
    });
}

-(void)addActivitiesFromParser:(GCGarminSearchModernJsonParser*)parser
                   toOrganizer:(GCActivitiesOrganizer*)organizer{
    GCActivitiesOrganizerListRegister * listRegister = [GCActivitiesOrganizerListRegister listRegisterFor:parser.activities from:[GCService service:gcServiceGarmin] isFirst:(self.start==0)];
    [listRegister addToOrganizer:[GCAppGlobal organizer]];
    self.reachedExisting = listRegister.reachedExisting;
    if (listRegister.childIds.count > 0) {
        self.childIds = self.childIds ? [self.childIds arrayByAddingObjectsFromArray:listRegister.childIds] : listRegister.childIds;
    }
    self.activities = parser.activities;
    NSDate * newDate = self.activities.lastObject.date;
    if(newDate){
        self.lastFoundDate = newDate;
    }
}

-(void)processParse{
    if ([self checkNoErrors]) {
        self.status = GCWebStatusOK;
        [self.delegate loginSuccess:gcWebServiceGarmin];
        NSData * data = [self.theString dataUsingEncoding:self.encoding];
        GCGarminSearchModernJsonParser * parser=[[[GCGarminSearchModernJsonParser alloc] initWithData:data] autorelease];
        if (parser.success) {
            GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];

            [[GCAppGlobal profile] serviceSuccess:gcServiceGarmin set:true];
            self.stage = gcRequestStageSaving;
            [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
            self.activities = parser.activities;

            [self addActivitiesFromParser:parser toOrganizer:organizer];
        }
        else{
            self.status = GCWebStatusParsingFailed;
            NSError * e = nil;
            NSString * fname = [NSString stringWithFormat:@"error_last_search_%d.json", (int)_start];
            if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:self.encoding error:&e]){
                RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
            }
        }
    }

    if (self.status != GCWebStatusOK && [GCAppGlobal configGetBool:CONFIG_CONTINUE_ON_ERROR defaultValue:false]) {
        RZLog(RZLogWarning, @"ignoring error for %@", [self url]);
        _reachedExisting = false;
        self.status = GCWebStatusOK;
    }

    [self performSelectorOnMainThread:@selector(processRegister) withObject:nil waitUntilDone:NO];
}

+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path{

    GCGarminRequestModernSearch * search = [[GCGarminRequestModernSearch alloc] initWithStart:0 andMode:false];

    NSString * fn = [path stringByAppendingPathComponent:[search searchFileNameForPage:0]];

    NSData * info = [NSData dataWithContentsOfFile:fn];

    GCGarminSearchModernJsonParser * parser = [[[GCGarminSearchModernJsonParser alloc] initWithData:info] autorelease];
    search.activities = parser.activities;
    [search addActivitiesFromParser:parser toOrganizer:organizer];

    RZRelease(search);

    return organizer;
}
-(NSUInteger)parsedCount{
    return self.activities.count;
}

-(void)processRegister{
    if (self.status == GCWebStatusOK) {
        if ( (_reloadAll || _reachedExisting < kActivityRequestCount) && self.parsedCount == kActivityRequestCount) {
            self.nextReq = [[[GCGarminRequestModernSearch alloc] initNextWith:self] autorelease];
        }
        if (self.nextReq == nil && self.childIds.count > 0) {
            self.nextReq = [[[GCGarminRequestActivityList alloc]  initWithIds:self.childIds andParentId:@"parent"] autorelease];
        }
    }
    [self processDone];
}

@end
