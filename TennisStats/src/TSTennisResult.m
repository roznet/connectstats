//  MIT Licence
//
//  Created on 06/12/2014.
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

#import "TSTennisResult.h"


// set: games-games (tie breakpoints)
// set:


@implementation TSTennisResult

+(TSTennisResult*)emptyResult{
    TSTennisResult * rv = [[TSTennisResult alloc] init];
    if (rv) {
        rv.sets = @[ [[TSTennisResultSet alloc] init] ];
    }
    return rv;
}
+(TSTennisResult*)resultForSets:(NSArray*)sets{
    TSTennisResult * rv = [[TSTennisResult alloc] init];
    if (rv) {
        rv.sets = sets;
    }
    return rv;
}

-(TSTennisResultSet*)lastSet{
    return [self.sets lastObject];
}
-(void)nextSet{
    if (self.winner == tsContestantUnknown){
        self.sets = [self.sets arrayByAddingObject:[[TSTennisResultSet alloc] init]];
    }
}
-(NSString*)asString{
    NSMutableArray * rv = [NSMutableArray array];
    if (rv) {
        for (TSTennisResultSet * set in self.sets) {
            [rv addObject:[set asString]];
        }
    }
    return [rv componentsJoinedByString:@", "];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), self.asString];
}

-(NSArray*)pack{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:self.sets.count+1];
    [rv addObject:@(self.winner)];
    for (TSTennisResultSet * set in self.sets) {
        [rv addObject:@( set.pack)];
    }
    return rv;
}
-(TSTennisResult*)unpack:(NSArray*)packed{

    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:packed.count];
    BOOL first = true;
    for (NSNumber * one in packed) {
        if ([one isKindOfClass:[NSNumber class]]) {
            if (first) {
                self.winner = [one intValue];
                first = false;
            }else{
                TSResultPacked res = [one intValue];
                TSTennisResultSet * set = [[[TSTennisResultSet alloc] init] unpack:res];
                [rv addObject:set];
            }
        }
    }
    self.sets = rv;

    return self;
}

@end
