//  MIT License
//
//  Created on 28/05/2019 for ConnectStats
//
//  Copyright (c) 2019 Brice Rosenzweig
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



#import "GCConnectStatsRequestSearch.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCConnectStatsSearchJsonParser.h"
#import "GCActivitiesOrganizerListRegister.h"
#import "GCService.h"

static const NSUInteger kActivityRequestCount = 20;

@interface GCConnectStatsRequestSearch ()

@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,assign) NSUInteger start;

@property (nonatomic,retain) NSDate * lastFoundDate;
@property (nonatomic,assign) BOOL searchMore;
@end

@implementation GCConnectStatsRequestSearch

+(GCConnectStatsRequestSearch*)requestWithStart:(NSUInteger)aStart mode:(BOOL)aMode andNavigationController:(UINavigationController*)nav{
    GCConnectStatsRequestSearch * rv = RZReturnAutorelease([[GCConnectStatsRequestSearch alloc] init]);
    if( rv ){
        rv.start = aStart;
        rv.reloadAll = aMode;
        rv.stage = gcRequestStageDownload;
        rv.status = GCWebStatusOK;
        rv.lastFoundDate = [NSDate date];
        rv.navigationController = nav;
    }
    return rv;
}

-(GCConnectStatsRequestSearch*)initNextWith:(GCConnectStatsRequestSearch*)current{
    self = [super initNextWith:current];
    if (self) {
        self.reloadAll = current.reloadAll;
        self.lastFoundDate = current.lastFoundDate;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
        // If we had navigation controller, we tried to login first, next will
        // start at same point, else go further
        if( current.navigationController ){
            self.start = current.start;
        }else{
            self.start = current.start + kActivityRequestCount;
        }
        // Next is always without navigationController, only first one in the chain can have it
        self.navigationController = nil;
    }
    return self;
}

-(void)dealloc{
    [_lastFoundDate release];
    [super dealloc];
}

-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: %@ %@>",
            NSStringFromClass([self class]),
            self.start == 0 ? @"first" : [self.lastFoundDate YYYYMMDD],
            [self.urlDescription truncateIfLongerThan:192 ellipsis:@"..."]];
}


-(NSString*)description{
    return [NSString stringWithFormat:NSLocalizedString(@"Downloading ConnectStats History... %@",@"Request Description"),[self.lastFoundDate dateFormatFromToday]];
}
-(NSString*)url{
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if( [self isSignedIn] ){
        self.navigationController = nil;
    }
    
    if (self.navigationController) {
        return nil;
    }else{
        NSString * path = GCWebConnectStatsSearch([[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_CONFIG defaultValue:gcWebConnectStatsConfigProduction]);
        NSDictionary *parameters = @{
                                     @"token_id" : @(self.tokenId),
                                     @"start" : @(self.start),
                                     @"limit" : @(kActivityRequestCount),
                                     };
        
        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSString*)searchFileNameForPage:(int)page{
    return  [NSString stringWithFormat:@"last_connectstats_search_%d.json", page];
}

-(void)process{
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(),^(){
            [self signIn];
        });
        
    }else{
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
}

-(void)addActivitiesFromParser:(GCConnectStatsSearchJsonParser*)parser
                   toOrganizer:(GCActivitiesOrganizer*)organizer{
        GCActivitiesOrganizerListRegister * listRegister = [GCActivitiesOrganizerListRegister listRegisterFor:parser.activities from:[GCService service:gcServiceConnectStats] isFirst:(self.start==0)];
    [listRegister addToOrganizer:organizer];

    NSDate * newDate = parser.activities.lastObject.date;
    if(newDate){
        self.lastFoundDate = newDate;
    }
    self.searchMore = [listRegister shouldSearchForMoreWith:kActivityRequestCount reloadAll:self.reloadAll];
}

-(void)processParse{
    if ([self checkNoErrors]) {
        NSData * data = [self.theString dataUsingEncoding:self.encoding];
        if( data ){
            GCConnectStatsSearchJsonParser * parser = [[[GCConnectStatsSearchJsonParser alloc] initWithData:data] autorelease];
            if (parser.success) {
                GCActivitiesOrganizer * organizer = [GCAppGlobal organizer];
                
                [[GCAppGlobal profile] serviceSuccess:gcServiceConnectStats set:true];
                self.stage = gcRequestStageSaving;
                [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
                
                [self addActivitiesFromParser:parser toOrganizer:organizer];
            }
            else{
                self.status = GCWebStatusParsingFailed;
                NSError * e = nil;
                NSString * fname = [NSString stringWithFormat:@"error_last_search_cs_%d.json", (int)_start];
                if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:self.encoding error:&e]){
                    RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
                }
            }
        }
    }
    
    [self processDone];
}

-(id<GCWebRequest>)nextReq{
    // later check logic to see if reach existing.
    if( self.navigationController ){
        return [[[GCConnectStatsRequestSearch alloc] initNextWith:self] autorelease];
    }else{
        if( self.searchMore ){
            return [[[GCConnectStatsRequestSearch alloc] initNextWith:self] autorelease];
        }else{
            if( self.reloadAll ){
                [[GCAppGlobal profile] serviceCompletedFull:gcServiceConnectStats set:YES];
                RZLog(RZLogInfo, @"ConnectStats completed full");
                [GCAppGlobal saveSettings];
            }
        }
    }
    return nil;
}

+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path{
    return [self testForOrganizer:organizer withFilesInPath:path start:0];
}
+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path start:(NSUInteger)start{
    
    GCConnectStatsRequestSearch * search = [GCConnectStatsRequestSearch requestWithStart:start mode:false andNavigationController:nil];
    
    BOOL isDirectory = false;
    if( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]){
        NSString * fn = isDirectory ? [path stringByAppendingPathComponent:[search searchFileNameForPage:(int)start]] : path;
        
        NSData * info = [NSData dataWithContentsOfFile:fn];
    
        GCConnectStatsSearchJsonParser * parser = [[[GCConnectStatsSearchJsonParser alloc] initWithData:info] autorelease];
        [search addActivitiesFromParser:parser toOrganizer:organizer];
    }
    
    return organizer;
}

@end
