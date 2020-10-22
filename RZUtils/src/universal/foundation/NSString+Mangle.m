//  MIT Licence
//
//  Created on 24/11/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "NSString+Mangle.h"
#import <RZUtils/RZMacros.h>
#import "NSArray+Map.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Mangle)

+(NSData*)mangledDataFromData:(NSData*)adata withKey:(NSString*)key{
    if (key.length==0) {
        return adata;
    }
    NSMutableData * rv = RZReturnAutorelease([adata mutableCopy]);
    NSData * keyData = [key dataUsingEncoding:NSUTF8StringEncoding];

    uint8_t *bytes = (uint8_t *)rv.mutableBytes;
    uint8_t *pattern = (uint8_t*)keyData.bytes;
    size_t patternLengthInBytes = keyData.length;

    for(size_t index = 0; index < rv.length; index++)
        bytes[index] ^= pattern[index % patternLengthInBytes];

    return rv;
}

-(NSData*)mangledDataWithKey:(NSString*)key{
    return [NSString mangledDataFromData:[[NSString stringWithFormat:@"br%@ice",self] dataUsingEncoding:NSUTF8StringEncoding] withKey:key];
}

+(NSString*)stringFromMangedData:(NSData*)ad withKey:(NSString*)key{
    if (ad.length==0) {
        return @"";
    }
    NSString * tmp =RZReturnAutorelease([[NSString alloc] initWithData:[NSString mangledDataFromData:ad withKey:key] encoding:NSUTF8StringEncoding]);
    return [tmp substringWithRange:NSMakeRange(2, tmp.length-5)];
}

-(NSArray*)charactersInSet:(NSCharacterSet*)charSet{
    NSScanner * scanner = [NSScanner scannerWithString:self];
    //[scanner setCharactersToBeSkipped:validSet];
    NSMutableDictionary * found = [NSMutableDictionary dictionary];
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToCharactersFromSet:charSet intoString:nil];
        NSString * one = nil;
        if ([scanner scanCharactersFromSet:charSet intoString:&one]) {
            [one enumerateSubstringsInRange:NSMakeRange(0, one.length)
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString*report, NSRange inSubstringRange, NSRange inEnclosingRange, BOOL *outStop){
                                     found[report] = @1;
                                 }];
        };
    }

    return  [[found allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

-(NSArray*)specialCharacters{
    NSMutableCharacterSet * validSet = [NSMutableCharacterSet lowercaseLetterCharacterSet];
    [validSet formUnionWithCharacterSet:[NSMutableCharacterSet uppercaseLetterCharacterSet]];
    [validSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];

    NSCharacterSet * specialSet = [validSet invertedSet];
    return [self charactersInSet:specialSet];
}

-(NSString*)specialCharacterReplacedBySeparator:(NSString*)sep{
    NSCharacterSet * specialChar = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSArray * separated = [self componentsSeparatedByCharactersInSet:specialChar];
    separated = [separated arrayByRemovingObjectsIn:@[@""]];
    return [separated componentsJoinedByString:sep];
}

-(NSString*)stringByEscapingForHTML{
    return [[[[[self stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"]
               stringByReplacingOccurrencesOfString: @"\"" withString: @"&quot;"]
              stringByReplacingOccurrencesOfString: @"'" withString: @"&#39;"]
             stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"]
            stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
}

-(NSString*)sha256String{
    NSData * stringdata = [self dataUsingEncoding:NSUTF8StringEncoding];;

    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256( stringdata.bytes, (CC_LONG)stringdata.length, result );

    NSMutableString *rv = [NSMutableString string];
    for (int i=0; i < CC_SHA256_DIGEST_LENGTH; i++) {
      [rv appendFormat:@"%02x", result[i]];
    }
    return rv;
}
@end
