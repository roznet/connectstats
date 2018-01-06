//
//  RZUnitTestTask.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 03/01/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import "RZUnitTestTask.h"
#import "RZUtils/RZUtils.h"

@implementation RZUnitTestTask

+(RZUnitTestTask*)taskWith:(RZUnitTest*)ut and:(NSDictionary*)d{
    RZUnitTestTask * rv = RZReturnAutorelease([[RZUnitTestTask alloc] init]);
    if (rv) {
        rv.unitTest = ut;
        rv.def = d;
        rv.status = utTaskWaiting;
    }
    return rv;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_unitTest release];
    [_def release];
    [super dealloc];
}
#endif

-(NSString*)statusString{
    switch (_status) {
        case utTaskDone:
            return @"Done";
        case utTaskRunning:
            return @"Running";
        case utTaskWaiting:
            return @"Waiting";
    }
    return @"Other";
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@:%@>", NSStringFromClass([self.unitTest class]), self.def[@"session"], [self statusString]];
}


@end
