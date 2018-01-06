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
#import <CloudKit/CloudKit.h>

typedef NSInteger TSPlayerId;

extern TSPlayerId kInvalidPlayerId;

@interface TSPlayer : RZParentObject


+(TSPlayer*)playerWithFirstName:(NSString*)first andLastName:(NSString*)last;
+(TSPlayer*)playerWithResultSet:(FMResultSet*)res;
+(TSPlayer*)playerWithRecord:(CKRecord*)record;
+(TSPlayer*)playerWithPlayer:(TSPlayer*)other;

-(void)saveToDb:(FMDatabase*)db;

-(BOOL)matchesString:(NSString*)string;
/// Equality of fields, if equal they should have same playerId
-(BOOL)isEqualToPlayer:(TSPlayer*)other;
-(BOOL)isSameCloudPlayer:(TSPlayer*)other;

-(NSString*)displayName;
-(NSString*)firstName;
-(NSString*)lastName;

-(TSPlayerId)playerId;
/// Will copy all values from player
-(void)updateFromPlayer:(TSPlayer*)player;
-(void)updatePlayerId:(TSPlayerId)pid;

-(void)noticeCloudRecord:(CKRecord*)record;
-(CKRecord*)cloudPlayerRecord;
-(BOOL)existsInCloud;
-(CKRecordID*)recordID;

-(void)updateFirstName:(NSString*)first andLastName:(NSString*)last;
-(BOOL)noticeChangesFrom:(TSPlayer*)other;
@end
