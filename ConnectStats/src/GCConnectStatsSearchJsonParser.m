//  MIT License
//
//  Created on 08/06/2019 for ConnectStats
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



#import "GCConnectStatsSearchJsonParser.h"
#import "GCActivity+Import.h"
#import "GCService.h"

@implementation GCConnectStatsSearchJsonParser

-(instancetype)initWithData:(NSData*)jsonData{
    self = [super init];
    if (self) {
        NSError *e = nil;
        
        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        
        if (json==nil) {
            self.activities = nil;
            self.success = false;
            RZLog(RZLogError, @"parsing failed %@", e);
        }else{
            
            NSArray * activityList = json[@"activityList"];
            if ([activityList isKindOfClass:[NSArray class]]) {
                NSMutableArray * found = [NSMutableArray arrayWithCapacity:activityList.count];
                for (NSDictionary * one in activityList) {
                    if ([one isKindOfClass:[NSDictionary class]]) {
                        NSString * aId = [[GCService service:gcServiceConnectStats] activityIdFromServiceId:one[@"cs_activity_id"]];
                        if ([aId isKindOfClass:[NSString class]]) {
                            GCActivity * act = [[GCActivity alloc] initWithId:aId andConnectStatsData:one];
                            [found addObject:act];
                            [act release];
                        }
                    }
                }
                self.activities = found;
                self.success = true;
            }
        }
        
    }
    return self;
}

-(void)dealloc{
    [_activities release];
    [super dealloc];
}

-(NSUInteger)parsedCount{
    return self.activities.count;
}

@end
