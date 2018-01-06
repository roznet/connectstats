//
//  RZTestRunner.h
//  GarminConnect
//
//  Created by Brice Rosenzweig on 03/01/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZUtils/RZUtils.h"
#import "RZUnitTest.h"
#import "RZUnitTestRecord.h"


@class RZUnitTestRunner;

extern NSString * kRZUnitTestAllDone;
extern NSString * kRZUnitTestNewResults;

@protocol RZUnitTestSource <NSObject>

-(NSArray*)testClassNames;

@end

@interface RZUnitTestRunner : RZParentObject<UnitTestDelegate>

@property (nonatomic,retain) NSArray*collectedResults;
@property (nonatomic,retain) NSObject<RZUnitTestSource>*testSource;
@property (nonatomic,assign) BOOL running;

-(void)run;
-(RZUnitTest*)current;
-(void)clearResults;

@end
