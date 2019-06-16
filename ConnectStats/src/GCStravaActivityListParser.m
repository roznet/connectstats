//  MIT Licence
//
//  Created on 15/03/2014.
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

#import "GCStravaActivityListParser.h"
#import "GCActivity.h"
#import "GCActivity+Import.h"
#import "GCService.h"
#import "GCAppGlobal.h"


@implementation GCStravaActivityListParser

+(GCStravaActivityListParser*)activityListParser:(NSData*)input{
    GCStravaActivityListParser*rv = [[[GCStravaActivityListParser alloc] init] autorelease];
    if (rv) {
        [rv parse:input];
    }
    return rv;
}
-(void)dealloc{
    [_activities release];
    [super dealloc];
}
-(NSArray*)parse:(NSData*)input{
    self.hasError = false;

    NSError * e = nil;
    id parsed = [NSJSONSerialization JSONObjectWithData:input options:NSJSONReadingMutableContainers error:&e];
    BOOL saveBadJson = false;
    if (parsed!=nil) {
        if ([parsed isKindOfClass:[NSArray class]]) {
            NSArray * json = parsed;
            NSMutableArray * rv = [NSMutableArray arrayWithCapacity:json.count];
            for (NSDictionary * one in json) {
                if ([one isKindOfClass:[NSDictionary class]]) {
                    NSString * activityId = [one[@"id"] stringValue];
                    activityId = [[GCService service:gcServiceStrava] activityIdFromServiceId:activityId];

                    GCActivity * act = [[GCActivity alloc] initWithId:activityId andStravaData:one];
                    if (act) {
                        [rv addObject:act];
                    }else{
                        RZLog(RZLogError, @"Failed to process activity %@", activityId);
                        saveBadJson =true;
                    }
                    [act release];
                }else{
                    RZLog(RZLogError, @"Got non dictionary %@", one);
                    saveBadJson =true;
                }
            }
            self.activities = rv;
        }else if ([parsed isKindOfClass:[NSDictionary class]]){
            NSDictionary * json = parsed;
            if (json[@"errors"]) {
                RZLog(RZLogError, @"Got error %@", json[@"errors"]);
                saveBadJson =true;
            }
            if (json[@"message"]) {
                RZLog(RZLogError, @"Got message %@", json[@"message"]);
                saveBadJson =true;
            }

        }else{
            RZLog(RZLogError, @"Got unknown class: %@", NSStringFromClass([parsed class]));
            saveBadJson =true;
        }
    }else{
        RZLog(RZLogError, @"Failed to parse json %@", e);
        saveBadJson =true;
    }

    if (saveBadJson) {
        self.hasError = true;
        NSString * fn = @"error_strava_list.json";
        [input writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true];

    }

    return nil;
}
-(NSUInteger)parsedCount{
    return (self.activities).count;
}
@end
