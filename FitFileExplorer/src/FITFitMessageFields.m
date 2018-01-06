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

#import "FITFitMessageFields.h"

@interface FITFitMessageFields ()

@property (nonatomic,strong) NSDictionary<NSString*,FITFitFieldValue*> * fields;
@property (nonatomic) NSUInteger messageIndex;
@end

@implementation FITFitMessageFields
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_fields release];
    [super dealloc];
}
#endif

+(FITFitMessageFields * )fitMessageFields:(NSDictionary*)values atIndex:(NSUInteger)index{
    FITFitMessageFields * rv = [[self alloc] init];
    if (rv) {
        rv.fields = values;
        rv.messageIndex = index;
    }
    return rv;
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%lu fields>", NSStringFromClass([self class]),(unsigned long)self.fields.count];
}
-(NSArray<NSString*>*)allFieldNames{
    return _fields.allKeys;
}

-(FITFitFieldValue*)valueForFieldKey:(NSString*)key{
    return _fields[key];
}

-(FITFitFieldValue*)objectForKeyedSubscript:(NSString*)key{
    return _fields[key];
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [_fields countByEnumeratingWithState:state objects:buffer count:len];
}


@end
