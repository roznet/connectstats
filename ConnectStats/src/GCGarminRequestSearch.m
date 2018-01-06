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

#import "GCGarminRequestSearch.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCGarminSearchJsonParser.h"
#import "Flurry.h"
#import "GCService.h"
#import "GCGarminRequestActivityList.h"
#import "GCActivitiesOrganizerListRegister.h"

@interface GCGarminSearch ()

@property (nonatomic,assign) double percent;
@property (nonatomic,assign) NSUInteger currentPage;
@property (nonatomic,assign) NSUInteger totalPages;
@property (nonatomic,assign) BOOL reachedExisting;
@property (nonatomic,retain) NSArray<NSString*> * childIds;

@end
#pragma mark -

@implementation GCGarminSearch

-(GCGarminSearch*)init{
    self = [super init];
    if (self) {
        _reloadAll = false;
        _start = 0;
        _percent = 0;
        self.stage = gcRequestStageDownload;
    }
    return self;
}

-(GCGarminSearch*)initWithStart:(NSUInteger)aStart percent:(double)pct andMode:(BOOL)aMode{
    self = [super init];
    if (self) {
        _start = aStart;
        _reloadAll = aMode;
        _percent = pct;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
    }
    return self;
}

-(GCGarminSearch*)initNextWith:(GCGarminSearch*)current{
    self = [super init];
    if (self) {
        self.start = current.start + 20;
        self.reloadAll = current.reloadAll;
        self.percent = (double)current.currentPage/current.totalPages;
        self.childIds = current.childIds;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
    }
    return self;
}

-(void)dealloc{
    [_activities release];
    [_childIds release];

    [super dealloc];
}

-(NSString*)url{
    return GCWebSearchURL( self.start);
}

-(NSString*)description{
    NSString * pctStr = _percent*100.>0. ? [NSString stringWithFormat:@"(%.0f%%)", _percent*100.] : @"";

    switch (self.stage) {
        case gcRequestStageDownload:
            return [NSString stringWithFormat:NSLocalizedString(@"Downloading History... %@",@"Request Description"),pctStr];
            break;
        case gcRequestStageParsing:
            return [NSString stringWithFormat:NSLocalizedString( @"Parsing History... %@", @"Request Description"),pctStr];
            break;
        case gcRequestStageSaving:
            return [NSString stringWithFormat:NSLocalizedString( @"Saving History... %@", @"Request Description"),pctStr];
            break;
    }
    return NSLocalizedString( @"Processing History...", @"Request Description" );
}

-(NSString*)searchFileNameForPage:(int)page{
    return  [NSString stringWithFormat:@"last_search_%d.json", page];
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

-(void)addActivitiesFromParser:(GCGarminSearchJsonParser*)parser
                   toOrganizer:(GCActivitiesOrganizer*)organizer{
    GCActivitiesOrganizerListRegister * listRegister = [GCActivitiesOrganizerListRegister listRegisterFor:parser.activities from:[GCService service:gcServiceGarmin] isFirst:(_currentPage == 1)];
    [listRegister addToOrganizer:organizer];
    self.reachedExisting = listRegister.reachedExisting;
    if (listRegister.childIds.count > 0) {
        self.childIds = self.childIds ? [self.childIds arrayByAddingObjectsFromArray:listRegister.childIds] : listRegister.childIds;
    }
}

-(void)processParse{
    if ([self checkNoErrors]) {
        self.status = GCWebStatusOK;
        [self.delegate loginSuccess:gcWebServiceGarmin];
        GCGarminSearchJsonParser * parser=[[[GCGarminSearchJsonParser alloc] initWithString:self.theString andEncoding:self.encoding] autorelease];
        if (parser.success) {
            GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];

            [[GCAppGlobal profile] serviceSuccess:gcServiceGarmin set:true];
            self.stage = gcRequestStageSaving;
            [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
            self.activities = parser.activities;
            _currentPage = parser.currentPage;
            _totalPages = parser.totalPages;

            [self addActivitiesFromParser:parser toOrganizer:organizer];
        }
        else{
            self.status = GCWebStatusParsingFailed;
        }
    };

    if( self.status != GCWebStatusOK){
        NSString * fname = [NSString stringWithFormat:@"error_last_search_%d.json", (int)_start];
        NSError * e = nil;
        if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:self.encoding error:&e]){
            RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
        }
    }

    if (self.status != GCWebStatusOK && [GCAppGlobal configGetBool:CONFIG_CONTINUE_ON_ERROR defaultValue:false]) {
        RZLog(RZLogWarning, @"ignoring error for %@", [self url]);
        _currentPage = [[GCAppGlobal profile] configGetInt:PROFILE_LAST_PAGE defaultValue:0];
        _totalPages = [[GCAppGlobal profile] configGetInt:PROFILE_LAST_TOTAL_PAGES defaultValue:0];
        _reachedExisting = false;
        self.status = GCWebStatusOK;
    }

    [self performSelectorOnMainThread:@selector(processRegister) withObject:nil waitUntilDone:NO];
}

+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path{

    GCGarminSearch * search = [[GCGarminSearch alloc] initWithStart:0 percent:0 andMode:false];

    NSString * fn = [path stringByAppendingPathComponent:[search searchFileNameForPage:0]];

    NSString * info = [NSString stringWithContentsOfFile:fn encoding:kRequestDebugFileEncoding error:nil];
    GCGarminSearchJsonParser * parser=[[[GCGarminSearchJsonParser alloc] initWithString:info andEncoding:kRequestDebugFileEncoding] autorelease];
    search.activities = parser.activities;
    [search addActivitiesFromParser:parser toOrganizer:organizer];

    RZRelease(search);

    return organizer;
}

-(void)registerEvent{

#ifdef GC_USE_FLURRY
    NSDictionary * params = @{@"Count": @(self.totalPages)};
    [Flurry logEvent:EVENT_FULL_DOWNLOAD withParameters:params];
#endif

}
-(void)processRegister{
    if (self.status == GCWebStatusOK) {
        if ([GCAppGlobal trialVersion]) {
            // trial version only downloads one page
            [[GCAppGlobal profile ]configSet:PROFILE_LAST_PAGE intVal:_totalPages];
            [[GCAppGlobal profile] configSet:PROFILE_LAST_TOTAL_PAGES intVal:_totalPages];
            [[GCAppGlobal profile] configSet:PROFILE_FULL_DOWNLOAD_DONE boolVal:TRUE];
            [GCAppGlobal saveSettings];
        }
        else{
            if (_reloadAll || !_reachedExisting) {
                if (_reloadAll) {
                    [[GCAppGlobal profile ]configSet:PROFILE_LAST_PAGE intVal:_currentPage];
                    [[GCAppGlobal profile] configSet:PROFILE_LAST_TOTAL_PAGES intVal:_totalPages];
                    [[GCAppGlobal profile] configSet:PROFILE_FULL_DOWNLOAD_DONE boolVal:_currentPage==_totalPages];
                    [GCAppGlobal saveSettings];
                    if (_currentPage==_totalPages) {
                        [self performSelectorOnMainThread:@selector(registerEvent) withObject:nil waitUntilDone:NO];
                    }
                }
                if (_currentPage < _totalPages) {
                    self.nextReq = [[[GCGarminSearch alloc] initNextWith:self] autorelease];
                }
            }
            if (self.nextReq == nil && self.childIds.count > 0) {
                self.nextReq = [[[GCGarminRequestActivityList alloc]  initWithIds:self.childIds andParentId:@"parent"] autorelease];
            }
        }
    }
    [self processDone];
}
@end
