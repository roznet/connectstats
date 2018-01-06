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

#import "TSPlayer.h"
#import "TSCloudTypes.h"

TSPlayerId kInvalidPlayerId = -1;

@interface TSPlayer ()
@property (nonatomic,assign) TSPlayerId playerId;
@property (nonatomic,retain) NSString * cloudPlayerRecordId;
@property (nonatomic,retain) CKRecord * cachedPlayerRecord;

@property (nonatomic,retain) NSString * firstName;
@property (nonatomic,retain) NSString * lastName;

@end

@implementation TSPlayer

#pragma mark - Init and Copy

+(TSPlayer*)playerWithPlayer:(TSPlayer*)other{
    TSPlayer * rv= [[TSPlayer alloc] init];
    if (rv) {
        rv.firstName = other.firstName;
        rv.lastName = other.lastName;
        rv.playerId = kInvalidPlayerId;
        rv.cloudPlayerRecordId = other.cloudPlayerRecordId;
    }
    return rv;

}

+(TSPlayer*)playerWithFirstName:(NSString*)first andLastName:(NSString*)last{
    TSPlayer * rv= [[TSPlayer alloc] init];
    if (rv) {
        rv.firstName = first;
        rv.lastName = last;
        rv.playerId = kInvalidPlayerId;
    }
    return rv;
}

+(TSPlayer*)playerWithResultSet:(FMResultSet*)res{
    TSPlayer * rv= [[TSPlayer alloc] init];
    if (rv) {
        rv.firstName = [res stringForColumn:@"firstName"];
        rv.lastName = [res stringForColumn:@"lastName"];
        rv.playerId = [res intForColumn:@"player_id"];
        //RESET ICLOUD: comment this out
        rv.cloudPlayerRecordId = [res stringForColumn:@"playerRecordId"];
    }
    return rv;
}
+(TSPlayer*)playerWithRecord:(CKRecord*)record{
    TSPlayer * rv = [[TSPlayer alloc] init];
    if (rv) {
        rv.firstName = record[kTSRecordFieldFirstName];
        rv.lastName = record[kTSRecordFieldLastName];
        rv.cloudPlayerRecordId = record.recordID.recordName;
        rv.playerId = kInvalidPlayerId;
    }
    return rv;
}

-(void)updateFromPlayer:(TSPlayer*)player{
    self.playerId = player.playerId;
    self.firstName = player.firstName;
    self.lastName = player.lastName;
}
-(void)updatePlayerId:(TSPlayerId)pid{
    self.playerId = pid;
}
#pragma mark - Database

-(void)saveToDb:(FMDatabase*)db{
    if (self.playerId != kInvalidPlayerId) {
        RZEXECUTEUPDATE(db, @"INSERT OR REPLACE INTO players (player_id,firstName,lastName,playerRecordId) VALUES (?,?,?,?)",
                        @(self.playerId), self.firstName, self.lastName,
                        self.cloudPlayerRecordId ? self.cloudPlayerRecordId : [NSNull null]);
    }else{
        RZEXECUTEUPDATE(db, @"INSERT INTO players (firstName,lastName,playerRecordId) VALUES (?,?,?)",
                         self.firstName, self.lastName,self.cloudPlayerRecordId ? self.cloudPlayerRecordId : [NSNull null]);
        self.playerId = (NSInteger)[db lastInsertRowId];
    }
}

#pragma mark - Search and display

-(BOOL)matchesString:(NSString*)string{
    NSArray * sub = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", ;"]];
    for (NSString * str in sub) {
        if ([self.firstName rangeOfString:str].location != NSNotFound || [self.lastName rangeOfString:str].location != NSNotFound){
            return true;
        }
    }
    return  false;
}

-(BOOL)isEqualToPlayer:(TSPlayer*)other{
    return [[self.firstName lowercaseString] isEqualToString:[other.firstName lowercaseString]] &&
        [[self.lastName lowercaseString] isEqualToString:[other.lastName lowercaseString]];
}

-(NSString*)displayName{
    NSMutableArray * elem = [NSMutableArray array];
    if (self.firstName ) {
        [elem addObject:self.firstName];
    }
    if (self.lastName) {
        [elem addObject:self.lastName];
    }
    if (elem.count) {
        return [elem componentsJoinedByString:@" "];
    }else{
        return @"";
    }
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@[%d]: %@ %@>", NSStringFromClass([self class]), (int)self.playerId, self.firstName, self.lastName];
}

#pragma mark - CloudKit

+(TSPlayer*)playerFromCloudRecord:(CKRecord*)rec{
    TSPlayer * rv = [[TSPlayer alloc] init];
    if (rv) {
        rv.lastName = rec[kTSRecordFieldLastName];
        rv.firstName = rec[kTSRecordFieldFirstName];
        rv.cloudPlayerRecordId = rec.recordID.recordName;
    }
    return rv;
}

-(CKRecord*)cloudPlayerRecord{
    if (!self.cachedPlayerRecord) {
        CKRecord * db = [[CKRecord alloc] initWithRecordType:kTSRecordTypePlayer];
        db[kTSRecordFieldFirstName] =self.firstName;
        db[kTSRecordFieldLastName] = self.lastName;
        self.cachedPlayerRecord = db;
    }
    return self.cachedPlayerRecord;
}

-(void)noticeCloudRecord:(CKRecord *)record{
    if ([record.recordType isEqualToString:kTSRecordTypePlayer]) {
        if (!self.cloudPlayerRecordId || ! [self.cloudPlayerRecordId isEqualToString:record.recordID.recordName] ) {
            self.cloudPlayerRecordId = record.recordID.recordName;
            if(self.cachedPlayerRecord ==nil){
                self.cachedPlayerRecord = record;
            }
            [self notify];
        }
    }
}

-(BOOL)isSynchedFromCloudRecord:(CKRecord*)record{
    return [record.recordID.recordName isEqualToString:self.cloudPlayerRecordId];
}

-(BOOL)existsInCloud{
    return self.cloudPlayerRecordId != nil;
}
-(BOOL)isSameCloudPlayer:(TSPlayer*)other{
    return self.cloudPlayerRecordId != nil && other.cloudPlayerRecordId != nil && [self.cloudPlayerRecordId isEqualToString:other.cloudPlayerRecordId];
}

-(CKRecordID*)recordID{
    if (self.cloudPlayerRecordId) {
        return [[CKRecordID alloc] initWithRecordName:self.cloudPlayerRecordId];
    }
    return nil;
}
-(void)updateFirstName:(NSString*)first andLastName:(NSString*)last{
    self.firstName = first;
    self.lastName = last;
    [self notify];
}

-(BOOL)noticeChangesFrom:(TSPlayer*)other{
    if (self.cloudPlayerRecordId ==nil && other.cloudPlayerRecordId) {
        self.cloudPlayerRecordId = other.cloudPlayerRecordId;
        [self notify];
        return true;
    }
    return false;
}
@end
