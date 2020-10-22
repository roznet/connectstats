//  MIT Licence
//
//  Created on 23/10/2014.
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

#import <RZUtils/TSDataCell.h>

@interface TSDataCell ()
@property (nonatomic,retain) NSString * field;
@property (nonatomic,retain) NSNumber * sum;
@property (nonatomic,assign) NSUInteger count;
@end

@implementation TSDataCell

+(NSArray*)cellForFields:(NSArray*)fields{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:fields.count];
    if (rv) {
        for (NSString * field in fields) {
            [rv addObject:[TSDataCell cellForField:field]];
        }
    }
    return rv;
}
+(TSDataCell*)cellForField:(NSString*)field{
    TSDataCell * rv = [[TSDataCell alloc] init];
    if (rv) {
        rv.field = field;
    }
    return rv;
}

-(void)collect:(TSDataRow*)row{
    id val = [row valueForField:_field];
    if (val) {
        if ([val isKindOfClass:[NSNumber class]]) {
            double dval = [val doubleValue];
            if (self.sum==nil) {
                self.sum = @(dval);
            }else{
                self.sum = @( dval + self.sum.doubleValue);
            }
        }
        self.count++;
    }
}

-(id)cellValue:(tsPivotCellType)type{
    switch (type) {
        case tsPivotCount:
            return @(self.count);
            break;
        case tsPivotSum:
            return self.sum;
        case tsPivotSumOrCount:
            return self.sum == nil ? @(self.count) : self.sum  ;
    }
}

-(NSString*)stringValue{
    return self.sum == nil ? [@(self.count) stringValue] : [self.sum stringValue];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:Sum=%@:Cnt=%lu>", @"TSDataCell", self.sum,(unsigned long) self.count ];
}

@end
