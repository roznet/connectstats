//  MIT License
//
//  Created on 24/03/2018 for ConnectStats
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

#import "GCGarminRequestModernActivityTypes.h"
#import "GCAppGlobal.h"
#import "GCWebUrl.h"

@interface GCGarminRequestModernActivityTypes ()
@property (nonatomic,retain) NSArray<NSDictionary*>*modern;
@property (nonatomic,retain) NSArray<NSDictionary*>*legacy;


@end

@implementation GCGarminRequestModernActivityTypes

-(instancetype)init{
    self = [super init];
    if (self) {
        self.modern = nil;
        self.legacy = nil;
    }
    return self;
}
-(void)dealloc{
    [_modern release];
    [_legacy release];
    
    [super dealloc];
}
-(NSString*)url{
    return GCWebActivityTypesModern();
}

-(NSString*)description{
    return NSLocalizedString(@"Updating Activity Types",@"Request Description");
}

-(NSString*)fileName{
    if( self.modern ){
        return [NSString stringWithFormat:@"activity_types.json"];
    }else{
        return [NSString stringWithFormat:@"activity_types_modern.json"];
    }
}

-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)delegate{
    self.delegate = delegate;
#if TARGET_IPHONE_SIMULATOR
    NSString * fn = self.fileName;
    [theData writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true];
#endif
    
    self.stage = gcRequestStageParsing;
    [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
    dispatch_async([GCAppGlobal worker],^(){
        [self processParse:theData];
    });
}
-(void)process{
    [self process:[self.theString dataUsingEncoding:self.encoding] andDelegate:self.delegate];
}

-(void)processParse:(NSData*)jsonData{
    if ([self checkNoErrors]) {
        NSError *e = nil;

        NSArray * jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        self.modern = jsonArray ?: @[];
        self.legacy = @[];
        self.stage = gcRequestStageSaving;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        
        NSUInteger n = [[GCAppGlobal activityTypes] loadMissingFromGarmin:self.modern withDisplayInfoFrom:self.legacy];
        if( n > 0){
            RZLog(RZLogInfo, @"Found %lu new types", (long unsigned)n);
        }
        self.status = GCWebStatusOK;
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}


+(GCGarminRequestModernActivityTypes*)testWithFilesIn:(NSString*)path forTypes:(GCActivityTypes*)types{
    NSData * jsonData = nil;
    NSError * err = nil;
    GCGarminRequestModernActivityTypes * rv = [[[GCGarminRequestModernActivityTypes alloc] init] autorelease];
    
    jsonData = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:rv.fileName]];
    rv.modern = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    rv.legacy = @[];

    [types loadMissingFromGarmin:rv.modern withDisplayInfoFrom:rv.legacy];
    
    return rv;
}
@end
