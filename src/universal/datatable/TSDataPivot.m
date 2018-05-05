//  MIT Licence
//
//  Created on 23/10/2014.
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

#import "TSDataPivot.h"
#import "TSDataCell.h"
#import "TSDataRow.h"

@interface TSDataPivotFieldValues : NSObject
@property (nonatomic,retain) NSString *field;
@property (nonatomic,retain) NSMutableDictionary * values;
@end

@implementation TSDataPivotFieldValues

+(NSArray*)valuesForFields:(NSArray*)fields{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:fields.count];
    if (rv) {
        for (NSString * field in fields) {
            [rv addObject:[TSDataPivotFieldValues valuesForField:field]];
        }
    }
    return rv;
}

+(TSDataPivotFieldValues*)valuesForField:(NSString*)field{
    TSDataPivotFieldValues * rv = [[TSDataPivotFieldValues alloc] init];
    if (rv) {
        rv.field = field;
    }
    return rv;
}

-(void)addValueFromRow:(TSDataRow*)row{
    if (_values == nil) {
        self.values = [ NSMutableDictionary dictionary];
    }
    id value = [row valueForField:_field];
    if (value) {
        if (!_values[value]) {
            _values[value] = @(self.values.count);
        }
    }
}

-(NSArray*)allValuesInNaturalOrder{
    return [_values.allKeys sortedArrayUsingComparator:^(NSString * k1, NSString * k2){
        return [self.values[k1] compare:self.values[k2]];
    }];
}
-(NSComparisonResult)compare:(id)v1 to:(id)v2{
    return [_values[v1] compare:_values[v2]];
}

@end

@interface TSDataPivot ()
@property (nonatomic,retain) NSMutableDictionary * collectedCells;
@property (nonatomic,retain) NSMutableDictionary * collectedColKeys;
@property (nonatomic,retain) NSArray * collectedRowValues;
@property (nonatomic,retain) NSArray * collectedColValues;

-(void)process;

@end

@implementation TSDataPivot

+(TSDataPivot*)pivot:(TSDataTable*)table rows:(NSArray*)rows columns:(NSArray*)cols collect:(NSArray*)col{
    TSDataPivot * rv = [[TSDataPivot alloc] init];
    if (rv) {
        rv.table = table;
        rv.rows  = rows;
        rv.columns = cols;
        rv.collect = col;
        [rv process];
    }
    return rv;
}

-(NSArray*)collectedCellsFor:(TSDataRow*)row{
    if (!_collectedCells) {
        self.collectedCells = [NSMutableDictionary dictionary];
        self.collectedColValues = [TSDataPivotFieldValues valuesForFields:self.columns];
        self.collectedRowValues = [TSDataPivotFieldValues valuesForFields:self.rows];
        self.collectedColKeys = [NSMutableDictionary dictionary];
    }
    NSArray * rowValues = [row valuesForFields:_rows];
    NSArray * colValues = [row valuesForFields:_columns];

    NSMutableDictionary * existingsForRow = _collectedCells[ rowValues];
    if (existingsForRow == nil) {
        [_collectedRowValues makeObjectsPerformSelector:@selector(addValueFromRow:) withObject:row];
        [_collectedColValues makeObjectsPerformSelector:@selector(addValueFromRow:) withObject:row];
        existingsForRow = [NSMutableDictionary dictionary];
        _collectedCells[rowValues] = existingsForRow;
    }
    NSArray * existings = existingsForRow[colValues];
    _collectedColKeys[colValues] = @(_collectedColKeys.count);
    if (existings == nil) {
        [_collectedColValues makeObjectsPerformSelector:@selector(addValueFromRow:) withObject:row];
        existings = [TSDataCell cellForFields:_collect];
        existingsForRow[colValues] = existings;
    }

    return existings;
}

-(void)process{
    for (TSDataRow * row in self.table) {
        NSArray * collected = [self collectedCellsFor:row];
        [collected makeObjectsPerformSelector:@selector(collect:) withObject:row];
    }
}

