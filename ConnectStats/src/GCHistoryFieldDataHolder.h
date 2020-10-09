//  MIT License
//
//  Created on 09/10/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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
#import "GCField.h"
#import "GCAppConstants.h"

NS_ASSUME_NONNULL_BEGIN

//
// For each field, sum/avg queried from db
@interface GCHistoryFieldDataHolder : NSObject

@property (nonatomic,retain) GCField * field;
@property (nonatomic,readonly) NSString * displayField;

-(GCNumberWithUnit*)maxWithUnit:(gcHistoryStats)which;
-(GCNumberWithUnit*)minWithUnit:(gcHistoryStats)which;

-(GCNumberWithUnit*)averageWithUnit:(gcHistoryStats)which;
-(GCNumberWithUnit*)sumWithUnit:(gcHistoryStats)which;
-(GCNumberWithUnit*)weightWithUnit:(gcHistoryStats)which DEPRECATED_MSG_ATTRIBUTE("use sum or avg");
-(GCNumberWithUnit*)weightedSumWithUnit:(gcHistoryStats)which;
-(GCNumberWithUnit*)weightedAverageWithUnit:(gcHistoryStats)which;
-(GCNumberWithUnit*)countWithUnit:(gcHistoryStats)which;
-(double)count:(gcHistoryStats)which;

-(void)addNumberWithUnit:(GCNumberWithUnit*)num DEPRECATED_MSG_ATTRIBUTE("use sum or avg");
-(void)addNumberWithUnit:(GCNumberWithUnit*)num withTimeWeight:(double)tw distWeight:(double)dw for:(gcHistoryStats)which;

// Used for testing
-(void)addSumWithUnit:(GCNumberWithUnit*)num andCount:(NSUInteger)count for:(gcHistoryStats)which;

@end

NS_ASSUME_NONNULL_END
