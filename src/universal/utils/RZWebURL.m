//  MIT Licence
//
//  Created on 01/04/2009.
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

#import "RZWebURL.h"
#import "RZMacros.h"
NSString * RZWebEncodeURLwGet( NSString * URL, NSDictionary * getparams ){
    return [NSString stringWithFormat:@"%@?%@", URL,RZWebEncodeDictionary(getparams)];
}

NSString * RZWebEncodeDictionary( NSDictionary * aDict ){
	NSMutableString * data = [NSMutableString string];
	BOOL started= false;
	for( NSString*key in aDict ){
		NSString * val = aDict[key];
		if( started )
			[data appendString:@"&"];
		[data appendString:RZWebEncodeURLPart(key)];
		[data appendString:@"="];
		[data appendString:RZWebEncodeURLPart(val)];
		started = TRUE;
	}
	return( data );
}

NSString * RZWebEncodeURLPart( NSString * unescaped){
    static NSCharacterSet * allowedSet = nil;
    if (allowedSet == nil) {
        NSMutableCharacterSet * temp = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [temp removeCharactersInString:@"&+=?"];
        allowedSet =  RZReturnRetain(temp);
    }

    return [unescaped stringByAddingPercentEncodingWithAllowedCharacters:allowedSet];
}

NSString * RZWebEncodeURL( NSString * unescaped )
{
    return [unescaped stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

NSString * RZWebRandomUserAgent(){
    NSArray<NSString*> * list = @[
                                  @"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1",
                                  @"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E188a Safari/601.1",
                                  @"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
                                  @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36",
                                  @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A",
                                  @"Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko",
                                  @"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246"
        ];

    static NSUInteger i = 0;
    if (list.count <= i) {
        i=0;
    }
    return list[i];
    //return list[i++];
}
