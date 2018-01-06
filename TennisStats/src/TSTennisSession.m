//  MIT Licence
//
//  Created on 12/10/2014.
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

#import "TSTennisSession.h"
#import "TSTennisEvent.h"
#import "TSTennisSessionState.h"
#import "TSCloudTypes.h"
#import "TSPlayerManager.h"
#import "TSAppGlobal.h"

static NSString * session_file_prefix = @"session";

NSString * kNotifySessionNewEvent = @"kNotifySessionNewEvent";
NSString * kNotifySessionDataChanged = @"kNotifySessionDataChanged";

@interface TSTennisSession ()
@property (nonatomic,retain) NSString * eventDbName;
@property (nonatomic,retain) FMDatabase * cachedEventdb;
@property (nonatomic,retain) NSMutableArray * events;
@property (nonatomic,assign) NSUInteger lastEventIdx;
@property (nonatomic,retain) TSTennisSessionState * cachedState;
@property (nonatomic,assign) NSInteger lastSyncEventCount;

@property (nonatomic,assign) NSUInteger replayToEventIdx;

@property (nonatomic,retain) NSThread * worker;

@property (nonatomic,assign) tsCourtLocation courtLocation;
@property (nonatomic,assign) tsCourtType courtType;

@property (nonatomic,retain) TSTennisScoreRule * scoreRule;
@property (nonatomic,retain) TSTennisResult * savedResult;

@property (nonatomic,retain) NSString * cloudSessionRecordId;
@property (nonatomic,retain) NSString * cloudEventsRecordId;

@property (nonatomic,retain) CKRecord * cachedCloudSessionRecord;
@property (nonatomic,retain) CKRecord * cachedCloudEventsRecord;

@property (nonatomic,retain) TSPlayer * player;
@property (nonatomic,retain) TSPlayer * opponent;

@property (nonatomic,assign) tsContestant contestantWinner;

@property (nonatomic,assign) BOOL enableLogging;
@property (nonatomic,assign) BOOL resultWasEdited;

@end

@implementation TSTennisSession

+(TSTennisSession*)sessionWithSummaryFromResultSet:(FMResultSet*)res andThread:(NSThread*)thread{
    TSTennisSession * rv = [[TSTennisSession alloc] init];
    if (rv) {
        rv.sessionId = [res stringForColumn:@"session_id"];
        rv.startTime = [res dateForColumn:@"startTime"];
        rv.duration  = [res doubleForColumn:@"duration"];
        rv.eventDbName = [res stringForColumn:@"file"];
        rv.lastSyncEventCount = [res intForColumn:@"numberOfEvents"];
        //RESET ICLOUD: comment this out
        rv.cloudSessionRecordId = [res stringForColumn:@"sessionRecordId"];
        // For now, later we'll save it in resultset too
        rv.isReadOnly = ![rv.startTime isSameCalendarDay:[NSDate date] calendar:[NSCalendar currentCalendar]];
        rv.worker = thread;
        rv.replayToEventIdx = NSUIntegerMax;
    }
    return rv;
}
+(TSTennisSession*)sessionWithId:(NSString*)sessionid forRule:(TSTennisScoreRule*)rule andThread:(NSThread*)thread{
    TSTennisSession * rv = [[TSTennisSession alloc] init];
    if (rv) {
        rv.sessionId = sessionid;
        rv.eventDbName = [NSString stringWithFormat:@"%@_%@.db", session_file_prefix, rv.sessionId];
        rv.scoreRule = rule;
        rv.startTime = [NSDate date];
        rv.worker = thread;
        rv.replayToEventIdx = NSUIntegerMax;
        [rv startSession];
    }
    return rv;
}

