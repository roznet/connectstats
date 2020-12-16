//  MIT Licence
//
//  Created on 02/10/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCGarminSearchModernJsonParser.h"
@import RZUtilsCore;
#import "GCActivity+Import.h"

@implementation GCGarminSearchModernJsonParser

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
                        NSNumber * aId = one[@"activityId"];
                        if ([aId isKindOfClass:[NSNumber class]]) {
                            GCActivity * act = [[GCActivity alloc] initWithId:[aId stringValue] andGarminData:one];
                            [found addObject:act];
                            [act release];
                            
                            if( [act.metaData[@"ownerDisplayName"].display isEqualToString:@"garmin.connect"] ){
                                RZLog(RZLogWarning, @"Spurious activity %@", act.activityId);
                            }
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
