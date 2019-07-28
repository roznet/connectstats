//  MIT Licence
//
//  Created on 29/09/2013.
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

#import "GCGarminActivityTrack13Request.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityDetailJsonParser.h"
#import "GCGarminActivityLapsParser.h"
#import "GCTrackPointSwim.h"
#import "GCLapSwim.h"
#import "GCActivity.h"
#import "GCActivitiesOrganizer.h"
@import RZUtils;
@import RZExternal;
@import RZExternalUniversal;
#import "ConnectStats-Swift.h"

@interface GCGarminActivityTrack13Request ()
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,retain) NSArray<GCTrackPoint*> * trackpoints;
@property (nonatomic,retain) NSArray<GCLap*> * laps;
@property (nonatomic, retain) NSArray<GCLapSwim*> * lapsSwim;
@property (nonatomic,retain) NSArray<GCTrackPointSwim*> * trackpointsSwim;

@end

@implementation GCGarminActivityTrack13Request

-(void)dealloc{
    [_activity release];
    [_trackpoints release];
    [_laps release];
    [_lapsSwim release];
    [_trackpointsSwim release];

    [super dealloc];
}
-(NSString*)activityId{
    return self.activity.activityId;
}
+(GCGarminActivityTrack13Request*)requestWithActivity:(GCActivity*)act{
    GCGarminActivityTrack13Request * rv = [[[GCGarminActivityTrack13Request alloc] init] autorelease];
    if (rv) {
        rv.activity = act;
        rv.stage = gcRequestStageDownload;
        rv.status = GCWebStatusOK;
        rv.trackpoints = nil;
        rv.laps = nil;
        rv.track13Stage = (gcTrack13RequestStage)0;
    }
    return rv;

}
+(GCGarminActivityTrack13Request*)nextRequest:(GCGarminActivityTrack13Request*)prev{
    GCGarminActivityTrack13Request * rv = [[[GCGarminActivityTrack13Request alloc] init] autorelease];
    if (rv) {
        rv.activity = prev.activity;
        rv.stage = gcRequestStageDownload;
        rv.status = GCWebStatusOK;
        rv.trackpoints = prev.trackpoints;
        rv.laps = prev.laps;
        rv.track13Stage = prev.track13Stage+1;
        rv.trackpointsSwim = prev.trackpointsSwim;
        rv.lapsSwim = prev.lapsSwim;
    }
    return rv;
}

-(NSString*)description{
    NSString * which = nil;
    switch (self.track13Stage) {
        case gcTrack13RequestTracks:
            which = NSLocalizedString(@"track points", @"Request Description");
            break;
        case gcTrack13RequestLaps:
            which = NSLocalizedString(@"laps", @"Request Description");
            break;
        case gcTrack13RequestFit:
            which = NSLocalizedString(@"Original", @"Request Description");
            break;
        default:
            which = NSLocalizedString(@"extra", @"Request Description");
            break;
    }
    if (which && _activity && _activity.date) {
        which = [NSString stringWithFormat:@"%@ %@", which, _activity.date.dateShortFormat];
    }
    NSString * rv = nil;
    switch (self.stage) {
        case gcRequestStageDownload:
            rv = [NSString stringWithFormat:NSLocalizedString(@"Downloading %@", @"Request Description"), which];
            break;
        case gcRequestStageParsing:
            rv = [NSString stringWithFormat:NSLocalizedString( @"Parsing %@", @"Request Description"), which];
            break;
        case gcRequestStageSaving:
            rv = NSLocalizedString( @"Saving track points", @"Request Description");
            break;
    }
    return rv;
}

