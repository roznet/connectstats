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

#import <Foundation/Foundation.h>


typedef NSArray<NSNumber*>*(^RZTableIndexRemapRowsFunc)(void);

@interface RZTableIndexRemap : NSObject

+(RZTableIndexRemap*)tableIndexRemap;

-(void)addSection:(NSUInteger)section withRows:( NSArray<NSNumber*>*)rows;
-(void)addSection:(NSUInteger)section withRowsFunc:( RZTableIndexRemapRowsFunc)func;

/**
 Remap an indexPath in the display table into the indexPath in the logical table
 */
-( NSIndexPath*)remap:( NSIndexPath*)indexPath;

/**
 Remap an indexPath in the logical Table into the indexPath in the display table
 */
-(NSIndexPath*)inverseMap:(NSIndexPath*)indexPath;

-(NSUInteger)numberOfSections;
-(NSUInteger)numberOfRowsInSection:(NSUInteger)section;
-(NSUInteger)sectionForIndexPath:(NSIndexPath*)indexPath;
-(NSUInteger)section:(NSUInteger)section;
-(NSUInteger)row:(NSIndexPath*)indexPath;

-(void)reloadData;

+(NSArray<NSNumber*>*)rowsWithNumbersFrom:(NSUInteger)from to:(NSUInteger)to;


@end
