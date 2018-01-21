//  MIT Licence
//
//  Created on 04/03/2009.
//
//  Copyright (c) None Brice Rosenzweig.
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

#define TK_SEL  @"selector"
#define TK_DESC @"description"
#define TK_SESS @"session"
#define TK_ARG  @"arg"


@interface UnitTestRecordDetail : NSObject
@property (nonatomic,retain) NSString * message;
@property (nonatomic,retain) NSString * path;
@property (nonatomic,retain) NSString * function;
@property (nonatomic,assign) unsigned line;


+(UnitTestRecordDetail*)detailFor:(NSString*)msg path:(const char*)p line:(unsigned)l function:(const char*)f;

@end


@interface RZUnitTestRecord : NSObject {
	NSUInteger success;
	NSUInteger failure;
	NSUInteger total;
	NSMutableArray * failureDetails;
	NSTimeInterval timeTaken;
	NSMutableArray * log;
    NSString * description;
}
@property NSUInteger success;
@property NSUInteger failure;
@property NSUInteger total;
@property NSTimeInterval timeTaken;
@property (nonatomic,retain) NSMutableArray<UnitTestRecordDetail*> * failureDetails;
@property (nonatomic,retain) NSMutableArray<NSString*> * log;
@property (nonatomic,retain) NSDictionary * testDefinition;
@property (nonatomic,retain) NSString *testClass;
@property (nonatomic,retain) NSString *session;

-(void)recordResult:(bool)aRes tag:(NSString*)aTag;
-(NSUInteger)numberOfDetails;
-(NSString*)detailAtIndex:(int)i;
-(NSString*)detailAsHTML;
-(void)logString:(NSString*)aStr;

@end
