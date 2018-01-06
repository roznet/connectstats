//  MIT Licence
//
//  Created on 20/12/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

extern NSString * kTSRecordTypeSession;
extern NSString * kTSRecordTypeEventsDb;
extern NSString * kTSRecordTypePlayer;

extern NSString * kTSRecordFieldSessionId;
extern NSString * kTSRecordFieldEventDb;
extern NSString * kTSRecordFieldEventDbName;
extern NSString * kTSRecordFieldEventDbReference;

extern NSString * kTSRecordFieldStartTime;
extern NSString * kTSRecordFieldDuration;
extern NSString * kTSRecordFieldScoreRule;
extern NSString * kTSRecordFieldWinner;
extern NSString * kTSRecordFieldNumberOfEvents;
extern NSString * kTSRecordFieldPlayer;
extern NSString * kTSRecordFieldOpponent;
extern NSString * kTSRecordFieldPlayerDescription;
extern NSString * kTSRecordFieldOpponentDescription;
extern NSString * kTSRecordFieldResult;


extern NSString * kTSRecordFieldFirstName;
extern NSString * kTSRecordFieldLastName;

@interface TSCloudTypes : NSObject

@end
