//  MIT License
//
//  Created on 22/04/2021 for ConnectStats
//
//  Copyright (c) 2021 Brice Rosenzweig
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



@import Foundation;

@class GCActivitySummaryValue;
@class GCActivityMetaValue;
@class GCActivity;

NS_ASSUME_NONNULL_BEGIN

@protocol GCActivityUpdateRecordProtocol <NSObject> 

-(void)recordFor:(GCActivity*)act newValue:(GCActivitySummaryValue*)value;
-(void)recordFor:(GCActivity*)act changedValue:(GCActivitySummaryValue*)valuefrom to:(GCActivitySummaryValue*)valueto;

-(void)recordFor:(GCActivity*)act newMeta:(GCActivityMetaValue*)value;
-(void)recordFor:(GCActivity*)act changedMeta:(GCActivityMetaValue*)valuefrom to:(GCActivityMetaValue*)valueto;

-(void)recordFor:(GCActivity*)act changedAttribute:(NSString*)attr from:(NSString*)from to:(NSString*)to;

@end

NS_ASSUME_NONNULL_END
