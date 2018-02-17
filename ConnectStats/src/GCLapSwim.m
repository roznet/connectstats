//  MIT Licence
//
//  Created on 10/10/2016.
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

#import "GCLapSwim.h"

@implementation GCLapSwim

-(GCLapSwim*)initWithResultSet:(FMResultSet*)res{
    self = [super init];
    if (self) {
        self.lapIndex = [res intForColumn:@"lap"];
        self.time = [res dateForColumn:@"Time"];
        self.elapsed = [res doubleForColumn:@"SumDuration"];
        self.directSwimStroke = [res intForColumn:@"DirectSwimStroke"];
        self.values = [NSMutableDictionary dictionaryWithCapacity:10];

    }
    return self;
}

-(void)dealloc{
    [_label release];
    [super dealloc];
}

-(void)saveToDb:(FMDatabase *)trackdb{
    [self saveLapToDb:trackdb index:self.lapIndex];
}

-(void)saveLapToDb:(FMDatabase*)trackdb index:(NSUInteger)idx{
    for (GCField * field in self.values) {
        GCNumberWithUnit * nb = self.values[field];
        [trackdb executeUpdate:@"INSERT INTO gc_pool_lap_info (lap,field,value,uom) VALUES (?,?,?,?)",
         @(idx),field.key,nb.number,(nb.unit).key];
    }
    BOOL distanceGreaterThanZero = (self.distanceMeters>0.);
    [trackdb executeUpdate:@"INSERT INTO gc_pool_lap (lap,Time,SumDuration,DirectSwimStroke,Active) VALUES (?,?,?,?,?)",
     @(idx),
     self.time,
     @(self.elapsed),
     @(self.directSwimStroke),
     @(distanceGreaterThanZero)
     ];
}

@end
