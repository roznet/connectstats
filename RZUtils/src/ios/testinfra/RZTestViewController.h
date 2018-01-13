//  MIT Licence
//
//  Created on 25/03/2009.
//
//  Copyright (c) None Brice Rosenzweig.
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
-(NSArray<UIBarButtonItem*>*)additionalLeftNavigationButton;
@end
