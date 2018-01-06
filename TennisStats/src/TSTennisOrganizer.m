//  MIT Licence
//
//  Created on 24/10/2014.
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

#import "TSTennisOrganizer.h"
#import "TSTennisSession.h"
#import "TSPlayerManager.h"

NSString * kNotifyOrganizerSessionChanged = @"kNotifySessionChanged";

NSUInteger kThrottleCount = 5;

@interface TSTennisOrganizer ()
@property (nonatomic,retain) FMDatabase*db;
@property (nonatomic,retain) NSThread * worker;
@property (nonatomic,retain) NSArray * sessions;
@property (nonatomic,retain) TSTennisSession * currentSession;
@property (nonatomic,assign) NSUInteger saveThrottle;
@property (nonatomic,retain) TSPlayerManager * players;
@end


@implementation TSTennisOrganizer

+(TSTennisOrganizer*)organizerWith:(FMDatabase*)db players:(TSPlayerManager*)players andThread:(NSThread*)thread{
    TSTennisOrganizer * rv = [[TSTennisOrganizer alloc] init];
    if (rv) {
        rv.db = db;
        rv.worker = thread;
        rv.players = players;
        if (rv.worker) {
            rv.sessions = @[];
            [rv performSelector:@selector(loadFromDb:) onThread:rv.worker withObject:rv.db waitUntilDone:NO];
        }else{
            [rv loadFromDb:db];
        }
    }
    return rv;
}
-(TSTennisOrganizer*)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDataChanged:) name:kNotifySessionDataChanged object:nil];
    }
    return self;
}

-(void)dealloc{
    [self.currentSession detach:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Database

-(void)loadFromDb:(FMDatabase*)db{
    FMResultSet * res = [db executeQuery:@"SELECT * FROM tennis_sessions ORDER BY startTime DESC"];
    NSMutableArray * rv = [NSMutableArray array];
    NSThread * thread = self.worker;
    NSMutableDictionary * access = [NSMutableDictionary dictionary];
    while ([res next]) {
        TSTennisSession * session = [TSTennisSession sessionWithSummaryFromResultSet:res andThread:thread];
        [rv addObject:session];
        access[session.sessionId] = session;
    }

    res = [db executeQuery:@"SELECT * FROM tennis_sessions_summary"];
    while ([res next]) {
        NSString * sessionId = [res stringForColumn:@"session_id"];
        TSTennisSession * session = access[sessionId];
        if (session) {
            [session updateWithSummaryResultSet:res andPlayers:self.players];
        }
    }

    self.sessions = rv;
    if (self.sessions.count > 0) {
        [self selectSessionIndex:0];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyOrganizerSessionChanged object:nil];

}
+(NSString*)eventDbNameFromSessionId:(NSString*)sid{
    return [NSString stringWithFormat:@"session_%@.db", sid];
}
+(NSString*)sessionIdFromEventDbName:(NSString*)fn{
    if ([fn hasPrefix:@"session_"] && [fn hasSuffix:@".db"]) {
        // 11 = 8(session_) + 3(.db)
        NSUInteger endI = fn.length > 11 ? fn.length-11 : 0;
        return [[fn substringFromIndex:8] substringToIndex:endI];
    }
    return nil;
}


-(void)importExistingDb{


    NSArray * existing = [RZFileOrganizer writeableFilesMatching:^(NSString*fn){
        return [fn hasPrefix:[NSString stringWithFormat:@"%@_%@", [TSTennisSession sessionFilePrefix], self.sessionIdPrefix]];
    }];
    NSMutableDictionary * inDb = [NSMutableDictionary dictionaryWithCapacity:existing.count];
    FMResultSet * res = [self.db executeQuery:@"SELECT file FROM tennis_sessions"];
    while ([res next]) {
        NSString * file = [res stringForColumn:@"file"];
        inDb[file] = file;
    }
    NSUInteger newSessions = 0;
    for (NSString * fn in existing) {
        if (inDb[fn] == nil ) {

            FMDatabase * eventdb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:fn]];
            [eventdb open];
            TSTennisSession * session = [TSTennisSession sessionFromEventDb:eventdb players:self.players andThread:nil];
            if (session) {
                [session saveToDb:self.db];
                newSessions++;
            }else{
                RZLog(RZLogInfo, @"Removing Empty or test session %@", fn);
                [RZFileOrganizer removeEditableFile:fn];
            }
        }
    }
    if (newSessions>0) {
        RZLog(RZLogInfo, @"Found %d new sessions files", (int)newSessions);
    }
}

+(void)ensureDbStructure:(FMDatabase*)db{
    [TSTennisSession ensureDbStructure:db];

}

-(TSTennisSession*)sessionFromEventDb:(FMDatabase*)eventdb{
    TSTennisSession * session = [TSTennisSession sessionFromEventDb:eventdb players:self.players andThread:nil];

    TSTennisSession * found = nil;
    for (TSTennisSession * one in _sessions) {
        if ([one isSameCloudSession:session]) {
            found = one;
            break;
        }
        if ([session.sessionId isEqualToString:one.sessionId]) {
            found = one;
            break;

        }
    }

    if (!found) {
        self.sessions = [[self.sessions arrayByAddingObject:session] sortedArrayUsingComparator:^(TSTennisSession*s1, TSTennisSession*s2){
            return [s2.startTime compare:s1.startTime];
        }];
        if (self.worker) {
            [self performSelector:@selector(saveChangesToSession:) onThread:self.worker withObject:session waitUntilDone:NO];
        }else{
            [self saveChangesToSession:session];
        }

        [self changeSession:session];
        found = session;
    }else{
        // Already Exists
        // FIXME: need to update with changes in session existing one
        [found updateWithChangesIn:session];
        [self changeSession:found];
    }
    return found;

}

