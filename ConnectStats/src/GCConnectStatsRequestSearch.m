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

static const NSUInteger kActivityRequestCount = 20;

@interface GCConnectStatsRequestSearch ()

@property (nonatomic,assign) NSUInteger reachedExisting;
@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,assign) NSUInteger start;

@property (nonatomic,retain) NSDate * lastFoundDate;
@property (nonatomic,assign) NSUInteger tokenId;
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
        rv.tokenId = 1;
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

-(NSString*)url{
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if (self.navigationController) {
        return nil;
    }else{
        NSString * path = GCWebConnectStatsSearch();
        NSDictionary *parameters = @{
                                     @"token_id" : @(self.tokenId),
                                     @"start" : @(self.start),
                                     @"limit" : @(kActivityRequestCount)
                                     
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

-(void)processParse{
    if ([self checkNoErrors]) {
        NSData * data = [self.theString dataUsingEncoding:self.encoding];
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if( dict ){
            NSLog(@"success %@", dict);
        }
    }
    
    [self processDone];
}

-(id<GCWebRequest>)nextReq{
    // later check logic to see if reach existing.
    if( self.navigationController ){
        return [[[GCConnectStatsRequestSearch alloc] initNextWith:self] autorelease];
    }
    return nil;
}


@end
