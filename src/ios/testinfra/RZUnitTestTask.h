//
//  RZUnitTestTask.h
//  GarminConnect
//
//  Created by Brice Rosenzweig on 03/01/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZUnitTest.h"

typedef NS_ENUM(NSUInteger, utTaskStatus){
    utTaskWaiting,
    utTaskRunning,
    utTaskDone
};

@interface RZUnitTestTask : NSObject
@property (nonatomic,retain) RZUnitTest * unitTest;
@property (nonatomic,retain) NSDictionary * def;
@property (nonatomic,assign) utTaskStatus status;

+(RZUnitTestTask*)taskWith:(RZUnitTest*)ut and:(NSDictionary*)d;

@end
