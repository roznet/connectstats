//  MIT Licence
//
//  Created on 01/12/2013.
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

#import "GCGarminChangeActivityType.h"
#import "GCWebUrl.h"
#import "GCGarminRequestActivityReload.h"

@implementation GCGarminChangeActivityType

+(GCGarminChangeActivityType*)garminChangeActivityType:(NSString *)aType forActivityId:(NSString *)aId{
    GCGarminChangeActivityType * rv = [[[GCGarminChangeActivityType alloc] init] autorelease];
    if (rv) {
        rv.activityId = aId;
        rv.activityType = aType;
    }
    return rv;
}

-(void)dealloc{
    [_activityId   release];
    [_activityType release];

    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:NSLocalizedString( @"Changing %@ to %@", @"Request Description"), self.activityId,self.activityType];
}

-(NSDictionary*)postData{
    NSDictionary * post= @{@"activityId": self.activityId,
                          @"value": self.activityType};
    return post;
}

-(NSString*)url{
    return GCWebChangeActivityType(self.activityId);
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSString * fn = @"last_change_type.json";
    NSError * e = nil;
    [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
    self.nextReq = [[[GCGarminRequestActivityReload alloc] initWithId:self.activityId] autorelease];
    [self processDone];
}

@end
