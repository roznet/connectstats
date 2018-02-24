//  MIT Licence
//
//  Created on 06/08/2013.
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

#import "GCActivity+UI.h"
#import "GCViewIcons.h"

@implementation GCActivity (UI)

-(UIImage*)icon{
    UIImage * rv = nil;
    if (self.activityTypeDetail) {
        rv = [GCViewIcons activityTypeColoredIconFor:self.activityTypeDetail.key];
    }
    if (!rv) {
        rv = [GCViewIcons activityTypeColoredIconFor:self.activityType];
    }

    return rv;
}

-(NSString*)activityTypeKey:(BOOL)primaryOnly{
    if (primaryOnly) {
        if ([self.activityType isEqualToString:GC_TYPE_RUNNING] ||
            [self.activityType isEqualToString:GC_TYPE_CYCLING] ||
            [self.activityType isEqualToString:GC_TYPE_SWIMMING] ||
            [self.activityType isEqualToString:GC_TYPE_DAY]) {
            return self.activityType;
        }
    }else{
        static NSDictionary * cache = nil;
        if (cache==nil) {
            cache = @{GC_TYPE_SWIMMING: @1,
                      GC_TYPE_CYCLING:  @1,
                      GC_TYPE_RUNNING:  @1,
                      GC_TYPE_HIKING:   @1,
                      GC_TYPE_FITNESS:  @1,
                      GC_TYPE_TENNIS:   @1,
                      GC_TYPE_OTHER:    @1,
                      GC_TYPE_SKI_BACK: @1,
                      GC_TYPE_SKI_DOWN: @1


                      };
            [cache retain];
        }

        if (self.activityTypeDetail && cache[self.activityTypeDetail.key]) {
            return self.activityTypeDetail.key;
        }else if(self.activityType && cache[self.activityType]){
            return self.activityType;
        }
    }
    return GC_TYPE_OTHER;
}
@end
