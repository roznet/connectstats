//
//  TestDetailsViewController.h
//  MacroDialTest
//
//  Created by brice on 20/05/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZUnitTestRecord.h"
#import "RZUnitTestRunner.h"
#import <RZUtils/RZUtils.h>

@interface RZTestDetailsViewController : UIViewController<RZChildObject,RZUnitTestSource> 
@property (retain,nonatomic)	RZUnitTestRecord*record;
@property (retain,nonatomic)    RZUnitTestRunner*runner;
-(RZTestDetailsViewController*)initWithRecord:(RZUnitTestRecord*)aRecord;



@end
