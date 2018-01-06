//  MIT Licence
//
//  Created on 17/11/2012.
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
#import "GCActivity.h"
#import "GCTrackFieldChoices.h"

@class GCFieldsForCategory;

@interface GCActivityLapViewController : UITableViewController<GCCellSimpleGraphDelegate>{
    GCActivity * activity;
    NSUInteger lapIndex;
    NSArray * organizedFields;
}
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,assign) NSUInteger lapIndex;
@property (nonatomic,retain) GCTrackFieldChoices * choices;
@property (nonatomic,retain) NSArray * organizedFields;

-(NSArray<GCFieldsForCategory*>*)setupFields;
-(void)nextLap:(id)cb;
-(void)previousLap:(id)cb;
-(NSArray<GCField*>*)fieldsForSection:(NSInteger)section;


@end
