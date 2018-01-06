//  MIT Licence
//
//  Created on 19/09/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCAppDelegate+Swift.h"
#import "ConnectStats-Swift.h"
#import "FITFitFileDecode.h"

@implementation GCAppDelegate (Swift)

-(void)setupSegmentOrganizer{
    dispatch_async(self.worker, ^(){
        //This will also ensureDb
        GCSegmentOrganizer * segments = [[[GCSegmentOrganizer alloc] initWithDb:self.db] autorelease];
        self.segments = segments;
    });
}

-(void)handleFitFile{
    NSData * fitData = [NSData dataWithContentsOfURL:self.urlToOpen];
    FITFitFileDecode * decode = [FITFitFileDecode fitFileDecode:fitData];
    [decode parse];

    GCActivity * fitAct = [[GCActivity alloc] initWithId:[self.urlToOpen.path lastPathComponent] fitFile:decode.fitFile];
    [self.organizer registerTemporaryActivity:fitAct forActivityId:fitAct.activityId];
    [self performSelectorOnMainThread:@selector(handleFitFileDone:) withObject:fitAct.activityId waitUntilDone:NO];
    RZRelease(fitAct);
}

-(void)handleFitFileDone:(NSString*)aId{
    if (self.tabBarController) {
        [self.tabBarController focusOnActivityId:aId];
    }else{
        [self.splitViewController focusOnActivityId:aId];
    }
}

@end