+(TSTennisSession*)sessionFromEventDb:(FMDatabase*)db players:(TSPlayerManager*)players andThread:(NSThread *)thread{
    TSTennisSession * rv = nil;

    if ([db tableExists:@"events"]) {
        if ([db tableExists:@"tennis_sessions"]) {
            FMResultSet * res = [db executeQuery:@"SELECT * FROM tennis_sessions"];
            if ([res next]) {
                rv = [TSTennisSession sessionWithSummaryFromResultSet:res andThread:thread];
                if (rv.sessionId) {
                    if (players) {
                        TSPlayerManager * local = [[TSPlayerManager alloc] initWithDatabase:db andThread:nil];

                        FMResultSet * res = [db executeQuery:@"SELECT * FROM tennis_sessions_summary WHERE session_id=?", rv.sessionId];
                        if ([res next]) {
                            [rv updateWithSummaryResultSet:res andPlayers:local];
                        }
                        rv.player   = [players playerFrom:rv.player inManager:local];
                        rv.opponent = [players playerFrom:rv.opponent inManager:local];
                    }
                }
                // Make consistent with actual file
                rv.eventDbName = [db.databasePath lastPathComponent];

            }
        }
        if (!rv) {
            // For old formats
            rv = [[TSTennisSession alloc] init];
            rv.worker = thread;
            [rv setupFromEventsOnly:db];
        }
        if (rv) {
            rv.replayToEventIdx = NSUIntegerMax;
            rv.cachedEventdb = db;
            [rv loadSessionFromEventDb];
        }
        // Need to update result at the end, but need to make sure when replaying existing, it does
        // not override savedResults
    }
    return rv;
}


+(void)setSessionFilePrefix:(NSString*)prefix{
    session_file_prefix = prefix;
}
+(NSString*)sessionFilePrefix{
    return session_file_prefix;
}

-(void)dealloc{
    [self.player detach:self];
    [self.opponent detach:self];
}

-(void)setupFromEventsOnly:(FMDatabase*)db{
    NSUInteger count = 0;
    NSDate * start = nil;
    NSDate * end = nil;
    FMResultSet * res = [db executeQuery:@"SELECT MIN(time),MAX(time),COUNT(time) FROM events"];
    if ([res next]) {
        count  = [res intForColumn:@"COUNT(time)"];
        if (count>0) {
            start = [res dateForColumn:@"MIN(time)"];
            end   = [res dateForColumn:@"MAX(time)"];
        }
    }
    if (count > 0) {
        self.startTime = start;
        self.duration = [end timeIntervalSinceDate:start];
        self.eventDbName = [db.databasePath lastPathComponent];
        self.sessionId = [start YYYYMMDDhhmmssGMT];
        self.scoreRule = [TSTennisScoreRule ruleFromDb:db];
        self.lastSyncEventCount = 0;
    }
}

-(FMDatabase*)eventdb{
    if (!self.cachedEventdb) {
        if (self.eventDbName) {
            self.cachedEventdb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:self.eventDbName]];
            [self.cachedEventdb open];
            [TSTennisEvent ensureDbStructure:self.cachedEventdb];
            [TSPlayerManager ensureDbStructure:self.cachedEventdb];
            [TSTennisSession ensureDbStructure:self.cachedEventdb];
        }
    }
    return self.cachedEventdb;
}

-(TSTennisSessionState*)state{
    if (!self.cachedState) {
        [self loadSessionFromEventDb];
    }
    return self.cachedState;
}


-(TSTennisSession*)loadSessionFromEventDb{
    self.events = [NSMutableArray array];
    self.cachedState = [TSTennisSessionState loadSessionStateFromDb:[self eventdb] session:self];
    if (self.worker) {
        [self performSelector:@selector(loadEventsFromDb) onThread:self.worker withObject:nil waitUntilDone:NO];
    }else{
        [self loadEventsFromDb];
    }
    return self;
}
-(TSTennisSession*)startSession{
    self.events = [NSMutableArray array];
    [self eventdb];
    self.cachedState = [TSTennisSessionState startSessionState:self.scoreRule session:self andDb:[self eventdb]];
    self.lastEventIdx = 0;
    self.replayToEventIdx = NSUIntegerMax;

    return self;
}

-(void)updateWithChangesIn:(TSTennisSession*)other{
    // FIXME: implement
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@[%@]: %d events %@>", NSStringFromClass([self class]), self.sessionId, (int)self.countOfEvents, self.cloudSessionRecordId?self.cloudSessionRecordId: @"localonly"];
}

#pragma mark - Database

-(void)loadEventsFromDb{
    RZPerformance * perf = [RZPerformance start];

    [self.state loadFromDb:self.eventdb];

    FMResultSet * res = [self.eventdb executeQuery:@"SELECT * FROM events ORDER BY time" ];
    while ([res next]) {
        [_events addObject:[TSTennisEvent eventWithResultSet:res]];
    }
    [self processNextEvent];

    if (!self.isReadOnly) {
        self.savedResult = [self.state currentResult];
    }
    RZLog(RZLogInfo, @"Loaded %@: %d events %@", self.sessionId, (int)self.events.count, perf);
}

