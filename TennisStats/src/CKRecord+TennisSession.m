//  MIT Licence
//
//  Created on 24/01/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "CKRecord+TennisSession.h"
#import "TSCloudTypes.h"
#import "TSTennisResult.h"
#import "TSAppGlobal.h"
#import "TSCloudOrganizer.h"

@implementation CKRecord (TennisSession)


-(NSString*)playerDescription{
    return self[kTSRecordFieldPlayerDescription];
}


-(NSString*)opponentDescription{
    return self[kTSRecordFieldOpponentDescription];
}

-(NSString*)scoreDescription{
    NSArray * upacked = self[kTSRecordFieldResult];
    NSString * rv = NSLocalizedString(@"No Scores", @"Score");
    if (upacked && [upacked isKindOfClass:[NSArray class]]) {
        TSTennisResult * res = [[[TSTennisResult alloc] init] unpack:upacked];
        if (res) {
            rv = [res asString];
        }
    }
    return rv;
}

-(NSString*)startTimeDescription{
    NSDate * start = self[kTSRecordFieldStartTime];
    NSString * rv = self[kTSRecordFieldSessionId];
    if (start && [start isKindOfClass:[NSDate class]]) {
        static NSDateFormatter * formatter = nil;
        if (formatter==nil) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterShortStyle;
        }
        rv = [formatter stringFromDate:start];

    }
    return rv;
}

-(NSString*)userNameDescription{
    NSString * rv = [[TSAppGlobal cloud] userName:self.creatorUserRecordID];
    return rv;
}

-(NSString*)durationDescription{
    NSNumber * durN = self[kTSRecordFieldDuration];
    NSString * rv = @"";
    if (durN && [durN isKindOfClass:[NSNumber class]] && [durN doubleValue] != 0.) {
        rv = [NSString stringWithFormat:@"Duration %@", [GCNumberWithUnit numberWithUnitName:@"second" andValue:[durN doubleValue]]];
    }
    return rv;
}

@end
