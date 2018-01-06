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

#import "TSPlayerManager.h"

@interface TSPlayerManager ()
@property (nonatomic,retain) NSArray * players;
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) NSThread * worker;
@end

NSString * kNotifyPlayerManagerChanged = @"kNotifyPlayerManagerChanged";

@implementation TSPlayerManager

-(TSPlayerManager*)initWithDatabase:(FMDatabase*)db andThread:(NSThread*)thread{
    self = [super init];
    if (self) {
        self.db = db;
        self.worker = thread;
        if (thread) {
            self.players = @[];
            [self performSelector:@selector(loadFromDb:) onThread:self.worker withObject:self.db waitUntilDone:NO];
        }else{
            [self loadFromDb:self.db];
        }

    }
    return self;
}

-(void)syncToDb{
    if (self.worker) {
        [self performSelector:@selector(saveToDb:) onThread:self.worker withObject:self.db waitUntilDone:NO];
    }else{
        [self saveToDb:self.db];
    }
}

-(void)savePlayer:(TSPlayer*)player{
    if (self.worker) {
        [player performSelector:@selector(saveToDb:) onThread:self.worker withObject:self.db waitUntilDone:NO];
    }else{
        [player saveToDb:self.db];
    }
}

-(void)loadFromDb:(FMDatabase*)db{
    FMResultSet * res = [db executeQuery:@"SELECT * FROM players"];
    NSMutableArray * all = [NSMutableArray array];
    while ([res next]) {
        TSPlayer * player = [TSPlayer playerWithResultSet:res];
        [all addObject:player];
    }
    self.players = all;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPlayerManagerChanged object:nil];
}

-(void)saveToDb:(FMDatabase*)db{
    [db beginTransaction];
    for (TSPlayer * player in self.players) {
        [player saveToDb:db];
    }
    [db commit];
}

+(void)ensureDbStructure:(FMDatabase*)db{
    NSInteger version  = 1;

    if (/* DISABLES CODE */ (false)) {//Force rebuild
        [db executeUpdate:@"DROP TABLE players"];
        [db executeUpdate:@"DROP TABLE players_version"];
    }
    if (![db tableExists:@"players"]) {
        RZEXECUTEUPDATE(db, @"CREATE TABLE players (player_id INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT, playerRecordId TEXT)");
    }
    if (![db tableExists:@"players_version"]) {
        RZEXECUTEUPDATE(db, @"CREATE TABLE players_version (version INTEGER)");
        RZEXECUTEUPDATE(db, @"INSERT INTO players_version (version) VALUES (1)");
    }
    version = [db intForQuery:@"SELECT MAX(version) FROM players_version"];
    if (![db columnExists:@"playerRecordId" inTableWithName:@"players"]) {
        [db executeUpdate:@"ALTER TABLE players ADD COLUMN playerRecordId TEXT"];
    }

}
#pragma mark - Access

-(NSUInteger)count{
    return _players.count;
}
-(id)objectAtIndexedSubscript:(NSUInteger)idx{
    return _players[idx];
}
-(TSPlayer*)playerAtIndex:(NSUInteger)idx{
    return _players[idx];
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [_players countByEnumeratingWithState:state objects:buffer count:len];
}

-(NSArray*)playersMatching:(NSString *)match{
    NSMutableArray * rv = [NSMutableArray arrayWithCapacity:_players.count];
    for (TSPlayer * player in _players) {
        if ([player matchesString:match]) {
            [rv addObject:player];
        }
    }
    return rv;
}

-(TSPlayer*)playerForId:(TSPlayerId)playerId{
    if (playerId != kInvalidPlayerId) {
        for (TSPlayer * player in self.players) {
            if (player.playerId == playerId) {
                return player;
            }
        }
    }
    return nil;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %d players>", NSStringFromClass([self class]), (int)self.count];
}

#pragma mark - Register
/**
 @discussion Add player if does not exist yet.
 @param player could be existing, or new one with invalidId
 */
-(void)registerPlayer:(TSPlayer*)player{
    TSPlayer * existing = [self playerForId:player.playerId];
    if (existing ) {
        if (existing != player){
            RZLog(RZLogWarning, @"Unexpected 2 players with same id");
            // Notify something changed, people may need to resync, should not really happen
            [existing updateFromPlayer:player];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyPlayerManagerChanged object:existing];
        }
        [self savePlayer:player];
    }else {
        existing = [self playerEqualsTo:player];
        if (existing) {
            [player updatePlayerId:existing.playerId];
            [self savePlayer:player];
        }else{

            [self savePlayer:player];
            if (player.playerId == kInvalidPlayerId) {
                RZLog( RZLogError, @"Failed to create new playerId");
            }
            self.players = [self.players arrayByAddingObject:player];
        }
    }

}
-(TSPlayer*)playerEqualsTo:(TSPlayer*)other{
    for (TSPlayer * player in self.players) {
        if ([player isEqualToPlayer:other]) {
            return player;
        }
    }
    return nil;
}

-(TSPlayer*)playerFrom:(TSPlayer*)other inManager:(TSPlayerManager*)manager{
    // First see if player has playerRecordID matching then return
    // otherwise keep track if we have match
    TSPlayer * found = nil;

    for (TSPlayer * one in _players) {
        if ([one isSameCloudPlayer:other]) {
            return one;
        }
        if ([one isEqualToPlayer:other]) {
            found = one;
        }
    }
    if (!found) {
        found  = [TSPlayer playerWithPlayer:other];
        self.players = [self.players arrayByAddingObject:found];
        [self savePlayer:found];
    }else{
        if([found noticeChangesFrom:other]){
            [self savePlayer:found];
        }
    }
    return found;
}

#pragma mark - cloudkit

-(TSPlayer*)playerForRecord:(CKRecord*)record{
    TSPlayer * found = nil;
    for (TSPlayer * player in self.players) {
        if ([player.recordID isEqual:record.recordID]) {
            found = player;
            break;
        }
    }
    if (!found) {
        found = [TSPlayer playerWithRecord:record];
        self.players = [self.players arrayByAddingObject:found];
        [self savePlayer:found];

    }
    return found;
}

-(TSPlayer*)noticeCloudRecord:(CKRecord*)record forPlayer:(TSPlayer*)player{
    TSPlayer * rv = player;
    TSPlayer * foundId = [self playerForId:player.playerId];
    TSPlayer * foundCloud = nil;
    for (TSPlayer * one in self.players) {
        if ([one.recordID isEqual:record.recordID]) {
            foundCloud = one;
            break;
        }
    }

    if (foundId && foundCloud==nil) {
        [player noticeCloudRecord:record];
        rv = player;
    }else if (foundId == nil && foundCloud){
        rv = foundCloud;
    }else if (foundCloud==nil && foundId == nil){ // create new
        rv = [TSPlayer playerWithPlayer:player];
        [rv noticeCloudRecord:record];
        [self registerPlayer:rv];
    }else{
        // FIXME: both and they are different. merge

        rv = nil;
    }
    if (rv) {
        [self savePlayer:rv];
    }
    return rv;
}
@end