-(NSString*)url{
    if (self.track13Stage == gcTrack13RequestTracks) {
        return GCWebActivityURLDetail(self.activityId);
    }else if(self.track13Stage == gcTrack13RequestLaps){
        return GCWebActivityURLSplits(self.activityId);
    }else if(self.track13Stage == gcTrack13RequestFit){
        if( [GCAppGlobal configGetBool:CONFIG_GARMIN_FIT_DOWNLOAD defaultValue:TRUE]){
            return GCWebActivityURLFitFile(self.activityId);
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

+(NSString*)stageFilename:(gcTrack13RequestStage)aStage forActivityId:(NSString*)activityId{
    NSString * fn = nil;
    switch (aStage) {
        case gcTrack13RequestLaps:
            fn = [NSString stringWithFormat:@"activitylaps_%@.json", activityId];
            break;
        case gcTrack13RequestTracks:
            fn =[NSString stringWithFormat:@"activitytrack_%@.json", activityId];
            break;
        case gcTrack13RequestFit:
            fn = [GCAppGlobal configGetBool:CONFIG_GARMIN_FIT_DOWNLOAD defaultValue:TRUE] ? [NSString stringWithFormat:@"activity_%@.fit", activityId] : nil;
            break;
        case gcTrack13RequestEnd:
            fn = nil;
            break;
    }
    return fn;
}

-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)adelegate{
    self.delegate = adelegate;
    if(self.track13Stage != gcTrack13RequestFit){
        self.encoding = NSUTF8StringEncoding;
        self.theString = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
        [self process];
    }else{
        NSError * e = nil;
        NSString * fn = [GCGarminActivityTrack13Request stageFilename:self.track13Stage forActivityId:self.activityId];
        if (fn) {
            NSString * fp = [RZFileOrganizer writeableFilePath:fn];
            NSString * zn = [fn stringByAppendingPathExtension:@"zip"];
            NSString * zp = [RZFileOrganizer writeableFilePath:zn];
            BOOL success = false;
            if([theData writeToFile:zp options:NSDataWritingAtomic error:&e]){
                OZZipFile * zipFile = [[OZZipFile alloc] initWithFileName:zp mode:OZZipFileModeUnzip error:&e];
                if (!zipFile) {
                    RZLog(RZLogError, @"zip open fail %@", e);
                }
                NSArray * files = [zipFile listFileInZipInfosWithError:&e];
                if (!files) {
                    RZLog(RZLogError, @"zip list fail %@", e);
                }
                OZFileInZipInfo * fitFile = nil;
                for (OZFileInZipInfo * info in files) {
                    if ([info.name hasSuffix:@".fit"]) {
                        if (fitFile != nil) {
                            RZLog( RZLogWarning, @"Multiple file in zip skipping %@, already has %@", info, fitFile);
                        }else{
                            fitFile = info;
                        }
                    }
                }
                if (fitFile) {
                    if([zipFile locateFileInZip:fitFile.name error:&e] == OZLocateFileResultFound){
                        OZZipReadStream * rstream = [zipFile readCurrentFileInZipWithError:&e];
                        if (fitFile.length < NSUIntegerMax) {
                            NSMutableData * data = [NSMutableData dataWithLength:(NSUInteger)fitFile.length];
                            if(![rstream readDataWithBuffer:data error:&e]){
                                RZLog(RZLogError, @"Failed to read %@", e);
                            }
                            if([data writeToFile:fp atomically:YES]){
                                success = true;
                            }else{
                                RZLog(RZLogError, @"Failed to extract and save %@", fn);
                            };
                        }else{
                            RZLog(RZLogError, @"File too big to read (%@ bytes)", @(fitFile.length));
                        }
                        [rstream finishedReadingWithError:&e];
                    }else{
                        RZLog(RZLogError, @"zip locate %@ fail %@", fitFile.name, e);
                    }
                }
                [zipFile closeWithError:&e];
                [zipFile release];
                if (success) {
                    [RZFileOrganizer removeEditableFile:zn];
                }
                
            }else{
                RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
            }

        }
        [self performSelectorOnMainThread:@selector(processNextOrDone) withObject:nil waitUntilDone:NO];
    }
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [GCGarminActivityTrack13Request stageFilename:self.track13Stage forActivityId:self.activityId];
    if (fn && self.theString) {
        if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:kRequestDebugFileEncoding error:&e]){
            RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
        }
    }
#endif
    if (self.track13Stage == gcTrack13RequestLaps) {
        dispatch_async([GCAppGlobal worker],^(){
            [self processParseLaps];
        });
    }else if(self.track13Stage==gcTrack13RequestTracks){
        dispatch_async([GCAppGlobal worker],^(){
            [self processParseTrackpoints];
        });
    }else{
        [self performSelectorOnMainThread:@selector(processNextOrDone) withObject:nil waitUntilDone:NO];
    }

}

-(void)processParseTCX{
    RZLog(RZLogError, @"SHOULD NOT USE ANYMORE");
    [self performSelectorOnMainThread:@selector(processNextOrDone) withObject:nil waitUntilDone:NO];
}

-(void)processParseLaps{
    if ([self checkNoErrors]) {
        self.stage = gcRequestStageParsing;
        [self.delegate loginSuccess:gcWebServiceGarmin];
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        GCGarminActivityLapsParser * parser = [[[GCGarminActivityLapsParser alloc] initWithData:[self.theString dataUsingEncoding:self.encoding]
                                                                                    forActivity:self.activity] autorelease];
        if (parser.success) {
            self.laps = parser.laps;
            self.trackpointsSwim = parser.trackPointSwim;
            self.lapsSwim = parser.lapsSwim;
        }
    }
    [self performSelectorOnMainThread:@selector(processNextOrDone) withObject:nil waitUntilDone:NO];

}

