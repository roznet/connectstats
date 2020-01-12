//  MIT Licence
//
//  Created on 01/05/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCGarminRequestActivityList.h"

#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCGarminActivitySummaryParser.h"
#import "GCActivity+Import.h"
#import "GCActivitiesOrganizer.h"

@interface GCGarminRequestActivityList ()
@property (nonatomic,retain) NSArray<NSString*> * list;
@property (nonatomic,retain) NSString * parentId;
@end

@implementation GCGarminRequestActivityList

-(instancetype)init{
    return [super init];
}

-(GCGarminRequestActivityList*)initWithIds:(NSArray<NSString*> *)aIdList andParentId:(NSString*)parentId{
    self = [super init];
    if (self) {
        self.list = aIdList;
        self.parentId = parentId;
        self.stage = gcRequestStageDownload;
        self.status = GCWebStatusOK;
    }
    return self;
}

+(GCGarminRequestActivityList*)nextRequestWith:(GCGarminRequestActivityList*)current{
    GCGarminRequestActivityList * rv = nil;
    if (current.list.count < 2) {
    }else{
        rv = [[[GCGarminRequestActivityList alloc] initWithIds:[current.list subarrayWithRange:NSMakeRange(0, current.list.count-1)] andParentId:current.parentId] autorelease];
    }
    return rv;
}

-(void)dealloc{
    [_list release];
    [_parentId release];

    [super dealloc];
}

-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: %@[%@] %@>",
            NSStringFromClass([self class]),
            self.list.count > 0 ? self.activityId : @"",
            @(self.list.count),
            [self.urlDescription truncateIfLongerThan:192 ellipsis:@"..."] ];
}

-(NSString*)description{
    switch (self.stage) {
        case gcRequestStageDownload:
            return [NSString stringWithFormat:NSLocalizedString( @"Downloading activity %@", @"Request Description"), self.activityId];
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
    return GCWebActivityURLSummary((self.list).lastObject);
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"activitydetails_%@.json", [self activityId]];
    if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
    }
#endif
    self.stage = gcRequestStageParsing;
    [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
    dispatch_async([GCAppGlobal worker],^(){
        [self processParse];
    });
}
-(NSString*)activityId{
    id val = (self.list).lastObject;
    if ([val isKindOfClass:[NSString class]]) {
        return val;
    }else if ([val respondsToSelector:@selector(stringValue)]){
        return [val stringValue];
    }else{
        return [val description];
    }
}
-(void)processParse{
    if ([self checkNoErrors]) {
        NSData * data = [self.theString dataUsingEncoding:self.encoding];
        GCGarminActivitySummaryParser * parser = [[[GCGarminActivitySummaryParser alloc] initWithData:data] autorelease];
        if (parser.success) {
            self.stage = gcRequestStageSaving;
            [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
            self.status = GCWebStatusOK;
            GCActivity * act = parser.activity;
            [[GCAppGlobal organizer] registerActivity:act forActivityId:act.activityId];
            NSArray<NSString*>*childIds = act.childIds;
            if(childIds){
                self.list = [childIds arrayByAddingObjectsFromArray:self.list];
            }
        }else{
            NSError * e = nil;
            NSString * fn = [NSString stringWithFormat:@"error_activity_%d_%@.json", (int)self.list.count, [self activityId]];
            if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
                RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
            }
            self.status = GCWebStatusParsingFailed;
        }
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    if (self.list.count>0) {
        return [GCGarminRequestActivityList nextRequestWith:self];
    }
    return nil;
}

@end
