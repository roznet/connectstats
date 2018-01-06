//  MIT Licence
//
//  Created on 26/03/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCFieldInfo.h"
#import "GCFieldsDefs.h"

@implementation GCFieldInfo
+(GCFieldInfo*)fieldInfoFor:(NSString*)field type:(NSString*)aType displayName:(NSString*)aDisplayName andUnitName:(NSString*)aUom{
    GCFieldInfo * rv = RZReturnAutorelease([[GCFieldInfo alloc] init]);
    if (rv) {
        rv.displayName = aDisplayName;
        rv.uom = aUom;
        rv.field = field;
        rv.activityType = aType;
    }
    return rv;
}
-(BOOL)match:(NSString*)str{
    if ([self.field isEqualToString:self.activityType] || [self.activityType isEqualToString:GC_TYPE_ALL]) {
        // special case don't match activity types
        return false;
    }
    NSRange res = [self.displayName rangeOfString:str options:NSCaseInsensitiveSearch];
    if (res.location != NSNotFound) {
        return true;
    }
    res = [self.field rangeOfString:str options:NSCaseInsensitiveSearch];
    if (res.location != NSNotFound) {
        return true;
    }
    return false;
}

-(GCUnit*)unit{
    return [GCUnit unitForKey:self.uom];
}
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_displayName release];
    [_uom release];
    [_field release];
    [_activityType release];

    [super dealloc];
}
#endif
-(NSString*)description{
    return [NSString stringWithFormat:@"<GCFieldInfo:%@:%@>",self.field,self.activityType];
}

@end
