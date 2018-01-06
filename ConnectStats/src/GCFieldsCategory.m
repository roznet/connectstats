//  MIT Licence
//
//  Created on 06/04/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "GCFieldsCategory.h"

@implementation GCFieldsCategory
+(void)buildCache{

}
+(void)forceRebuildCache{

}

+(NSString*)displayNameForCategory:(NSString*)cat{
    static NSMutableDictionary * cache = nil;
    if (cache==nil) {
        FMDatabase * fdb = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
        [fdb open];

        cache = [NSMutableDictionary dictionary];
        FMResultSet * res = [fdb executeQuery:@"SELECT * FROM category_order"];
        while ([res next]) {
            NSString * category = [res stringForColumn:@"category"];
            NSString * display = [res stringForColumn:@"displayName"];

            cache[category] = display;
        }

        [fdb close];
        RZRetain(cache);

    }
    NSString * rv = cache[cat];
    if (!rv) {
        rv=cat;
    }
    return rv;
}

+(NSDictionary*)categoryOrder{
    static NSMutableDictionary * rv = nil;
    if (!rv) {
        FMDatabase * fdb = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
        [fdb open];

        rv = [NSMutableDictionary dictionary];
        FMResultSet * res = [fdb executeQuery:@"SELECT * FROM category_order"];
        while ([res next]) {
            NSString * category = [res stringForColumn:@"category"];
            int order = [res intForColumn:@"display_order"];

            if (order <= 0) {
                category = GC_CATEGORY_IGNORE;
            }
            rv[category] = @(order);
        }

        [fdb close];
        RZRetain(rv);
    }
    return rv;
}

@end
