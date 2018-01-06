//  MIT Licence
//
//  Created on 24/10/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCActivitySearch.h"
#import "GCActivity.h"
#import "GCActivitySearchElement.h"

// distance > 10
// distance > 10 km   d>12
// speed > 12
// speed > 12 km/h    s>12
// near me
// tourrette
// jun 2012
// june
// sep
// hr   h<12
// cadence > 10
// c > 2
// near current
// c < current
// duration > 20 min t>20
//

// comp keyword:  distance,d,speed,s,cadence,duration,t
// keyword: cycling,running,bike,biking,swim,swimming,
// keyword: near (me,current),year (number),
// pattern: 4digits->year
// keyword: and,or
// value: number,number unit,
// keyword: this,last (month,week,year)
// keyword: morning,evening,afternoon


@implementation GCActivitySearch
@synthesize searchElements,searchString;

+(GCActivitySearch*)activitySearchWithString:(NSString*)aStr{
    GCActivitySearch * rv = [[[GCActivitySearch alloc] init] autorelease];
    if (rv) {
        rv.searchString = aStr;
        [rv parse];
    }
    return rv;
}

-(void)dealloc{
    [searchElements release];
    [searchString release];
    [super dealloc];
}

-(void)parse{
    [self setSearchElements:nil];
    if (searchString) {
        NSScanner * scanner = [NSScanner scannerWithString:searchString];
        int i = 0;
        self.searchElements = [NSMutableArray arrayWithCapacity:10];
        while (i<100 && ! scanner.atEnd) {
            i++;
            GCActivitySearchElement * element = [GCActivitySearchElement searchElement:scanner];
            if (element) {
                [searchElements addObject:element];
            }
        }
    }
}

-(BOOL)match:(GCActivity*)aAct{
    if (searchElements == nil) {
        return true;
    }
    BOOL rv = true;
    for (GCActivitySearchElement * element in searchElements) {
        rv = rv && [element match:aAct];
    }
    return rv;
}

@end