/**
 @discussion Save session summary and details into the database.
 @param db that contains tennis_sessions and tennis_sessions_summary
 */
-(void)saveToDb:(FMDatabase*)db{
    if (self.sessionId==nil) {
        RZLog(RZLogError, @"Invalid session_id, can't save");
        return;
    }
    if(![db executeUpdate:@"INSERT OR REPLACE INTO tennis_sessions (session_id,startTime,duration,file,numberOfEvents,sessionRecordId) VALUES (?,?,?,?,?,?)",
         self.sessionId,
         self.startTime,
         @(self.duration),
         self.eventDbName,
         self.events ? @([self.events count]) : @(self.lastSyncEventCount),
         self.cloudSessionRecordId ? self.cloudSessionRecordId : [NSNull null]
         ]){
        RZLog(RZLogError, @"Failed to save session %@", [db lastErrorMessage]);
    }

    NSArray * res = [[self result] sets];
    NSUInteger nsets = res.count;

    if (self.player) {
        [self.player saveToDb:db];
    }
    if (self.opponent) {
        [self.opponent saveToDb:db];
    }

    if(![db executeUpdate:@"INSERT OR REPLACE INTO tennis_sessions_summary (session_id,playerId,opponentId,winner,rule,set1,set2,set3,set4,set5,resultWasEdited) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
         self.sessionId,
         @(self.player ? self.player.playerId : kInvalidPlayerId),
         @(self.opponent ? self.opponent.playerId : kInvalidPlayerId),
         @(self.contestantWinner),
         @([self.scoreRule pack]),
         nsets > 0 ? @([(TSTennisResultSet*)(res[0]) pack]) : [NSNull null],
         nsets > 1 ? @([(TSTennisResultSet*)(res[1]) pack]) : [NSNull null],
         nsets > 2 ? @([(TSTennisResultSet*)(res[2]) pack]) : [NSNull null],
         nsets > 3 ? @([(TSTennisResultSet*)(res[3]) pack]) : [NSNull null],
         nsets > 4 ? @([(TSTennisResultSet*)(res[4]) pack]) : [NSNull null],
         @(self.resultWasEdited)
         ]){
        RZLog(RZLogError, @"Failed to save session_summary %@", [db lastErrorMessage]);

    }
}
-(void)syncEventDb{
    if (self.lastSyncEventCount < self.events.count) {
        [self saveToDb:[self eventdb]];
        self.lastSyncEventCount = [self.events count];
    }
}

+(void)ensureDbStructure:(FMDatabase*)db{
    NSInteger version  = 1;

    if (/* DISABLES CODE */ (false)) {//Force rebuild
        [db executeUpdate:@"DROP TABLE tennis_sessions"];
        [db executeUpdate:@"DROP TABLE tennis_version"];
        [db executeUpdate:@"DROP TABLE tennis_sessions_summary"];
    }
    if (![db tableExists:@"tennis_sessions"]) {
        [db executeUpdate:@"CREATE TABLE tennis_sessions (session_id TEXT PRIMARY KEY, startTime REAL, duration REAL, file TEXT, numberOfEvents INTEGER,sessionRecordId TEXT)"];
    }
    if (![db tableExists:@"tennis_version"]) {
        [db executeUpdate:@"CREATE TABLE tennis_version (version INTEGER)"];
        [db executeUpdate:@"INSERT INTO tennis_version (version) VALUES (1)"];
    }

    if (![db tableExists:@"tennis_sessions_summary"]) {
        [db executeUpdate:@"CREATE TABLE tennis_sessions_summary (session_id TEXT PRIMARY KEY, playerId INTEGER, opponentId INTEGER, winner INTEGER, rule INTEGER, set1 INTEGER, set2 INTEGER, set3 INTEGER, set4 INTEGER, set5 INTEGER, resultWasEdited INTEGER DEFAULT 0)"];
    }
    version = [db intForQuery:@"SELECT MAX(version) FROM tennis_version"];

    if (![db columnExists:@"rule" inTableWithName:@"tennis_sessions_summary"]) {
        [db executeUpdate:@"ALTER TABLE tennis_sessions_summary ADD COLUMN rule INTEGER"];
    }
    if (![db columnExists:@"numberOfEvents" inTableWithName:@"tennis_sessions"]) {
        RZEXECUTEUPDATE(db, @"ALTER TABLE tennis_sessions ADD COLUMN numberOfEvents INTEGER");
    }
    if (![db columnExists:@"sessionRecordId" inTableWithName:@"tennis_sessions"]) {
        RZEXECUTEUPDATE(db, @"ALTER TABLE tennis_sessions ADD COLUMN sessionRecordId TEXT");
    }
    if (![db columnExists:@"playerId" inTableWithName:@"tennis_sessions_summary"]) {
        RZEXECUTEUPDATE(db, @"ALTER TABLE tennis_sessions_summary ADD COLUMN playerId INTEGER");
        RZEXECUTEUPDATE(db, @"ALTER TABLE tennis_sessions_summary ADD COLUMN opponentId INTEGER");
    }
    if (![db columnExists:@"resultWasEdited" inTableWithName:@"tennis_sessions_summary"]) {
        RZEXECUTEUPDATE(db, @"ALTER TABLE tennis_sessions_summary ADD COLUMN resultWasEdited INTEGER DEFAULT 0");
    }
}
/**
 @discussion update session with info from record from tennis_sessions_summary. Will check session_id are consitent or does nothing
 @param res form tennis_sessions_summary
 */
