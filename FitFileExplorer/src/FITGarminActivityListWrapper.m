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

@property (nonatomic,retain) NSMutableArray<FITGarminActivityWrapper*>*list;
@property (nonatomic,retain) NSMutableDictionary<NSString*,FITGarminActivityWrapper*>*map;

@end

@implementation FITGarminActivityListWrapper

-(FITGarminActivityWrapper*)objectAtIndex:(NSUInteger)index{
    return self.list[index];
}

-(NSUInteger)count{
    return self.list.count;
}

-(void)merge:(FITGarminActivityListWrapper*)other{
    if( self.list == nil){
        self.list = [NSMutableArray array];
        self.map  = [NSMutableDictionary dictionary];
    }

    for (FITGarminActivityWrapper * one in other.list) {
        FITGarminActivityWrapper * found = self.map[one.activityId];
        if( found ){
            [found updateWith:one];
        }else{
            [self.list addObject:one];
        }
    }
}
-(void)add:(FITGarminActivityWrapper*)one{
    if( self.list == nil){
        self.list = [NSMutableArray array];
        self.map  = [NSMutableDictionary dictionary];
    }

    FITGarminActivityWrapper * found = self.map[one.activityId];
    if( found ){
        [found updateWith:one];
    }else{
        [self.list addObject:one];
        self.map[one.activityId] = one;
    }
}

-(void)addJson:(NSArray<NSDictionary*>*)jsonList{
    if( [jsonList isKindOfClass:[NSArray class]]){
        
        for (NSDictionary * dict in jsonList) {
            if( [dict isKindOfClass:[NSDictionary class]]){
                FITGarminActivityWrapper * one = [FITGarminActivityWrapper wrapperFor:dict];
                [self add:one];
            }
        }
    }
}
@end
