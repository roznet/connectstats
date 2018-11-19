//  MIT License
//
//  Created on 13/11/2018 for FitFileExplorer
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "FITGarminActivityWrapper.h"
#import "GCGarminActivityInterpret.h"
#import "FITAppGlobal.h"
#import "GCActivityTypes.h"

@interface FITGarminActivityWrapper ()
@property (nonatomic,retain) NSDictionary * json;
@property (nonatomic,retain) GCGarminActivityInterpret * interpert;
@end

@implementation FITGarminActivityWrapper

+(FITGarminActivityWrapper*)wrapperFor:(NSDictionary*)json{
    FITGarminActivityWrapper*rv = [[FITGarminActivityWrapper alloc] init];
    
    NSMutableDictionary * pruned = [NSMutableDictionary dictionary];
    for (NSString * key in json) {
        id val = json[key];
        if( ![val isKindOfClass:[NSNull class]]){
            pruned[key] = val;
        }
    }
    rv.json = pruned;
    rv.interpert = [GCGarminActivityInterpret interpret:rv.json usingDTOUnit:false withTypes:[FITAppGlobal activityTypes]];
    //NSLog(@"Added %@: %lu/%lu", rv.activityId, (unsigned long)pruned.count, (unsigned long)json.count);
    
    return rv;
}

-(NSString*)activityId{
    return [self.json[@"activityId"] stringValue] ?: @"";
}
-(void)updateWith:(FITGarminActivityWrapper*)other{
    self.json = other.json;
}
@end
