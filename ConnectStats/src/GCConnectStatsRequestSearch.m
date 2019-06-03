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

@interface GCConnectStatsRequestSearch ()

@property (nonatomic,assign) NSUInteger reachedExisting;
@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,assign) NSUInteger start;

@property (nonatomic,retain) NSDate * lastFoundDate;

@end

@implementation GCConnectStatsRequestSearch

+(GCConnectStatsRequestSearch*)requestWithStart:(NSUInteger)aStart andMode:(BOOL)aMode{
    GCConnectStatsRequestSearch * rv = RZReturnAutorelease([[GCConnectStatsRequestSearch alloc] init]);
    if( rv ){
        rv.start = aStart;
        rv.reloadAll = aMode;
        rv.stage = gcRequestStageDownload;
        rv.status = GCWebStatusOK;
        rv.lastFoundDate = [NSDate date];
    }
    return rv;
}

-(void)dealloc{
    [_lastFoundDate release];
    [super dealloc];
}

-(NSString*)url{
    return GCWebConnectStatsSearch( self.start );
}

-(NSString*)searchFileNameForPage:(int)page{
    return  [NSString stringWithFormat:@"last_connectstats_search_%d.json", page];
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

-(void)processParse{
    if ([self checkNoErrors]) {
    }
    
    [self processDone];
}

@end
