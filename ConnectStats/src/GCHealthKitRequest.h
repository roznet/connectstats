//  MIT Licence
//
//  Created on 20/08/2014.
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
#import "GCWebRequest.h"
#import "GCFields.h"
#ifdef GC_USE_HEALTHKIT
@import HealthKit;
#endif

@interface GCHealthKitRequest : NSObject<GCWebRequest>
@property (nonatomic,retain) NSArray * results;
@property (nonatomic,retain) NSError * error;
@property (nonatomic,assign) GCWebStatus status;
@property (nonatomic,retain) NSObject<GCWebRequestDelegate>* delegate;
@property (nonatomic,retain) NSMutableDictionary * data;

#ifdef GC_USE_HEALTHKIT
@property (nonatomic,readonly) HKHealthStore * healthStore;
#endif


+(instancetype)request;

//Should Implement

+(BOOL)isSupported;

-(BOOL)isLastRequest;
-(void)nextQuantityType;
#ifdef GC_USE_HEALTHKIT
-(HKQuantityType*)currentQuantityType;
+(HKStatisticsOptions)optionForIdentifier:(NSString*)identifier;
+(GCUnit*)unitForIdentifier:(NSString*)identifier;
+(NSString*)fieldForIdentifier:(NSString*)identifier prefix:(NSString*)prefix;
+(gcFieldFlag)fieldFlagForIdentifier:(NSString*)identifier;
#endif

-(void)resetAnchor;

-(void)processDone;

-(void)saveCollectedData:(NSDictionary*)dict withSuffix:(NSString*)suffix andId:(NSString*)aid;

+(NSString*)dayActivityId:(NSDate*)date;

@end