-(void)processSaving{
    if ([self checkNoErrors]) {
        if (self.trackpoints && self.laps) {
            self.stage = gcRequestStageSaving;
            [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
            self.status = GCWebStatusOK;
            if (self.trackpointsSwim && self.lapsSwim) {
                [[GCAppGlobal organizer] registerActivity:self.activityId withTrackpointsSwim:self.trackpointsSwim andLaps:self.lapsSwim];
            }else{
                [[GCAppGlobal organizer] registerActivity:self.activityId withTrackpoints:self.trackpoints andLaps:self.laps];
            }
            [self processMergeFitFile];
        }else{
            RZLog(RZLogError, @"laps or trackpoints missing");
            self.status = GCWebStatusParsingFailed;
        }
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(void)processNextOrDone{
    if (self.track13Stage + 1 < gcTrack13RequestEnd) {
        [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
    }else{
        dispatch_async([GCAppGlobal worker],^(){
            [self processSaving];
        });
    }
}

-(void)processParseTrackpoints{
    if ([self checkNoErrors]) {
        self.stage = gcRequestStageParsing;
        [self.delegate loginSuccess:gcWebServiceGarmin];
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        NSData * data = [self.theString dataUsingEncoding:self.encoding];
        GCGarminActivityDetailJsonParser * parser = [[[GCGarminActivityDetailJsonParser alloc] initWithData:data forActivity:self.activity] autorelease];
        if (parser.success) {
            self.trackpoints = parser.trackPoints;
            self.laps = @[];
        }else{
            if (parser.webError) {
                self.status = GCWebStatusAccessDenied;
            }else{
                NSError * e = nil;
                NSString * fn = [NSString stringWithFormat:@"error_activity_%@.json", self.activityId];
                if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
                    RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
                }
                self.status = GCWebStatusParsingFailed;
            }
        }
    }
    [self performSelectorOnMainThread:@selector(processNextOrDone) withObject:nil waitUntilDone:NO];
}

-(void)processMergeFitFile{
    if( [GCAppGlobal configGetBool:CONFIG_GARMIN_FIT_DOWNLOAD defaultValue:TRUE] && [GCAppGlobal configGetBool:CONFIG_GARMIN_FIT_MERGE defaultValue:FALSE]){
        NSString * fn = [GCGarminActivityTrack13Request stageFilename:gcTrack13RequestFit forActivityId:self.activityId];
        
        GCActivity * fitAct = RZReturnAutorelease([[GCActivity alloc] initWithId:self.activityId fitFilePath:[RZFileOrganizer writeableFilePath:fn] startTime:self.activity.date]);
        
        [self.activity updateTrackpointsFromActivity:fitAct];
        
    }
}

-(id<GCWebRequest>)nextReq{
    if (self.track13Stage+1<gcTrack13RequestEnd) {
        return [GCGarminActivityTrack13Request nextRequest:self];
    }
    return nil;
}

+(GCActivity*)testForActivity:(GCActivity*)act withFilesIn:(NSString*)path{
    return [self testForActivity:act withFilesIn:path mergeFit:FALSE];
}
+(GCActivity*)testForActivity:(GCActivity*)act withFilesIn:(NSString*)path mergeFit:(BOOL)mergeFit{

    NSString * fnTracks = [path stringByAppendingPathComponent:[self stageFilename:gcTrack13RequestTracks forActivityId:act.activityId]];
    NSString * fnLaps   = [path stringByAppendingPathComponent:[self stageFilename:gcTrack13RequestLaps forActivityId:act.activityId]];
    NSString * fnFit = [path stringByAppendingPathComponent:[self stageFilename:gcTrack13RequestFit forActivityId:act.activityId]];
    
    if (fnTracks && fnLaps) {

        NSData * trackdata = [NSData dataWithContentsOfFile:fnTracks];
        NSData * lapsdata = [NSData dataWithContentsOfFile:fnLaps];

        GCGarminActivityDetailJsonParser * parserTracks = [[[GCGarminActivityDetailJsonParser alloc] initWithData:trackdata forActivity:act] autorelease];
        GCGarminActivityLapsParser * parserLaps = [[[GCGarminActivityLapsParser alloc] initWithData:lapsdata forActivity:act] autorelease];

        if (parserLaps.success || parserTracks.success) {
            if(parserLaps.trackPointSwim || parserLaps.lapsSwim){
                [act saveTrackpointsSwim:(parserLaps.trackPointSwim ?: @[]) andLaps:(parserLaps.lapsSwim ?: @[]) ];
            }else{
                [act saveTrackpoints:(parserTracks.trackPoints ?:@[]) andLaps:(parserLaps.laps ?:@[])];
            }
            
            if( mergeFit && fnFit && [[NSFileManager defaultManager] fileExistsAtPath:fnFit] ){
                GCActivity * fitAct = RZReturnAutorelease([[GCActivity alloc] initWithId:act.activityId fitFilePath:fnFit startTime:act.date]);
                
                [act updateSummaryDataFromActivity:fitAct];
                [act updateTrackpointsFromActivity:fitAct];
                [act saveTrackpoints:act.trackpoints andLaps:act.laps];
            }
            return act;
        }else{
            return nil;
        }
    }
    return nil;
}

@end
