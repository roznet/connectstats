//  MIT Licence
//
//  Created on 13/09/2014.
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

#import "RZTableIndexRemap.h"
#import <RZUtils/RZMacros.h>
// For indexRemap
#if TARGET_OS_IPHONE
@import UIKit;
#endif

@interface RZTableIndexRemapInfo : NSObject
@property (nonatomic,retain) NSArray<NSNumber*> * rows;
@property (nonatomic,assign) NSUInteger section;
@property (nonatomic,copy) RZTableIndexRemapRowsFunc func;

@end

@implementation RZTableIndexRemapInfo

-(void)dealloc{
    RZRelease(_func);
    RZRelease(_rows);
    RZSuperDealloc;
}

@end

@interface RZTableIndexRemap ()
@property (nonatomic,retain) NSMutableArray * remap;
@end

@implementation RZTableIndexRemap

+(RZTableIndexRemap*)tableIndexRemap{
    RZTableIndexRemap * rv = RZReturnAutorelease([[RZTableIndexRemap alloc] init]);
    if (rv) {
        rv.remap = [NSMutableArray arrayWithCapacity:10];
    }
    return rv;
}
-(void)dealloc{
    RZRelease(_remap);
    RZSuperDealloc;
}
-(void)addSection:(NSUInteger)section withRowsFunc:(RZTableIndexRemapRowsFunc)func{
    RZTableIndexRemapInfo * info = [[RZTableIndexRemapInfo alloc] init];
    info.func = func;
    info.rows = func();
    info.section = section;
    [self.remap addObject:info];
    RZRelease(info);

}
-(void)addSection:(NSUInteger)section withRows:(NSArray *)rows{
    RZTableIndexRemapInfo * info = [[RZTableIndexRemapInfo alloc] init];
    info.rows = rows;
    info.section = section;
    [self.remap addObject:info];
    RZRelease(info);
}
-(void)reloadData{
    for (RZTableIndexRemapInfo * info in self.remap) {
        if (info.func) {
            info.rows = info.func();
        }
    }
}
-(RZTableIndexRemapInfo*)infoForSection:(NSUInteger)section{
    RZTableIndexRemapInfo * rv= nil;
    if (section < self.remap.count) {
        rv = self.remap[section];
    }
    return rv;
}
#if TARGET_OS_IPHONE
-(NSIndexPath*)remap:(NSIndexPath*)indexPath{
    RZTableIndexRemapInfo * info = [self infoForSection:indexPath.section];
    NSNumber * row = info.rows[indexPath.row];

    return [NSIndexPath indexPathForRow:row.integerValue inSection:info.section];
}
-(NSIndexPath*)inverseMap:(NSIndexPath*)indexPath{
    RZTableIndexRemapInfo * info = nil;
    NSUInteger sectionIndex = 0;
    for (RZTableIndexRemapInfo * one in self.remap) {
        if (one.section == indexPath.section) {
            info = one;
            break;
        }
        sectionIndex++;
    }

    if (info) {
        NSUInteger rowIndex=0;
        for (NSNumber * row in info.rows) {
            if (row.integerValue == indexPath.row) {
                return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            }
            rowIndex ++;
        }
    }
    return nil;
}
#endif
-(NSUInteger)numberOfSections{
    return self.remap.count;
}
-(NSUInteger)numberOfRowsInSection:(NSUInteger)section{
    return [self infoForSection:section].rows.count;
}
-(NSUInteger)sectionForIndexPath:(NSIndexPath*)indexPath{
    return [self infoForSection:indexPath.section].section;
}
-(NSUInteger)section:(NSUInteger)section{
    return [self infoForSection:section].section;
}
-(NSUInteger)row:(NSIndexPath*)indexPath{
    RZTableIndexRemapInfo * info = [self infoForSection:indexPath.section];
    NSNumber * row = info.rows[indexPath.row];
    return row.integerValue;
}
+(NSArray<NSNumber*>*)rowsWithNumbersFrom:(NSUInteger)from to:(NSUInteger)to{
    if (to <= from) {
        return @[];
    }
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:(to-from)];
    for (NSUInteger i=from; i<to; i++) {
        [rv addObject:@(i)];
    }
    return rv;
}
@end
