//  MIT License
//
//  Created on 18/11/2018 for FitFileExplorer
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "FITGarminActivityListWrapper.h"
#import "FITGarminActivityWrapper.h"

@interface FITGarminActivityListWrapper ()

@property (nonatomic,retain) NSMutableArray<FITGarminActivityWrapper*>*mlist;
@property (nonatomic,retain) NSMutableDictionary<NSString*,FITGarminActivityWrapper*>*map;
@property (nonatomic,retain) NSString * lastFileName;

@end

@implementation FITGarminActivityListWrapper

-(FITGarminActivityWrapper*)objectAtIndexedSubscript:(NSUInteger)index{
    return self.list[index];
}

-(NSUInteger)count{
    return self.list.count;
}
-(NSArray<FITGarminActivityWrapper*>*)list{
    return self.mlist;
}
-(void)reorder{
    [self.mlist sortUsingComparator:^(FITGarminActivityWrapper * left, FITGarminActivityWrapper * right){
        return [right.time compare:left.time];
    }];
}

-(void)merge:(FITGarminActivityListWrapper*)other{
    if( self.mlist == nil){
        self.mlist = [NSMutableArray array];
        self.map  = [NSMutableDictionary dictionary];
    }

    for (FITGarminActivityWrapper * one in other.list) {
        FITGarminActivityWrapper * found = self.map[one.activityId];
        if( found ){
            [found updateWith:one];
        }else{
            [self.mlist addObject:one];
        }
    }
    
    [self reorder];
}

/**
 Add one activity to the list

 @param one activity
 @return true if new activity, false otherwise
 */
-(BOOL)add:(FITGarminActivityWrapper*)one{
    BOOL rv = false;
    
    if( self.mlist == nil){
        self.mlist = [NSMutableArray array];
        self.map  = [NSMutableDictionary dictionary];
    }

    FITGarminActivityWrapper * found = self.map[one.activityId];
    if( found ){
        [found updateWith:one];
    }else{
        [self.mlist addObject:one];
        self.map[one.activityId] = one;
        rv = true;
    }
    return rv;
}

-(NSUInteger)addJson:(NSArray<NSDictionary*>*)jsonList{
    NSUInteger rv = 0;
    if( [jsonList isKindOfClass:[NSArray class]]){
        
        for (NSDictionary * dict in jsonList) {
            if( [dict isKindOfClass:[NSDictionary class]]){
                FITGarminActivityWrapper * one = [FITGarminActivityWrapper wrapperFor:dict];
                rv += [self add:one] ? 1 : 0;
            }
        }
    }
    [self reorder];
    return rv;
}
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [self.mlist countByEnumeratingWithState:state objects:buffer count:len];
}

-(void)saveAsJson:(NSString*)filename{
    NSMutableArray<NSDictionary*>*obj = [NSMutableArray arrayWithCapacity:self.list.count];
    for (FITGarminActivityWrapper * one in self.list) {
        [obj addObject:one.json];
    }
    NSData * data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingSortedKeys error:nil];
    [data writeToFile:filename atomically:YES];
    self.lastFileName = filename;
}
-(void)loadFromJson:(NSString*)filename{
    if( [self.lastFileName isEqualToString:filename] ){
        // check timestamp/
    }else{
        if( self.mlist){
            [self.mlist removeAllObjects];
            
            [self.map removeAllObjects];
        }

        NSData * data = [NSData dataWithContentsOfFile:filename];
        if( data ){
            NSArray<NSDictionary*>*read = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if( [read isKindOfClass:[NSArray class]]){
                [self addJson:read];
            }
            self.lastFileName = filename;
        }
    }
}
    

-(void)clear{
    [self.mlist removeAllObjects];
}

@end
