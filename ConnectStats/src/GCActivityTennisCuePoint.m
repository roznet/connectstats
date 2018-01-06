//  MIT Licence
//
//  Created on 14/02/2014.
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

#import "GCActivityTennisCuePoint.h"

#define CUEPOINT_FIELDS @[@"time",@"totalStrokes",@"averagePower",@"energy",@"regularity"]


@implementation GCActivityTennisCuePoint

-(GCActivityTennisCuePoint*)init{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)saveToDb:(FMDatabase*)db forSessionId:(NSString*)session_id index:(NSUInteger)idx{
    [db executeUpdate:@"INSERT INTO babolat_cuepoints (session_id,cuepoint_id,time,totalStrokes,averagePower,energy,regularity) VALUES(?,?,?,?,?,?,?)",
     session_id,@(idx),@(self.time),@(self.totalStrokes),@(self.averagePower),@(self.energy),@(self.regularity)];
}

+(GCActivityTennisCuePoint*)cuePointFromResultSet:(FMResultSet*)res{
    GCActivityTennisCuePoint * rv = [[[GCActivityTennisCuePoint alloc] init] autorelease];
    if (rv) {
        rv.time = [res doubleForColumn:@"time"];
        rv.totalStrokes = [res doubleForColumn:@"totalStrokes"];
        rv.averagePower = [res doubleForColumn:@"averagePower"];
        rv.energy = [res doubleForColumn:@"energy"];
        rv.regularity = [res doubleForColumn:@"regularity"];
    }
    return rv;
}


+(GCActivityTennisCuePoint*)cuePointFromData:(NSDictionary*)data{
    GCActivityTennisCuePoint * rv = [[[GCActivityTennisCuePoint alloc] init] autorelease];
    if (rv) {
        rv.time = [data[@"time"] doubleValue];
        rv.totalStrokes = [data[@"totalStrokes"] doubleValue];
        rv.averagePower = [data[@"averagePower"] doubleValue];
        rv.energy = [data[@"energy"] doubleValue];
        rv.regularity = [data[@"regularity"] doubleValue];
    }
    return rv;
}
-(double)valueForField:(NSString*)field{
    if([field hasPrefix:@"a"]){
        return self.averagePower;
    }else if([field hasPrefix:@"e"]){
        return self.energy;
    }else if([field hasPrefix:@"r"]){
        return self.regularity;
    }else if ([field hasPrefix:@"ti"]) {
        return self.time;
    }else {
        return self.totalStrokes;
    }

}
@end
