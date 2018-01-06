//  MIT Licence
//
//  Created on 25/01/2013.
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

#import "GCGarminRenameActivity.h"
#import "GCWebUrl.h"
#import "GCGarminRequestActivityReload.h"

@implementation GCGarminRenameActivity
@synthesize activityId,activityName;

-(instancetype)init{
    return [super init];
}
-(GCGarminRenameActivity*)initWithId:(NSString*)aId andName:(NSString*)aName{
    self = [super init];
    if (self) {
        self.activityId = aId;
        self.activityName = aName;
    }
    return self;
}

-(void)dealloc{
    [activityId release];
    [activityName release];

    [super dealloc];
}

-(NSString*)description{
    return [NSString stringWithFormat:NSLocalizedString( @"Renaming %@ to %@", @"Request Description"), activityId,activityName];
}

-(NSDictionary*)postJson{
    NSDictionary * post= @{@"activityId": @([activityId integerValue]),
               @"activityName": activityName};
    return post;
}

-(NSString*)url{
    return GCWebRenameActivity(activityId);
}
-(void)process:(NSData *)theData andDelegate:(id<GCWebRequestDelegate>)adelegate{
    self.delegate = adelegate;
    self.encoding = NSUTF8StringEncoding;
    self.theString = RZReturnAutorelease([[NSString alloc] initWithData:theData encoding:self.encoding]);
    [self process];

}
-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSString * fn = @"last_rename.json";
    NSError * e = nil;
    [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
    self.nextReq = [[[GCGarminRequestActivityReload alloc] initWithId:activityId] autorelease];
    [self processDone];
}

@end
