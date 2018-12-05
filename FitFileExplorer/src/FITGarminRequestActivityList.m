//  MIT License
//
//  Created on 15/11/2018 for FitFileExplorer
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



#import "FITGarminRequestActivityList.h"
#import "GCWebUrl.h"
#import "FITAppGlobal.h"
#import "FitFileExplorer-Swift.h"

const NSUInteger kActivityRequestCount = 20;


@interface FITGarminRequestActivityList ()

@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,assign) NSUInteger start;
@property (nonatomic,retain) NSDate * lastFoundDate;
@property (nonatomic,assign) NSUInteger parsedCount;


@end

@implementation FITGarminRequestActivityList

-(FITGarminRequestActivityList*)initWithStart:(NSUInteger)aStart andMode:(BOOL)aMode{
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

-(FITGarminRequestActivityList*)initNextWith:(FITGarminRequestActivityList*)current{
    self = [super init];
    if (self) {
        self.start = current.start + kActivityRequestCount;
        self.reloadAll = current.reloadAll;
        self.lastFoundDate = current.lastFoundDate;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
    }
    return self;
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
    NSError * e;
    NSString * fname = [self searchFileNameForPage:(int)_start];
    if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:kRequestDebugFileEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
    self.stage = gcRequestStageParsing;
    [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
    [self processParse];
}

-(void)processParse{
    if ([self checkNoErrors]) {
        self.status = GCWebStatusOK;
        [self.delegate loginSuccess:gcWebServiceGarmin];
        
        self.parsedCount = [[FITAppGlobal downloadManager] loadOneFileWithFilePath:[RZFileOrganizer writeableFilePath:[self searchFileNameForPage:(int)_start]]];
        
    }
    
    [self performSelectorOnMainThread:@selector(processRegister) withObject:nil waitUntilDone:NO];
}

-(void)processRegister{
    if (self.status == GCWebStatusOK) {
        if ( (_reloadAll || self.parsedCount == kActivityRequestCount) && self.parsedCount > 0) {
            self.nextReq = [[FITGarminRequestActivityList alloc] initNextWith:self];
        }
    }
    [self processDone];
}

@end