-(TSTennisSession*)updateWithSummaryResultSet:(FMResultSet *)res andPlayers:(TSPlayerManager*)players{
    if ([self.sessionId isEqualToString:[res stringForColumn:@"session_id"]]) {

        TSPlayerId playerId = [res intForColumn:@"playerId"];
        self.player = [players playerForId:playerId];
        self.opponent = [players playerForId:[res intForColumn:@"opponentId"]];
        self.contestantWinner = [res intForColumn:@"winner"];
        self.scoreRule = [[[TSTennisScoreRule alloc] init] unpack:[res intForColumn:@"rule"]];
        NSMutableArray * sets = [NSMutableArray arrayWithCapacity:5];
        for (NSUInteger i=0; i<5; i++) {
            NSString * colname = [NSString stringWithFormat:@"set%d", (int)i+1];
            if (![res columnIsNull:colname]) {
                [sets addObject:[[[TSTennisResultSet alloc] init] unpack:[res intForColumn:colname]]];
            }
        }
        self.savedResult = [TSTennisResult resultForSets:sets];
        self.resultWasEdited = [res boolForColumn:@"resultWasEdited"];
    }
    return self;
}

#pragma mark - CloudKit

+(TSTennisSession*)sessionWithRecord:(CKRecord*)record event:(CKRecord*)eventrec player:(TSPlayer*)player andOpponent:(TSPlayer*)opponent{
    TSTennisSession * rv = [[TSTennisSession alloc] init];
    if (rv) {
        rv.sessionId = record[kTSRecordFieldSessionId];
        rv.eventDbName = record[kTSRecordFieldEventDbName];
        CKAsset * eventasset =eventrec[kTSRecordFieldEventDb];
        NSData * file = [NSData dataWithContentsOfURL:eventasset.fileURL ];
        [file writeToFile:[RZFileOrganizer writeableFilePath:rv.eventDbName] atomically:NO];

    }
    return rv;
}

-(CKRecord*)cloudEventsRecord{
    if (!self.cachedCloudEventsRecord) {
        CKRecord * db = [[CKRecord alloc] initWithRecordType:kTSRecordTypeEventsDb];
        db[kTSRecordFieldEventDbName] =self.eventDbName;
        db[kTSRecordFieldEventDb] = [[CKAsset alloc] initWithFileURL:[NSURL fileURLWithPath:[RZFileOrganizer writeableFilePath:self.eventDbName]]];
        self.cachedCloudEventsRecord = db;
    }
    return self.cachedCloudEventsRecord;
}

