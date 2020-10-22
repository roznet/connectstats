//  MIT Licence
//
//  Created on 22/03/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "RZFilteredSelectedArray.h"
#import <RZUtils/RZMacros.h>

@interface RZFilteredSelectedArray ()

@property (nonatomic,retain) NSArray * array;
@property (nonatomic,retain) NSMutableIndexSet * selectedIndexes;
@property (nonatomic,retain) NSIndexSet * filteredIndexes;

@property (nonatomic,assign) RZFilteredArrayMatchFunc currentFilter;
@property (nonatomic,retain) NSArray * currentFilteredArray;
@property (nonatomic,retain) NSMutableIndexSet * currentFilteredSelectedIndexes;

@end

@implementation RZFilteredSelectedArray

+(RZFilteredSelectedArray*)array:(NSArray*)array withFilter:(RZFilteredArrayMatchFunc)func{
    RZFilteredSelectedArray * rv = [[RZFilteredSelectedArray alloc] init];
    if (rv) {
        rv.array = array;
        rv.filter = func;
        rv.selectedIndexes = RZReturnAutorelease([[NSMutableIndexSet alloc] init]);
        rv.currentFilteredSelectedIndexes = RZReturnAutorelease([[NSMutableIndexSet alloc] init]);
    }
    return rv;
}

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_array release];
    [_selectedIndexes release];
    [_filteredIndexes release];
    [_currentFilteredArray release];
    [_currentFilteredSelectedIndexes release];

    [super dealloc];
}
#endif

#pragma mark - filter

-(RZFilteredArrayMatchFunc)filter{
    return self.currentFilter;
}

-(void)setFilter:(RZFilteredArrayMatchFunc)filter{
    self.currentFilter = filter;

    if (filter == nil) {
        self.filteredIndexes = RZReturnAutorelease([[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.array.count)]);
        self.currentFilteredSelectedIndexes = RZReturnAutorelease([[NSMutableIndexSet alloc] initWithIndexSet:self.selectionIndexes]);
        self.currentFilteredArray = self.array;
    }else{
        NSMutableIndexSet * set = RZReturnAutorelease([[NSMutableIndexSet alloc] init]);
        self.currentFilteredSelectedIndexes = RZReturnAutorelease([[NSMutableIndexSet alloc] init]);
        NSUInteger idx = 0;
        NSUInteger selectedIdx = 0;
        for (id one in self.array) {
            if (filter(one)) {
                [set addIndex:idx];
                if ([self.selectionIndexes containsIndex:idx]) {
                    [self.currentFilteredSelectedIndexes addIndex:selectedIdx];
                }
                selectedIdx++;
            }
            idx++;
        }
        self.filteredIndexes = set;
        self.currentFilteredArray = [self.array objectsAtIndexes:self.filteredIndexes];
    }
}

-(void)setFilterFromSelection{
    self.currentFilter = nil;
    self.filteredIndexes = self.selectionIndexes;
    self.currentFilteredArray = [self.array objectsAtIndexes:self.selectionIndexes];
    self.currentFilteredSelectedIndexes = RZReturnAutorelease([[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.currentFilteredArray.count)]);

}

-(BOOL)isFilterEqualToSelection{
    return [self.filteredIndexes isEqualToIndexSet:self.selectionIndexes];
}

-(void)clearFilter{
    [self setFilter:nil];
}
#pragma mark - Access

-(NSUInteger)count{
    return self.filteredIndexes.count;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [self.currentFilteredArray countByEnumeratingWithState:state objects:buffer count:len];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx{
    return self.currentFilteredArray[idx];
}

-(NSArray*)filteredArray{
    return self.currentFilteredArray;
}
#pragma mark - Selected

-(NSIndexSet*)selectionIndexes{
    return self.selectedIndexes;
}
-(void)setSelectionIndexes:(NSIndexSet *)selectionIndexes{
    self.selectedIndexes = RZReturnAutorelease([[NSMutableIndexSet alloc] initWithIndexSet:selectionIndexes]);
    // reset filter to force rebuild of filterSelectedIndexes
    [self setFilter:self.filter];
}

-(NSUInteger)originalIndexForFilteredIndex:(NSUInteger)idx{
    NSUInteger rv = 0;
    if (idx < self.filteredIndexes.count) {
        NSUInteger * indexes = malloc(sizeof(NSUInteger)*(idx+1));
        [self.filteredIndexes getIndexes:indexes maxCount:idx+1 inIndexRange:nil];
        rv = indexes[idx];
        free(indexes);
    }
    return rv;
}

-(void)selectionSetIndexSet:(NSIndexSet*)idxset{
    [self.selectedIndexes removeAllIndexes];
    [idxset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * stop){
        NSUInteger origIdx = [self originalIndexForFilteredIndex:idx];
        [self.selectedIndexes addIndex:origIdx];
        [self.currentFilteredSelectedIndexes addIndex:idx];
    }];
}

-(void)selectionAddIndex:(NSUInteger)idx{
    if (![self.currentFilteredSelectedIndexes containsIndex:idx]) {
        NSUInteger origIdx = [self originalIndexForFilteredIndex:idx];
        [self.selectedIndexes addIndex:origIdx];
        [self.currentFilteredSelectedIndexes addIndex:idx];
    }
}

-(void)selectionRemoveIndex:(NSUInteger)idx{
    if ([self.currentFilteredSelectedIndexes containsIndex:idx]) {
        NSUInteger origIdx = [self originalIndexForFilteredIndex:idx];
        [self.selectedIndexes removeIndex:origIdx];
        [self.currentFilteredSelectedIndexes removeIndex:idx];
    }
}

-(NSIndexSet*)filteredSelectionIndexes{
    return self.currentFilteredSelectedIndexes;
}

#pragma mark - Arrays
-(NSArray*)selectedArray{
    return [self.array objectsAtIndexes:self.selectionIndexes];
}
-(NSArray*)filteredSelectedArray{
    return [self.filteredArray objectsAtIndexes:self.filteredSelectionIndexes];
}


@end
