//
//  TestViewController.h
//  MacroDialTest
//
//  Created by brice on 25/03/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//
// To Create new test project:
//    - Add the test infra directory
//    - Create a Viewcontroller derived from TestViewController 
//         it should implement doTheTests appropriately and call testFinished at the end

#import <Foundation/Foundation.h>
@import UIKit;
@import RZUtils;
@import RZUtilsTouch;

#import "RZUnitTest.h"
#import "RZUnitTestRunner.h"

@interface RZTestViewController : UIViewController <RZChildObject,GCEntryFieldDelegate,RZUnitTestSource,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,retain)	UITableView*	resultsTableView;
@property (nonatomic,retain)	UIActivityIndicatorView* activityIndicator;
@property (nonatomic,retain)    UIView*         mainView;
@property (nonatomic,assign)    BOOL            runTestOnStartup;
@property (nonatomic,retain)    RZUnitTestRunner * runner;
@property (nonatomic,retain)    NSArray*        displayResults;

-(void)notifyUpdate;

/**
 This method needs to be implemented in derived class
 */
-(NSArray*)allTestClassNames;
@end