-(CKRecord*)cloudSessionRecord{
    if (!self.cachedCloudSessionRecord) {
        CKRecord * rv = [[CKRecord alloc] initWithRecordType:kTSRecordTypeSession];
        rv[kTSRecordFieldSessionId] = self.sessionId;
        rv[kTSRecordFieldEventDbReference] = [[CKReference alloc] initWithRecord:self.cloudEventsRecord action:CKReferenceActionDeleteSelf];
        rv[kTSRecordFieldEventDbName] = self.eventDbName;
        rv[kTSRecordFieldScoreRule] = @([self.scoreRule pack]);
        rv[kTSRecordFieldStartTime] = self.startTime;
        rv[kTSRecordFieldWinner] = @(self.contestantWinner);
        rv[kTSRecordFieldResult] = [self.result pack];
        rv[kTSRecordFieldDuration] = @(self.duration);

        if(self.player){
            rv[kTSRecordFieldPlayerDescription] = [self.player displayName];
            rv[kTSRecordFieldPlayer] = [[CKReference alloc] initWithRecord:[self.player cloudPlayerRecord] action:CKReferenceActionNone];
        }
        if (self.opponent) {
            rv[kTSRecordFieldOpponentDescription] = [self.opponent displayName];
            rv[kTSRecordFieldOpponent] = [[CKReference alloc] initWithRecord:[self.opponent cloudPlayerRecord] action:CKReferenceActionNone];
        }
        self.cachedCloudSessionRecord = rv;
    }
    return  self.cachedCloudSessionRecord;
}

-(void)noticeCloudRecord:(CKRecord*)record{
    if ([record.recordType isEqualToString:kTSRecordTypeSession] && [record[kTSRecordFieldSessionId] isEqualToString:self.sessionId]) {
        self.cloudSessionRecordId = record.recordID.recordName;
        [self saveToDb:[self eventdb]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySessionDataChanged object:self];
    }
}

/// Has same values as record (same values or same recordId)
-(BOOL)matchesCloudRecord:(CKRecord*)record{
    return self.cloudSessionRecordId == record.recordID.recordName ||
    ([record[kTSRecordFieldSessionId] isEqualToString:self.sessionId]

    );
}

/// Was synch'd from record (same recordId)
-(BOOL)isSynchedFromCloudRecord:(CKRecord*)record{
    return self.cloudSessionRecordId == record.recordID.recordName;
}
-(BOOL)isSameCloudSession:(TSTennisSession*)other{
    return self.cloudSessionRecordId != nil && other.cloudSessionRecordId && [self.cloudSessionRecordId isEqualToString:other.cloudSessionRecordId];
}

#pragma mark - Events


-(void)processNextEvent{
    NSUInteger to   = self.events.count;
    if (self.replayToEventIdx != NSUIntegerMax) {
        to = MIN(self.replayToEventIdx, self.events.count);
        if (self.lastEventIdx>to) {
            [self.state resetState];
            self.lastEventIdx = 0;
        }
    }

    while (self.lastEventIdx < to) {
        TSTennisEvent * event = self.events[self.lastEventIdx];
        [self.state processEvent:event];
        self.lastEventIdx++;
    }

    [self notifyForString:kNotifySessionNewEvent];
}

-(NSUInteger)countOfEvents{
    return self.events.count;
}

-(void)replayToEventIndex:(NSUInteger)idx{
    if (self.isReadOnly) {//only for readonly
        self.replayToEventIdx = idx;
        [self processNextEvent];
    }else{
        self.replayToEventIdx = NSUIntegerMax;
    }
}

-(void)replayNextEvent{
    [self replayToEventIndex:self.lastEventIdx+1];
}

-(void)replayToEventMatching:(tsStateMatchingBlock)matching hint:(BOOL)lookBackward{
    if (self.isReadOnly) {
        if (lookBackward) {
            [self.state resetState];
            self.lastEventIdx = 0;
        }

        NSUInteger count = 0;
        while (count<self.events.count && !matching(self.state)) {
            if (self.lastEventIdx < self.events.count) {
                TSTennisEvent * event = self.events[self.lastEventIdx];
                [self.state processEvent:event];
            }
            self.lastEventIdx++;
            if (self.lastEventIdx>=self.events.count) {
                self.lastEventIdx=0;
                [self.state resetState];
            }
            count++;

        }

        [self notifyForString:kNotifySessionNewEvent];

    }else{
        self.replayToEventIdx = NSUIntegerMax;
    }
}

-(TSTennisEvent*)currentEvent{
    NSUInteger cur = self.lastEventIdx-1;
    return cur < self.events.count ?  self.events[cur] : nil;
}
/**
 @discussion Add event and process. If the session is read only the event won't be added

 */
