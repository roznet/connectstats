//  MIT Licence
//
//  Created on 23/10/2013.
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

#import "GCGarminActivityWeatherHtml.h"
#import "GCAppGlobal.h"
#import "GCGarminActivityWeatherParser.h"
#import "GCActivitiesOrganizer.h"

@implementation GCGarminActivityWeatherHtml
-(void)dealloc{
    [_activityId release];
    [super dealloc];
}
+(GCGarminActivityWeatherHtml*)garminActivityWeatherHtml:(NSString*)activityId{
    GCGarminActivityWeatherHtml * rv = [[[GCGarminActivityWeatherHtml alloc] init] autorelease];
    if (rv) {
        rv.activityId = activityId;
    }
    return rv;
}
-(NSString*)url{
    return [NSString stringWithFormat:@"http://connect.garmin.com/activity/%@", self.activityId];
}
-(NSString*)description{
    return NSLocalizedString(@"Downloading weather", @"Request Status");
}
-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"activity_%@.html", self.activityId];
    if([self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
    }
#endif
    self.stage = gcRequestStageParsing;
    [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
    dispatch_async([GCAppGlobal worker],^(){
        [self processParse];
    });
}

+(NSString*)extractWeatherSection:(NSString*)theString{
    NSRange range = [theString rangeOfString:@"<div id=\"detailsWeatherInfoBox\" class=\"detailsBox leftBox\"><html"];
    if (range.location != NSNotFound) {
        NSString * weatherStart = [theString substringFromIndex:range.location+range.length-5];
        NSRange end = [weatherStart rangeOfString:@"</html>"];
        if (end.location != NSNotFound) {
            NSString * weather = [weatherStart substringToIndex:end.location+end.length];
            return weather;
        }
    }
    return nil;
}

-(void)processParse{
    if ([self checkNoErrors]) {
        self.stage = gcRequestStageDownload;
        NSString * weather = [GCGarminActivityWeatherHtml extractWeatherSection:self.theString];
        if (weather) {
            GCGarminActivityWeatherParser * parser = [GCGarminActivityWeatherParser garminActivityWeatherParser:weather andEncoding:self.encoding];
            if (parser.success && parser.weather) {
                [[GCAppGlobal organizer] registerActivity:self.activityId withWeather:parser.weather];
            }else{
                RZLog(RZLogWarning, @"failed to get weather");
                NSError * e = nil;
                NSString * fn = [NSString stringWithFormat:@"error_activityweather_%@.html", self.activityId];
                if(![weather writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e]){
                    RZLog(RZLogError, @"Failed to save %@. %@", fn, e.localizedDescription);
                }
            }
        }

        self.stage = gcRequestStageSaving;
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        self.status = GCWebStatusOK;
    }
    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}


@end