-(NSArray*)rowsValues{
    return [self.collectedCells.allKeys sortedArrayUsingComparator:^(NSArray * v1, NSArray * v2){
        __block NSComparisonResult rv = NSOrderedSame;
        [v1 enumerateObjectsUsingBlock:^(id o1, NSUInteger idx, BOOL * stop){
            TSDataPivotFieldValues * fv = self.collectedRowValues[idx];
            id o2 = v2[idx];
            NSComparisonResult one = [fv compare:o1 to:o2];
            if (one != NSOrderedSame) {
                rv = one;
                *stop = true;
            }
        }];
        return rv;
    }];
}

-(NSArray*)columnsValues{
    return [self.collectedColKeys.allKeys sortedArrayUsingComparator:^(NSArray * v1, NSArray * v2){
        __block NSComparisonResult rv = NSOrderedSame;
        [v1 enumerateObjectsUsingBlock:^(id o1, NSUInteger idx, BOOL * stop){
            TSDataPivotFieldValues * fv = self.collectedColValues[idx];
            id o2 = v2[idx];
            NSComparisonResult one = [fv compare:o1 to:o2];
            if (one != NSOrderedSame) {
                rv = one;
                *stop = true;
            }
        }];
        return rv;
    }];
}
-(NSArray*)cellForRowValue:(NSArray*)row andColValues:(NSArray*)col{
    return _collectedCells[row][col];
}

-(NSArray*)asGrid{
    NSArray * rows = [self rowsValues];
    NSArray * cols = [self columnsValues];

    NSUInteger nr = _rows.count;
    NSUInteger nc = _columns.count;
    NSUInteger nd = _collect.count;
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:(rows.count*nd)+nc];
    id last = nil;
    for (NSUInteger c = 0; c<nc; c++) {
        NSMutableArray * line = [NSMutableArray arrayWithCapacity:nr+cols.count];
        for (NSUInteger r=0; r<nr; r++) {
            [line addObject:[NSNull null]];
        }
        for (NSArray * col in cols) {
            id one = col[c];
            if (last == nil || [last compare:one]!=NSOrderedSame) {
                [line addObject:one];
            }else{
                [line addObject:[NSNull null]];
            }
            last = one;
        }
        [rv addObject:line];
    }
    NSMutableArray * lastLine = nil;
    for (NSArray * row in rows) {
        NSMutableArray * line = [NSMutableArray arrayWithCapacity:nr];
        NSMutableArray * lastCompare = [NSMutableArray arrayWithCapacity:nr];
        for (NSUInteger r=0; r<nr; r++) {
            [lastCompare addObject:row[r]];
            if (lastLine==nil || [lastLine[r] compare:row[r]] != NSOrderedSame) {
                [line addObject:row[r]];
            }else{
                [line addObject:[NSNull null]];
            }
        }
        lastLine = lastCompare;
        for(NSUInteger d=0;d<nd;d++){
            NSMutableArray * values = [NSMutableArray arrayWithCapacity:cols.count];
            for (NSArray * col in cols) {
                NSArray * cells = [self cellForRowValue:row andColValues:col];
                if (cells) {
                    [values addObject:[cells[d] cellValue:tsPivotSumOrCount]];
                }else{
                    [values addObject:[NSNull null]];
                }
            }
            [rv addObject:[line arrayByAddingObjectsFromArray:values]];
        }
    }
    return rv;
}

-(TSDataTable*)asTable:(tsPivotCellType)type{
    NSArray * rows = [self rowsValues];
    NSArray * cols = [self columnsValues];

    NSArray * allCols = [self.rows arrayByAddingObjectsFromArray:cols];

    TSDataTable * rv = [TSDataTable tableWithColumnNames:allCols];

    for (NSArray * row in rows) {
        NSMutableArray * rowValues = [NSMutableArray arrayWithArray:row];
        for (NSArray * col in cols) {
            NSArray * cells = [self cellForRowValue:row andColValues:col];
            if (cells == nil) {
                [rowValues addObject:[NSNull null]];
            }else if (cells.count == 1) {
                [rowValues addObject:[cells[0] cellValue:type]];
            }else{
                [rowValues addObject:cells];
            }
        }
        [rv addRow:rowValues];
    }

    return rv;
}



@end
