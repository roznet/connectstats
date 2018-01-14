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

#import "FITFitFile.h"
#import "RZUtils/RZUtils.h"

@interface FITFitFile ()
/**
 All Message Fields received in order
 */
@property (nonatomic,strong) NSMutableArray<FITFitMessageFields*> * messages;
/**
 Message Organized by types
 */
@property (nonatomic,strong) NSDictionary<NSString*,FITFitMessage*> * messagesByTypes;

@end

@implementation FITFitFile

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_messages release];
    [_messagesByTypes release];
    [super dealloc];
}
#endif
+(FITFitFile*)fitFile{
    return RZReturnAutorelease([[self alloc] init]);
}
-(void)addMessageFields:(FITFitMessageFields*)fields forMessageType:(NSString*)type{
    if (self.messages == nil) {
        self.messages = [NSMutableArray array];
    }
    if (self.messagesByTypes == nil) {
        self.messagesByTypes = @{};
    }

    FITFitMessage * message = self.messagesByTypes[type];
    if (message == nil) {
        message = [FITFitMessage messageWithType:type];
        self.messagesByTypes = [self.messagesByTypes dictionaryByAddingEntriesFromDictionary:@{type:message}];
    }
    [message addMessageFields:fields];
    [self.messages addObject:fields];

}

-(NSString*)defaultMessageType{
    static NSArray<NSString*>*preferred = nil;
    if( preferred == nil){
        preferred = @[ @"session", @"record", @"file_id"];
    }

    NSString * rv = nil;
    for (NSString * attempt in preferred) {
        if( self.messagesByTypes[attempt]){
            rv = attempt;
            break;
        }
    }
    if(rv == nil && self.messagesByTypes.count > 0){
        rv = self.messagesByTypes.allKeys[0];
    }
    return rv ?: @"file_id";
}

-(NSArray<FITFitMessageFields*>*)allMessageFields{
    return self.messages;
}

-(NSArray*)allMessageTypes{
    return _messagesByTypes.allKeys;
}
-(FITFitMessage*)messageForType:(NSString*)type{
    return _messagesByTypes[type];
}

-(BOOL)containsMessageType:(NSString*)type{
    return _messagesByTypes[type] != nil;
}

-(FITFitMessage*)objectForKeyedSubscript:(NSString *)type{
    return _messagesByTypes[type];
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [self.messagesByTypes countByEnumeratingWithState:state objects:buffer count:len];
}

@end
