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

static const NSUInteger kActivityRequestCount = 20;

@interface GCGarminRequestModernSearch ()

/**
 Number of existing activity reached. If equal to the total request, we
 can stop
 */
@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,assign) NSUInteger start;
@property (nonatomic,retain) NSArray<NSString*>*childIds;
@property (nonatomic,assign) BOOL searchMore;

@property (nonatomic,retain) NSDate * lastFoundDate;
@property (nonatomic,retain) GCWebRequestStandard * nextReqCache;

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
    [_lastFoundDate release];
    [_nextReqCache release];

    [super dealloc];
}

-(NSString*)url{
    return GCWebModernSearchURL(self.start, kActivityRequestCount);
}

-(NSString*)debugDescription{
    NSString * info = self.start == 0 ? @"first" : [NSString stringWithFormat:@"%@[%@]", [self.lastFoundDate YYYYMMDD], @(self.start)];
    
    if(self.reloadAll){
        info = [NSString stringWithFormat:@"%@/all", info];
    }
    
    return [NSString stringWithFormat:@"<%@: %@ %@>",
            NSStringFromClass([self class]),
            info,
            [self.urlDescription truncateIfLongerThan:192 ellipsis:@"..."]];
}

-(NSString*)description{

    switch (self.stage) {
        case gcRequestStageDownload:
            return [NSString stringWithFormat:NSLocalizedString(@"Downloading Garmin History... %@",@"Request Description"),[self.lastFoundDate dateFormatFromToday]];
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
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self processNewStage];
    });
    dispatch_async([GCAppGlobal worker],^(){
        [self processParse];
    });
}

-(void)addActivitiesFromParser:(GCGarminSearchModernJsonParser*)parser
                   toOrganizer:(GCActivitiesOrganizer*)organizer{
    GCActivitiesOrganizerListRegister * listRegister = [GCActivitiesOrganizerListRegister activitiesOrganizerListRegister:parser.activities from:[GCService service:gcServiceGarmin] isFirst:(self.start==0)];
    [listRegister addToOrganizer:organizer];
    if (listRegister.childIds.count > 0) {
        self.childIds = self.childIds ? [self.childIds arrayByAddingObjectsFromArray:listRegister.childIds] : listRegister.childIds;
    }
    NSDate * newDate = parser.activities.lastObject.date;
    if(newDate){
        self.lastFoundDate = newDate;
    }
    self.searchMore = [listRegister shouldSearchForMoreWith:kActivityRequestCount reloadAll:self.reloadAll];
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
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self processNewStage];
            });

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
        self.status = GCWebStatusOK;
    }

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self processRegister];
    });
}

+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path{
    return [self testForOrganizer:organizer withFilesInPath:path start:0];
}
+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path start:(NSUInteger)start{
    GCGarminRequestModernSearch * search = [[GCGarminRequestModernSearch alloc] initWithStart:start andMode:false];

    BOOL isDirectory = false;
    if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]){
        NSString * fn = isDirectory ? [path stringByAppendingPathComponent:[search searchFileNameForPage:(int)start]] : path;
        
        NSData * info = [NSData dataWithContentsOfFile:fn];
        
        GCGarminSearchModernJsonParser * parser = [[[GCGarminSearchModernJsonParser alloc] initWithData:info] autorelease];
        [search addActivitiesFromParser:parser toOrganizer:organizer];
    }
    RZRelease(search);
    
    return organizer;
}

-(void)processRegister{
    if (self.status == GCWebStatusOK) {
        
        if ( self.searchMore ) {
            self.nextReqCache = [[[GCGarminRequestModernSearch alloc] initNextWith:self] autorelease];
            if( self.reloadAll ){
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[GCAppGlobal profile] serviceAnchor:gcServiceGarmin set:self.start];
                    [GCAppGlobal saveSettings];
                });
            }
        }else{
            if( self.reloadAll ){
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[GCAppGlobal profile] serviceCompletedFull:gcServiceGarmin set:YES];
                    [GCAppGlobal saveSettings];
                });
            }
        }
        if (self.nextReq == nil && self.childIds.count > 0) {
            self.nextReqCache = [[[GCGarminRequestActivityList alloc]  initWithIds:self.childIds andParentId:@"parent"] autorelease];
        }
    }
    [self processDone];
}

-(GCWebRequestStandard*)nextReq{
    return self.nextReqCache;
}
@end
