//  MIT Licence
//
//  Created on 06/07/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "NSDateComponents+RZHelper.h"
#import <RZUtils/RZMacros.h>

@implementation NSDateComponents (RZHelper)

+(NSDateComponents*)dateComponentsFromString:(NSString*)str{
    NSDateComponents * dateComponents = RZReturnAutorelease([[NSDateComponents alloc] init]);
    NSScanner * scan = [NSScanner scannerWithString:str.lowercaseString];
    int val;
    NSString * unit;
    if (![scan scanInt:&val]) {
        return nil;
    }
    if (![scan scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"myw"] intoString:&unit]) {
        return nil;
    }

    if ([unit isEqualToString:@"m"]) {
        dateComponents.month = val;
    }else if ([unit isEqualToString:@"y"]){
        dateComponents.year = val;
    }else if ([unit isEqualToString:@"w"]){
        dateComponents.weekOfYear = val;
    }
    return dateComponents;
}

-(NSInteger)monthWeekOrYear:(NSCalendarUnit)unit{
    if (unit==NSCalendarUnitYear) {
        return self.year;
    }else if (unit==NSCalendarUnitMonth){
        return self.month;
    }else if (unit==NSCalendarUnitWeekOfYear){
        return self.weekOfYear;
    }
    return 0;
}
+(NSDateComponents*)dateComponentsForCalendarUnit:(NSCalendarUnit)aUnit withValue:(NSInteger)val{
    NSDateComponents * rv = RZReturnAutorelease([[NSDateComponents alloc] init]);
    if (rv) {
        if (aUnit == NSCalendarUnitWeekOfYear) {
            rv.weekOfYear = val;
        }else if(aUnit == NSCalendarUnitMonth){
            rv.month = val;
        }else if(aUnit == NSCalendarUnitYear){
            rv.year = val;
        }else{
            rv = nil;
        }

    }
    return rv;
}
@end
