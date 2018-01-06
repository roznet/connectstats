//  MIT Licence
//
//  Created on 30/05/2009.
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

#import "RZAppConfig.h"

@implementation RZAppConfig

+(NSMutableDictionary*)	settings{
	return( nil );
}

#pragma mark String
+(NSString*)configGetString:(NSString*)key	defaultValue:(NSString*)aDefault{
	NSString * rv = [self settings][key];
	if( !rv ){
		rv = aDefault;
		[self configSet:key stringVal:aDefault];
	}
	return( rv );
}
+(void)configSet:(NSString*)key	stringVal:(NSString*)aValue{
	[self settings][key] = aValue;
}

#pragma mark DOUBLE
+(double)configGetDouble:	(NSString*)key	defaultValue:(double)aDefault{
	double rv = aDefault;
	NSNumber * val = [self settings][key];
	if( val != nil){
		rv = val.doubleValue;
	}else{//make sure the default is persisted to avoid surprises and inconsistencies
		[self configSet:key doubleVal:aDefault];
	}
	return( rv );
}
+(void)configSet:		(NSString*)key	doubleVal:(double)aValue{
	[self settings][key] = @(aValue);
}


#pragma mark INT
+(NSInteger)configGetInt:	(NSString*)key	defaultValue:(NSInteger)aDefault{
	NSInteger rv = aDefault;
	NSNumber * val = [self settings][key];
	if( val != nil ){
		rv = val.intValue;
	}else{//make sure the default is persisted to avoid surprises and inconsistencies
		[self configSet:key intVal:aDefault];
	}
	return( rv );
}
+(void)configSet:(NSString*)key	intVal:(NSInteger)aValue{
	[self settings][key] = @(aValue);

}

+(NSInteger)configIncInt:	(NSString*)key{
	NSInteger counter = [self configGetInt:key defaultValue:0];
	counter++;
	[self configSet:key intVal:counter];
	return( counter );
}

#pragma mark Bool
+(BOOL)configGetBool:(NSString*)key defaultValue:(BOOL)aDefault{
	BOOL rv = aDefault;
	NSNumber * val = [self settings][key];
	if( val != nil){
		rv = val.boolValue;
	}else{//make sure the default is persisted to avoid surprises and inconsistencies
		[self configSet:key boolVal:aDefault];
	}
	return( rv );
}

+(void)configSet:(NSString*)key	boolVal:(BOOL)value{
	[self settings][key] = @(value);
}
+(BOOL)configToggleBool:(NSString*)key{
	BOOL rv = FALSE;
	if( [self configGetBool:key defaultValue:FALSE] ){
		[self configSet:key boolVal:FALSE];
		rv = FALSE;
	}else{
		[self configSet:key boolVal:TRUE];
		rv = TRUE;
	}
	return( rv );
}

#pragma mark Array

+(NSArray*)	configGetArray:	(NSString*)key	defaultValue:(NSArray*)aDefault{
	NSArray * rv = [self settings][key];
	if( !rv ){
		rv = aDefault;
		[self configSet:key arrayVal:aDefault];
	}
	return( rv );

}
+(void)	configSet:		(NSString*)key  arrayVal:(NSArray*)aValue{
	[self settings][key] = aValue;
}


#pragma mark Events

+(NSInteger)getEventOccurence:(NSString*)name{
	NSString*internalKey	= [NSString stringWithFormat:@"event_%@", name];
	return( [self configGetInt:internalKey defaultValue:0] );
}


+(void)recordEvent:(NSString*)name every:(int)aStep{
	NSString*internalKey	= [NSString stringWithFormat:@"event_%@",		name];
	NSString*lastRecordKey	= [NSString stringWithFormat:@"event_last_%@",	name];

	NSInteger counter = [self configIncInt:internalKey];
    NSInteger last    = [self configGetInt:lastRecordKey defaultValue:0];

	BOOL report = FALSE;

	if( aStep == RECORDEVENT_STEP_EVERY ){
		report = TRUE;
	}else if( aStep == RECORDEVENT_STEP_FIRSTONLY ){
		if( last == 0 )
			report = TRUE;
	}else {
		NSInteger rs = counter / aStep;
		NSInteger ls = last / aStep;
		if( rs > ls )
			report = TRUE;
	}

	if( report ){
		[self configSet:lastRecordKey intVal:counter];
		[self publishEvent:name];
	};
}

+(void)publishEvent:(NSString*)name{
}
@end
