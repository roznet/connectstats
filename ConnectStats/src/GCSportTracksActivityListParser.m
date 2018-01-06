//  MIT Licence
//
//  Created on 31/03/2014.
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

#import "GCSportTracksActivityListParser.h"
#import "GCActivity+Import.h"
#import "GCService.h"

@implementation GCSportTracksActivityListParser
+(GCSportTracksActivityListParser*)activityListParser:(NSData*)input{
    GCSportTracksActivityListParser * rv = [[[GCSportTracksActivityListParser alloc] init] autorelease];
    if (rv) {
        [rv parse:input];
    }
    return rv;
}
-(void)dealloc{
    [_activities release];
    [_nextUrl release];
    [super dealloc];
}
-(NSUInteger)parsedCount{
    return _activities.count;
}
-(void)parse:(NSData*)input{

    NSError * e = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:input options:NSJSONReadingMutableContainers error:&e];
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSArray *items =json[@"items"];
        self.nextUrl = json[@"next"];
        NSMutableArray * rv = [NSMutableArray arrayWithCapacity:items.count];
        if (items) {
            for (NSDictionary * one in items) {
                if ([one respondsToSelector:@selector(objectForKey:)]) {
                    id uri = one[@"uri"];
                    if (uri) {
                        NSString * activityId =  [GCService serviceIdFromSportTracksUri:uri];
                        activityId = [[GCService service:gcServiceSportTracks] activityIdFromServiceId:activityId];

                        GCActivity * act = [[GCActivity alloc] initWithId:activityId andSportTracksData:one];
                        [rv addObject:act];
                        [act release];
                    }
                }else{
                    RZLog(RZLogError, @"Invalid data of type %@", NSStringFromClass([one class]));
                }
            }
            self.activities = rv;
        }else{
            RZLog(RZLogError, @"missing items");
        }

    }else{
        RZLog(RZLogError, @"Failed to parse json %@", e ?: NSStringFromClass([json class]));
    }
}

@end
