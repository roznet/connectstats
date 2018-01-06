//  MIT Licence
//
//  Created on 28/08/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCFitBitActivities.h"
#import "GCAppGlobal.h"
@import RZExternal;
#import "GCFitBitActivitiesParser.h"
#import "GCActivitiesOrganizer.h"

@implementation GCFitBitActivities
-(void)dealloc{
    [_date release];
    [_earliestDate release];
    [super dealloc];
}
+(GCFitBitActivities*)activitiesForDate:(NSDate*)date withEarliest:(NSDate*)earliest{
    GCFitBitActivities * rv = [[[GCFitBitActivities alloc] init]autorelease];
    if (rv) {
        rv.navigationController = nil;
        rv.date = date;
        rv.earliestDate = earliest;
    }
    return rv;
}

+(GCFitBitActivities*)activitiesForDate:(NSDate*)date with:(UINavigationController*)nav{
    GCFitBitActivities * rv = [[[GCFitBitActivities alloc] init]autorelease];
    if (rv) {
        rv.navigationController = nav;
        rv.date = date;
        NSDateComponents * comp = [[NSDateComponents alloc] init];
        comp.day = -90;
        rv.earliestDate = [date dateByAddingGregorianComponents:comp];
        [comp release];
    }
    return rv;
}
-(NSString*)url{
    return nil;
}

-(NSURLRequest*)preparedUrlRequest{
    if (self.navigationController) {
        return nil;
    }else{
        NSString * path = [NSString stringWithFormat:@"1/user/-/activities/date/%@.json", [self.date YYYYdashMMdashDD]];
        NSDictionary *parameters = @{@"format" : @"json"};

        return [self preparedUrlRequest:path params:parameters];
    }
}

-(NSDictionary*)postData{
    return nil;
}

-(NSString*)description{
    return [NSString stringWithFormat: @"Fitbit activity %@", [self.date YYYYdashMMdashDD]];
}

-(void)process{
    if (![self isSignedIn]) {
        [self performSelectorOnMainThread:@selector(processNewStage) withObject:nil waitUntilDone:NO];
        dispatch_async(dispatch_get_main_queue(),^(){
            [self signInToFitBit];
        });

    }else{
#if TARGET_IPHONE_SIMULATOR
        NSError * e = nil;
        NSString * fn = [NSString stringWithFormat:@"fitbit_%@.json", [self.date YYYYMMDD]];
        [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
        dispatch_async([GCAppGlobal worker],^(){
            [self parse];
        });
    }
}

-(void)parse{
    if (self.theString) {
        GCFitBitActivitiesParser * parser = [GCFitBitActivitiesParser activitiesParser:[self.theString dataUsingEncoding:self.encoding] forDate:self.date];
        GCActivity * act = parser.activity;
        if (act) {
            if ([[GCAppGlobal organizer] activityForId:act.activityId]) {
                self.existingOverlap++;
            }
            [[GCAppGlobal organizer ] registerActivity:act forActivityId:act.activityId];
        }
    }else{
        RZLog(RZLogWarning, @"No data received");
    }

    [self performSelectorOnMainThread:@selector(processDone) withObject:nil waitUntilDone:NO];
}

-(id<GCWebRequest>)nextReq{
    GCFitBitActivities * next = nil;
    if (self.navigationController) {
        next = [GCFitBitActivities activitiesForDate:self.date with:nil];
    }else{
        NSDateComponents * oneday = [[NSDateComponents alloc] init];
        oneday.day = -1;
        NSDate * prev = [self.date dateByAddingGregorianComponents:oneday];
        [oneday release];
        // go back to last 10 overlap or earliest date
        if ([prev compare:self.earliestDate]== NSOrderedDescending && self.existingOverlap < 10) {
            next = [GCFitBitActivities activitiesForDate:prev withEarliest:self.earliestDate];
            next.existingOverlap = self.existingOverlap;
        }
    }
    return next;
}
-(id<GCWebRequest>)remediationReq{
    if (self.status == GCWebStatusLoginFailed && self.navigationController  && [self isSignedIn]) {
        [GCFitBitReqBase signout];
        GCFitBitActivities * next = [GCFitBitActivities activitiesForDate:self.date with:self.navigationController];
        return next;
    }
    return nil;
}

@end