-(void)addEvent:(TSTennisEvent *)event{
    if(self.isReadOnly){
        return;
    }

    if (self.startTime == nil) {
        self.startTime = event.time;
        self.duration = 0;
    }else{
        self.duration = [event.time timeIntervalSinceDate:self.startTime];
    }

    [_events addObject:event];

    if (_worker) {
        [event performSelector:@selector(saveToDb:) onThread:_worker withObject:_cachedEventdb waitUntilDone:NO];
        if (self.enableLogging) {
            [self performSelector:@selector(saveLogEntry) onThread:_worker withObject:nil waitUntilDone:NO];
        }
        [self performSelector:@selector(processNextEvent) onThread:_worker withObject:nil waitUntilDone:NO];
    }else{
        [event saveToDb:_cachedEventdb];
        if (self.enableLogging) {
            [self saveLogEntry];
        }
        [self processNextEvent];
    }
}

#pragma mark - Logging

-(void)setupForLogging:(BOOL)yesorno{
    if (yesorno) {
        FMDatabase * db = [self eventdb];

        if (![db tableExists:@"session_log"]) {
            RZEXECUTEUPDATE(db, @"CREATE TABLE session_log (playerScore TEXT,opponentScore TEXT,playerShot TEXT,opponentShot TEXT, playerAnalysis TEXT,opponentAnalysis TEXT)");
        }
        self.enableLogging = true;
    }else{
        self.enableLogging = false;
    }
}

-(void)saveLogEntry{
    if (self.enableLogging) {
        TSTennisSessionState * state = self.state;

        RZEXECUTEUPDATE( [self eventdb],
                        @"INSERT INTO session_log (playerScore,opponentScore,playerShot,opponentShot,playerAnalysis,opponentAnalysis) VALUES (?,?,?,?,?,?)",
                        [[state currentScore] playerScore],
                        [[state currentScore] opponentScore],
                        [state playerCurrentShotDescription],
                        [state opponentCurrentShotDescription],
                        [state playerCurrentAnalysis],
                        [state opponentCurrentAnalysis]
                        );
    }
}


#pragma mark - Summary and Description

-(NSString*)displayPlayerName{
    return self.player ? [self.player displayName] : @"Player";
}
-(NSString*)displayOpponentName{
    return self.opponent ? [self.opponent displayName] : @"Opponent";
}

-(TSTennisResult*)result{
    if (self.savedResult) {
        return self.savedResult;
    }else{
        return [self.state currentResult];
    }
}

-(void)saveResult:(TSTennisResult*)result{
    self.savedResult = [[[TSTennisResult alloc] init] unpack:[result pack]];
    self.resultWasEdited = true;
    [self saveToDb:[self eventdb]];
    [self notifyForString:kNotifySessionDataChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySessionDataChanged object:self];

}
-(void)registerPlayer:(TSPlayer*)player{
    if (player != self.player) {
        [self.player detach:self];
        self.player = player;
        [self.player attach:self];
        [self.player saveToDb:[self eventdb]];
        [self saveToDb:[self eventdb]];
        [self notifyForString:kNotifySessionDataChanged];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySessionDataChanged object:self];
    }
}
-(void)registerOpponent:(TSPlayer*)opponent{
    if (opponent != self.opponent) {
        [self.opponent detach:self];
        self.opponent = opponent;
        [self.opponent attach:self];
        [self.opponent saveToDb:[self eventdb]];
        [self saveToDb:[self eventdb]];
        [self notifyForString:kNotifySessionDataChanged];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySessionDataChanged object:self];
    }
}
-(void)registerContestantWinner:(tsContestant)which{
    if (self.contestantWinner != which) {
        self.contestantWinner = which;
        [self saveToDb:[self eventdb]];
        [self notifyForString:kNotifySessionDataChanged];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySessionDataChanged object:self];
    }
}

-(void)changeScoreRule:(TSTennisScoreRule*)newRule{
    self.scoreRule = newRule;
    [self.state changeScoreRule:newRule];
    [self saveToDb:[self eventdb]];
    [self notifyForString:kNotifySessionDataChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySessionDataChanged object:self];
}

#pragma mark - Notification

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (theParent == self.player) {
        [self.player saveToDb:[self eventdb]];
    }else if (theParent == self.opponent){
        [self.opponent saveToDb:[self eventdb]];
    }
}
@end