#pragma mark - Sessions Access

-(NSString*)newSessionId:(NSString*)baseid{
    NSString * newSessionId = baseid;
    if (self.sessionIdPrefix) {
        newSessionId = [self.sessionIdPrefix stringByAppendingString:newSessionId];
    }
    BOOL found = false;
    NSString * base = newSessionId;
    NSUInteger extra = 0;
    do {
        found = false;
        for (TSTennisSession * session in _sessions) {
            if ([session.sessionId isEqualToString:newSessionId]) {
                found = true;
                extra++;
                newSessionId = [base stringByAppendingString:[@(extra) stringValue]];
                break;
            }
        }
    } while (found);

    return newSessionId;
}


-(TSTennisSession*)startNewSession:(TSTennisScoreRule*)rule{
    NSString * newSessionId = [self newSessionId:[[NSDate date] YYYYMMDDhhmmssGMT]];
    TSTennisSession * session = [TSTennisSession sessionWithId:newSessionId forRule:rule andThread:self.worker];
    self.sessions = [[self.sessions arrayByAddingObject:session] sortedArrayUsingComparator:^(TSTennisSession*s1, TSTennisSession*s2){
        return [s2.startTime compare:s1.startTime];
    }];
    if (self.worker) {
        [self performSelector:@selector(saveChangesToSession:) onThread:self.worker withObject:session waitUntilDone:NO];
    }else{
        [self saveChangesToSession:session];
    }

    [self changeSession:session];
    return session;
}

-(TSTennisSession*)selectSessionForId:(NSString*)sessionId{
    for (TSTennisSession * session in _sessions) {
        if ([session.sessionId isEqualToString:sessionId]) {
            [self changeSession:session];
            return session;
        }
    }
    return nil;
}
-(TSTennisSession*)selectSessionIndex:(NSUInteger)index{
    if (index < self.sessions.count) {
        [self changeSession:self.sessions[index]];
        return self.currentSession;
    }
    return nil;
}
-(NSUInteger)count{
    return _sessions.count;
}

-(void)changeSession:(TSTennisSession*)session{
    if (self.currentSession) {
        if (self.worker) {
            [self performSelector:@selector(saveChangesToSession:) onThread:self.worker withObject:self.currentSession waitUntilDone:NO];
        }else{
            [self saveChangesToSession:self.currentSession];
        }
        [self.currentSession detach:self];
    }
    self.currentSession = session;
    [self.currentSession attach:self];
    self.saveThrottle = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyOrganizerSessionChanged object:self];
}
-(void)saveChangesToSession:(TSTennisSession*)session{
    [session saveToDb:self.db];
    [session syncEventDb];
}

-(void)deleteSession:(TSTennisSession*)session{
    NSMutableArray * newSessions = [NSMutableArray arrayWithCapacity:self.sessions.count];
    for (TSTennisSession * one in self.sessions) {
        if ([one.sessionId isEqualToString:session.sessionId]) {
            continue;
        }
        [newSessions addObject:one];
    }
    self.sessions = newSessions;
    if (self.currentSession == session) {
        self.currentSession = self.sessions[0];
    }

    void (^deleteRecords)(void) = ^(){
        [self.db beginTransaction];
        RZEXECUTEUPDATE(self.db, @"DELETE FROM tennis_sessions WHERE session_id = ?", session.sessionId);
        RZEXECUTEUPDATE(self.db, @"DELETE FROM tennis_sessions WHERE session_id = ?", session.sessionId);
        if ([self.db commit]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyOrganizerSessionChanged object:nil];
        }else {
            RZLog(RZLogError, @"Failed to delete sessions %@", [self.db lastErrorMessage]);
        }
    };

    if (self.worker) {
        [self.worker performBlock:deleteRecords];
    }else{
        deleteRecords();
    }
}

#pragma mark - Notifications

-(void)sessionDataChanged:(NSNotification*)obj{
    TSTennisSession * found = nil;
    for (TSTennisSession * session in _sessions) {
        if (obj.object==session) {
            found = obj.object;
            break;
        }
    }
    if (found) {
        if (self.worker) {
            [self performSelector:@selector(saveChangesToSession:) onThread:self.worker withObject:found waitUntilDone:NO];
        }else{
            [self saveChangesToSession:found];
        }
    }
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if (theInfo.stringInfo == kNotifySessionNewEvent) {
        self.saveThrottle++;
        if (self.saveThrottle > kThrottleCount) {
            if (self.worker) {
                [self performSelector:@selector(saveChangesToSession:) onThread:self.worker withObject:self.currentSession waitUntilDone:NO];
            }else{
                [self saveChangesToSession:self.currentSession];
            }
            self.saveThrottle = 0;
        }
    }
}

#pragma mark - Cloud

-(TSTennisSession*)findSessionForRecord:(CKRecord*)record{
    TSTennisSession * found = nil;
    for (TSTennisSession* obj in _sessions) {
        if ([obj isSynchedFromCloudRecord:record]) {
            found = obj;
            break;
        }
    }
    return found;
}


@end
