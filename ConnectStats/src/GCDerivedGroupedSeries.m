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

#import "GCDerivedGroupedSeries.h"

@interface GCDerivedGroupedSeries ()
@property (nonnull,retain) NSArray<GCDerivedDataSerie*>*series;
@property (nonnull,retain) GCField * field;

@end
@implementation GCDerivedGroupedSeries

-(void)dealloc{
    [_field release];
    [_series release];
    [super dealloc];
}

+(GCDerivedGroupedSeries*)groupedSeriesStartingWith:(GCDerivedDataSerie*)first{
    GCDerivedGroupedSeries * rv = [[[GCDerivedGroupedSeries alloc] init] autorelease];
    if (rv) {
        rv.series = @[ first];
        rv.field = first.field;
    }
    return rv;
}

-(void)addSerie:(GCDerivedDataSerie*)one{
    if ([one.field isEqual:self.field]) {
        NSMutableArray * next = [NSMutableArray arrayWithArray:self.series];
        [next addObject:one];
        [next sortUsingComparator:^(GCDerivedDataSerie*d1, GCDerivedDataSerie *d2){
            return [d2.bucketStart compare:d1.bucketStart];
        }];
        self.series = [NSArray arrayWithArray:next];
    }
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@>%@", NSStringFromClass([self class]),self.field,self.series];
}

@end
