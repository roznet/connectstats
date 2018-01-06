//
//  UnitTestRecord.h
//  MacroDialTest
//
//  Created by brice on 04/03/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
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
@property (nonatomic,retain) NSMutableArray * failureDetails;
@property (nonatomic,retain) NSMutableArray * log;
@property (nonatomic,retain) NSDictionary * testDefinition;
@property (nonatomic,retain) NSString *testClass;
@property (nonatomic,retain) NSString *session;

-(void)recordResult:(bool)aRes tag:(NSString*)aTag;
-(NSUInteger)numberOfDetails;
-(NSString*)detailAtIndex:(int)i;
-(NSString*)detailAsHTML;
-(void)logString:(NSString*)aStr;

@end
