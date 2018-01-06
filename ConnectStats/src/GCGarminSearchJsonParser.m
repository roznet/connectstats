//  MIT Licence
//
//  Created on 10/09/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCGarminSearchJsonParser.h"
#import "GCActivity+Import.h"

@implementation GCGarminSearchJsonParser
@synthesize activities,totalPages,currentPage,success;

-(instancetype)init{
    return [self initWithString:nil andEncoding:NSUTF8StringEncoding];
}

-(GCGarminSearchJsonParser*)initWithString:(NSString*)theString andEncoding:(NSStringEncoding)encoding{
    return [self initWithData:[[self fixedUpString:theString ] dataUsingEncoding:encoding] ];
}

-(GCGarminSearchJsonParser*)initWithData:(NSData*)jsonData{
    self = [super init];
    if (self) {
        NSError *e = nil;

        NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];

        if (json==nil) {
            activities = nil;
            success = false;
            RZLog(RZLogError, @"parsing failed %@", e);
        }else{

            success = true;
            NSMutableArray * acts = json[@"results"][@"activities"];
            self.activities = [NSMutableArray arrayWithCapacity:acts.count];
            self.childIds = [NSMutableArray array];
            for (NSMutableDictionary * one in acts) {
                NSDictionary* data = one[@"activity"];
                NSString * activityId = [data[@"activityId"] stringValue];
                GCActivity * act = [[GCActivity alloc] initWithId:activityId andGarminData:data];
                [activities addObject:act];
                NSArray * child = data[@"childIds"];
                if (child && [child isKindOfClass:[NSArray class]] && child.count>0 )  {
                    [self.childIds addObjectsFromArray:child];
                    act.childIds = child;
                }
                [act release];
            }

            currentPage = [json[@"results"][@"currentPage"] intValue];
            totalPages = [json[@"results"][@"totalPages"] intValue];
        }
    }
    return self;
}

-(void)dealloc{
    [activities release];
    [_childIds release];

    [super dealloc];
}
-(NSString*)fixedUpString:(NSString*)input{
    BOOL _switch = FALSE;
    NSArray * lines = [input componentsSeparatedByString:@"\n"];
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:lines.count];
    for (NSString*line in lines) {
        NSString * add = line;
        NSRange found = [line rangeOfString:@"activityTimeZone"];
        if (found.location != NSNotFound) {
            if (_switch){
                _switch = FALSE;
                add = [line stringByReplacingOccurrencesOfString:@"activityTimeZone" withString:@"activityTimeZone2"];
            }else{
                _switch = TRUE;
            }
        }
        [rv addObject:add];
    }
    return [rv componentsJoinedByString:@"\n"];
}


@end
