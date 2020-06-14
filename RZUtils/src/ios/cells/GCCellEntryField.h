//  MIT Licence
//
//  Created on 07/10/2012.
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

#import <UIKit/UIKit.h>


@protocol GCEntryFieldProtocol <NSObject>

-(NSInteger)identifierInt;

@optional
-(NSString*)text;
-(NSUInteger)selected;
-(BOOL)on;
-(NSArray*)choices;
-(BOOL)resignFirstResponder;

@end

typedef void(^GCCellEntryFieldCompletion)(NSObject<GCEntryFieldProtocol>*cell);

@protocol GCEntryFieldDelegate <NSObject>

-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell;
-(UINavigationController*)baseNavigationController;
-(UINavigationItem*)baseNavigationItem;

@end

@interface GCCellEntryField : UITableViewCell<GCEntryFieldProtocol>
@property (nonatomic,retain)	NSObject<GCEntryFieldDelegate> * entryFieldDelegate;
@property (nonatomic,copy)      GCCellEntryFieldCompletion entryFieldCompletion;
@property						NSInteger identifierInt;

@end
