//  MIT Licence
//
//  Created on 08/05/2016.
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

#import <Foundation/Foundation.h>
#import "FITFitMessage.h"

@interface FITFitFile : NSObject<NSFastEnumeration>

/**
 A fit file consists of a dictionary of FITFitMessage
    each message is an array of FITFitMessageFields
    each FITFitMessageFields is a dictionary of field:String -> FITFitFieldValue
 */
+(FITFitFile*)fitFile;

-(void)addMessageFields:(FITFitMessageFields*)fields forMessageType:(NSString*)type;

-(NSArray<NSString*>*)allMessageTypes;
-(FITFitMessage*)messageForType:(NSString*)type;

-(BOOL)containsMessageType:(NSString*)type;

/**
 All the message fields of the fitFiles in order
 in which they need to be saved

 @return array of messages
 */
-(NSArray<FITFitMessageFields*>*)allMessageFields;

/**
 Attempt at finding a default appropriate message

 @return default message type to use
 */
-(NSString*)defaultMessageType;

-(FITFitMessage*)objectForKeyedSubscript:(NSString*)type;
@end
