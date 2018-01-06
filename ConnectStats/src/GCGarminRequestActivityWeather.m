//  MIT Licence
//
//  Created on 14/03/2015.
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

#import "GCGarminRequestActivityWeather.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityWeatherParser.h"
#import "GCActivity.h"
#import "GCActivitiesOrganizer.h"

@interface GCGarminRequestActivityWeather ()
@property (nonatomic,retain) GCActivity * activity;

@end
@implementation GCGarminRequestActivityWeather

-(void)dealloc{
    [_activity release];
    [super dealloc];
}

+(GCGarminRequestActivityWeather*)requestWithActivity:(GCActivity*)activity{
    GCGarminRequestActivityWeather * rv = [[[GCGarminRequestActivityWeather alloc] init] autorelease];
    if (rv) {
        rv.activity = activity;
    }
    return rv;
}

-(NSString*)activityId{
    return self.activity.activityId;
}

-(NSString*)url{
    return GCWebWeatherHtml(self.activityId);
}
-(NSString*)description{
    NSString * rv = NSLocalizedString(@"Downloading weather", @"Request Status");
    if (self.activity.date) {
        return [NSString stringWithFormat:@"%@ %@", rv, self.activity.date.dateShortFormat];
    }else{
        return rv;
    }
}


-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)adelegate{
    // seems this url switch to data, so process properly
    self.delegate = adelegate;
    self.encoding = NSUTF8StringEncoding;
    self.theString = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
    [self process];

}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"activityweather_%@.json", self.activityId];
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


-(void)processParse{
    if ([self checkNoErrors]) {
        self.stage = gcRequestStageDownload;
        GCGarminActivityWeatherParser * parser = [GCGarminActivityWeatherParser garminActivityWeatherParser:self.theString andEncoding:self.encoding];
        if (parser.success && parser.weather) {
            [[GCAppGlobal organizer] registerActivity:self.activityId withWeather:parser.weather];
        }else{
            RZLog(RZLogWarning, @"failed to get weather");
            NSError * e = nil;
            NSString * fn = [NSString stringWithFormat:@"error_activityweather_%@.json", self.activityId];
            if(![self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
                RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
            }
        }

        self.stage = gcRequestStageSaving;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        self.status = GCWebStatusOK;
    }else if (self.status == GCWebStatusDeletedActivity){
        self.status = GCWebStatusOK;
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(NSString*)httpUserAgent{
    return RZWebRandomUserAgent();
}

@end
