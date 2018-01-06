//  MIT Licence
//
//  Created on 21/12/2014.
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
#import "TSPlayer.h"

extern NSString * kNotifyPlayerManagerChanged;

@interface TSPlayerManager : NSObject<NSFastEnumeration>

-(TSPlayerManager*)initWithDatabase:(FMDatabase*)db andThread:(NSThread*)thread;

+(void)ensureDbStructure:(FMDatabase*)db;
-(void)syncToDb;

-(NSArray*)playersMatching:(NSString*)match;

-(NSUInteger)count;
-(TSPlayer*)objectAtIndexedSubscript:(NSUInteger)idx;

-(TSPlayer*)playerAtIndex:(NSUInteger)idx;

-(TSPlayer*)playerFrom:(TSPlayer*)other inManager:(TSPlayerManager*)manager;

/// Return player with given playerId or new one if no such playerId or if invalid
-(TSPlayer*)playerForId:(TSPlayerId)playerId;
/// Return player with save values and that should have same playerId
-(TSPlayer*)playerEqualsTo:(TSPlayer*)other;

-(void)registerPlayer:(TSPlayer*)player;
-(TSPlayer*)playerForRecord:(CKRecord*)record;

-(TSPlayer*)noticeCloudRecord:(CKRecord*)record forPlayer:(TSPlayer*)player;
@end
