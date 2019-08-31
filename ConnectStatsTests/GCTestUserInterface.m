//  MIT License
//
//  Created on 30/08/2019 for ConnectStatsXCTests
//
//  Copyright (c) 2019 Brice Rosenzweig
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



#import <XCTest/XCTest.h>
#import "GCTestCase.h"
#import "GCViewConfig.h"

@interface GCTestUserInterface : GCTestCase

@end

@implementation GCTestUserInterface

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [super tearDown];
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)buildJson:(NSMutableDictionary*)json
             forObj:(id)defObj
         keyPath:(NSArray<NSObject<NSCopying>*>*)keyPath{
    
    if( [defObj isKindOfClass:[NSDictionary class]]){
        NSDictionary * dictObj = (NSDictionary*)defObj;
        // Special case of color json
        if( [dictObj[@"colors"] isKindOfClass:[NSArray class]] ){
            NSString * jsonKey = [[keyPath arrayByMappingBlock:^(NSObject*elem) {
                return [elem description];
            }] componentsJoinedByString:@"-"];
            json[jsonKey] = dictObj;
        }else{
            for (NSObject<NSCopying>*key in dictObj) {
                id subObj = dictObj[key];
                [self buildJson:json forObj:subObj keyPath:[keyPath arrayByAddingObject:key]];
            }
        }
    }else if ([defObj isKindOfClass:[NSArray class]]){
        NSArray * arrayObj = (NSArray*)defObj;
        NSUInteger i = 0;
        for (id subObj in arrayObj) {
            [self buildJson:json forObj:subObj keyPath:[keyPath arrayByAddingObject:[NSString stringWithFormat:@"[%lu]", i]]];
            i++;
        }
    }else{
        NSString * jsonKey = [[keyPath arrayByMappingBlock:^(NSObject*elem) {
            return [elem description];
        }] componentsJoinedByString:@"-"];
        if( [defObj isKindOfClass:[UIColor class]]){
            json[jsonKey] = @{ @"colors": @[
                                           @{
                                               @"idiom": @"universal",
                                               @"color": [(UIColor*)defObj rgbComponentColorSetJsonFormat]
                                               }
                                           ] };

        }else{
            //json[jsonKey] = defObj;
        }
    }
}

- (void)testSkins {
    // Check that all the name have the same keys
    
    NSUInteger totalKeys = 0;
    NSDictionary * lastDict= nil;
    for (NSString * name in [GCViewConfigSkin availableSkinNames]) {
        GCViewConfigSkin * skin = [GCViewConfigSkin skinForName:name];
        XCTAssertNotNil(skin);
        NSError * error = nil;
        NSMutableDictionary * jsonDict = [NSMutableDictionary dictionary];
        [self buildJson:jsonDict forObj:skin.defs keyPath:@[]];
        XCTAssertNotEqual(jsonDict.count, 0, @"%@ has some keys", name);
        if( totalKeys == 0){
            totalKeys = jsonDict.count;
        }else{
            XCTAssertEqual(jsonDict.count, totalKeys, @"%@ Consistent keys", name);
            if( jsonDict.count != totalKeys ){
                NSDictionary * toCompare = [NSDictionary dictionaryWithObjects:jsonDict.allKeys forKeys:jsonDict.allKeys];
                NSDictionary * diff = lastDict.count > toCompare.count ? [lastDict smartCompareDict:toCompare] :[toCompare smartCompareDict:lastDict];
                RZLog(RZLogError,@"%@ diffs %@", name, diff.allKeys);
            }
        }
        lastDict = [NSDictionary dictionaryWithObjects:jsonDict.allKeys forKeys:jsonDict.allKeys];
        NSData * data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingSortedKeys error:&error];
        if( data ){
            NSString *  jsonFName = [NSString stringWithFormat:@"%@-colorset.json",name];
            [data writeToFile:[RZFileOrganizer writeableFilePath:jsonFName] atomically:YES];
        }

    }
    
    
}


@end
