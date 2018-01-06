//  MIT Licence
//
//  Created on 22/09/2013.
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

#import "GCWithingsRequestOnce.h"
#import "GCWithingsRequestUserList.h"
#import "GCWebUrl.h"

@implementation GCWithingsRequestOnce

+(GCWithingsRequestOnce*)withingsRequestOnce{
    return [[[GCWithingsRequestOnce alloc] init] autorelease];
}
-(void)dealloc{
    [_once release];
    [super dealloc];
}

-(void)saveError:(NSString*)theString{
    NSError * e;
   NSString * fname = @"error_withings_once.json";
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
}

-(NSString*)url{
    return GCWebWithingsOnce();
}
-(NSString*)description{
    return NSLocalizedString(@"Connecting to withings",@"Request Description");
}
-(NSDictionary*)postData{
    return nil;
}
-(NSDictionary*)deleteData{
    return nil;
}
-(NSData*)fileData{
    return nil;
}
-(NSString*)fileName{
    return nil;
}
-(gcWebService)service{
    return gcWebServiceWithings;
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    NSError * err = nil;
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * fn = [NSString stringWithFormat:@"withings_once.json"];
    [theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:encoding error:&e];
#endif
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err ];
    if (json==nil) {
        RZLog(RZLogError, @"json parsing failed %@", err);
        [self saveError:theString];
        _status = GCWebStatusConnectionError;
    }else {
        self.once=json[@"body"][@"once"];
        if (self.once==nil) {
            RZLog(RZLogError, @"WithingsStageOnce missing body:once key");
            [self saveError:theString];
            _status = GCWebStatusParsingFailed;
        }
    }
    [delegate processDone:self];
}
-(id<GCWebRequest>)nextReq{
    return [GCWithingsRequestUserList withingsRequestUserListWith:self.once];
}



@end
