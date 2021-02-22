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

#define GC_STARTING_FILE @"starting.log"

BOOL kOpenTemporary = false;

@implementation GCAppDelegate (Swift)

-(void)handleAppRating{
    [self initiateAppRating];
}

-(void)handleFitFile:(NSData*)fitData{
    if( fitData.length  > 12){// minimum size for fit file include headers
        GCActivity * fitAct = RZReturnAutorelease([[GCActivity alloc] initWithId:[self.urlToOpen.path lastPathComponent] fitFileData:fitData fitFilePath:self.urlToOpen.path startTime:[NSDate date]]);
        RZLog(RZLogInfo, @"Opened temp fit %@", [RZMemory formatMemoryInUse]);
        if( kOpenTemporary ){
            [self.organizer registerTemporaryActivity:fitAct forActivityId:fitAct.activityId];
        }else{
            
            [self.organizer registerActivity:fitAct forActivityId:fitAct.activityId];
            [self.organizer registerActivity:fitAct.activityId withTrackpoints:fitAct.trackpoints andLaps:fitAct.laps];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self handleFitFileDone:fitAct.activityId];
        });
    }else{
        RZLog(RZLogWarning, @"Handling fit file with no data")
    }
}

-(void)handleFitFileDone:(NSString*)aId{
    [self.actionDelegate focusOnActivityId:aId];
}
-(void)stravaSignout{
    [GCStravaRequestBase signout];
}

-(BOOL)startInit{
    NSString * filename = [RZFileOrganizer writeableFilePathIfExists:GC_STARTING_FILE];
    NSUInteger attempts = 1;
    NSError * e = nil;

    if (filename) {

        NSString * sofar = [NSString stringWithContentsOfFile:filename
                                            encoding:NSUTF8StringEncoding error:&e];

        if (sofar) {
            attempts = MAX(1, [sofar integerValue]+1);
        }else{
            RZLog(RZLogError, @"Failed to read initfile %@", e.localizedDescription);
        }
    }

    NSString * already = [NSString stringWithFormat:@"%lu",(unsigned long)attempts];
    if(![already writeToFile:[RZFileOrganizer writeableFilePath:GC_STARTING_FILE] atomically:YES encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save startInit %@", e.localizedDescription);
    }

    return attempts < 3;
}

-(void)startSuccessful{
    static BOOL once = false;
    if (!once) {
        RZLog(RZLogInfo, @"Started");
        [RZFileOrganizer removeEditableFile:GC_STARTING_FILE];
        once = true;
        
        [self settingsUpdateCheckPostStart];
        [self startSuccessfulSwift];
    }
}

@end
