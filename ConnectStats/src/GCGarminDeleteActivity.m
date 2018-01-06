//  MIT Licence
//
//  Created on 07/12/2013.
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

#import "GCGarminDeleteActivity.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"

@implementation GCGarminDeleteActivity


+(GCGarminDeleteActivity*)garminDeleteActivity:(NSString *)aId{
    GCGarminDeleteActivity * rv = [[[GCGarminDeleteActivity alloc] init] autorelease];
    if (rv) {
        rv.activityId = aId;
    }
    return rv;
}

-(void)dealloc{
    [_activityId   release];

    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:NSLocalizedString( @"Deleting %@", @"Request Description"), self.activityId];
}

-(NSDictionary*)deleteData{
    NSDictionary * post= @{@"activityId": self.activityId};
    return post;
}

-(NSString*)url{
    return GCWebDeleteActivity(self.activityId);
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSString * fn = @"last_delete.json";
    NSError * e = nil;
    [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
    //[[GCAppGlobal organizer] deleteActivityId:self.activityId];
    [self processDone];
}


@end
