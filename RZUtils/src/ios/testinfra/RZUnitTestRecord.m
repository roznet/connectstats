//
//  UnitTestRecord.m
//  MacroDialTest
//
//  Created by brice on 04/03/2009.
//  Copyright 2009 ro-z.net. All rights reserved.
//

#import "RZUnitTestRecord.h"
#import "RZUtils/RZUtils.h"


@implementation UnitTestRecordDetail

+(UnitTestRecordDetail*)detailFor:(NSString*)msg path:(const char*)p line:(unsigned)l function:(const char*)f{
    UnitTestRecordDetail * rv  = RZReturnAutorelease([[self alloc] init]);
    if (rv) {
        rv.message = msg;
        rv.path = p?[NSString stringWithUTF8String:p]:nil;
        rv.line= l;
        rv.function = f?[NSString stringWithUTF8String:f]:nil;
    }
    return rv;
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_message release];
    [_path release];
    [_function release];
    [super dealloc];
}
#endif

-(NSString*)description{
    return self.function?[NSString stringWithFormat:@"<%@:%d %@>", self.function, self.line, self.message]:self.message;
}
@end

@implementation RZUnitTestRecord
@synthesize total, failure, success, failureDetails, timeTaken,log;
-(RZUnitTestRecord*)init{
	self = [super init];
	if( self ){
		total	=	0;
		failure	=	0;
		success	=	0;
		failureDetails	= [[NSMutableArray alloc] init];
		log				= [[NSMutableArray alloc] init];
	}
	
	return( self );
}

#if ! __has_feature(objc_arc)
-(void)dealloc{
	[failureDetails release];
	[log			release];
    [_session release];
    [_testClass release];
    [_testDefinition release];
	[super dealloc];
}
#endif

-(void)recordResult:(bool)aRes tag:(NSString*)aTag{
	total++;
	if( aRes ) { 
		success ++; 
	} else { 
		failure++; 
		[failureDetails addObject:[UnitTestRecordDetail detailFor:aTag path:nil line:0 function:nil]];
	};
}

-(void)logString:(NSString*)aStr{
	[log addObject:aStr];
}

-(NSUInteger)numberOfDetails{
	return( [failureDetails count] );
}
-(NSString*)detailAtIndex:(int)i{
	return( [failureDetails objectAtIndex:i] );
}
-(NSString*)detailAsHTML{
	NSMutableString * html = [NSMutableString stringWithFormat:@"<html><head>%@</head><body>",
								@"<style type=\"text/css\">table { border: thin solid #0000FF; border-collapse: collapse; } td,th { border: thin solid #0000FF; }</style>"
							  ];
    [html appendFormat:@"<code>[%@ %@]</code>\n", self.testClass, self.testDefinition[TK_SEL] ];
    [html appendFormat:@"<p>%@</p>", self.testDefinition[TK_DESC]];
	[html appendFormat:@"<table><tr><td>Total</td><td>%d</td></tr><tr><td>Failure</td><td>%d</td></tr></table>",
	 (int)total, (int)failure];
	[html appendString:@"<p><table><tr><td colspan=2>Messages for Failures</td></tr>"];
	
	for (int i=0; i<[failureDetails count]; i++) {
        UnitTestRecordDetail * detail = failureDetails[i];
		[html appendFormat:@"<tr><td>%d</td><td>%@</td></tr>", i+1, [detail.description stringByEscapingForHTML]];
	}
	
	[html appendString:@"</table><p /><table><tr><td>Log</td></tr>"];
	for( int i = 0 ; i < [log count]; i++ ){
		NSString* l = [log objectAtIndex:i];
		if( l )
			[html appendFormat:@"<tr><td><pre>%@</pre></td></tr>", l];
	}
	
	[html appendString:@"</table></body></html>"];
	
	return( html );
}
@end
