//  MIT Licence
//
//  Created on 21/07/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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
@class GCActivityType;
@class GCActivityTypeSelection;

NS_ASSUME_NONNULL_BEGIN

@protocol GCViewActivityTypeButtonDelegate <NSObject>

-(BOOL)useFilter;
-(GCActivityTypeSelection*)activityTypeSelection;
-(void)setupForCurrentActivityTypeSelection:(GCActivityTypeSelection*)selection andFilter:(BOOL)aFilter;
@optional
-(NSArray<GCActivityType*>*)listActivityTypes;
-(BOOL)useColoredIcons;
-(BOOL)ignoreFilter;
@end

@interface GCViewActivityTypeButton : NSObject<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) UIBarButtonItem * activityTypeButtonItem;
@property (nonatomic,retain) NSObject<GCViewActivityTypeButtonDelegate> * delegate;
@property (nonatomic,assign) BOOL matchPrimaryType;

+(GCViewActivityTypeButton*)activityTypeButtonForDelegate:(NSObject<GCViewActivityTypeButtonDelegate>*)del;

-(BOOL)setupBarButtonItem:(nullable UIViewController*)presentingViewController;

@end

NS_ASSUME_NONNULL_END
