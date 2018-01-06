//  MIT Licence
//
//  Created on 07/12/2014.
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

#import "TSCloudOrganizer.h"
#import "TSCloudTypes.h"
#import "TSAppGlobal.h"
#import "TSPlayerManager.h"
#import "TSTennisOrganizer.h"
@import Contacts;
/*
 RESET FROM ICLOUD
 Comment

 */


/*
 Save to cloud : save/get icloud I'd/update database for new icloudid
 Check if player have cloudid if not upload/sync
 Cloud session use cloud player ids

 Load from cloud: download and save session and icloudid

 Check for new sessions
 List session from friend who don't have a sync'd Id
 Save summary but no full download?

 Players;
 Has sync Id: use
 Find if match not sync'd : update cloud id
 Upload if no match

 Players download existing players and merge.

 On startup check for new players from friends
 Check for new cloud sessions from friends

 (Search player modification date  > last sync date)


 Sessions:
 --------

 In cloud: first/last event to check same on type/time
 Locally:  cloudSessionId or null -> was saved or not


 Players:
 -------

 In cloud: first/last name to check same
 Locally: cloudPlayerId or null -> was saved/matched/downloaded

 */

NSString * kNotifyCloudFoundNewSessions = @"kNotifyCloudFoundNewSessions";

@interface TSCloudOrganizer ()
@property (nonatomic,assign) BOOL enabled;
@property (nonatomic,retain) CKRecordID * userRecordId;
@property (nonatomic,retain) CKRecord * userRecord;

@property (nonatomic,retain) NSThread * worker;
@property (nonatomic,retain) FMDatabase * db;

@property (nonatomic,retain) CKDatabase * publicDatabase;
@property (nonatomic,retain) CKDatabase * privateDatabase;

@property (nonatomic,retain) NSError * lastError;
@property (nonatomic,assign) CKApplicationPermissionStatus permissionStatus;
@property (nonatomic,retain) NSString * status;

@property (nonatomic,retain) NSArray * foundRecords;
@property (nonatomic,retain) NSArray * discoveredUsers;
@property (nonatomic,retain) NSArray * discoveredUserRecordIds;

@property (nonatomic,retain) NSDictionary * discoveredUserNames;

@end

@implementation TSCloudOrganizer

-(TSCloudOrganizer*)initWithDatabase:(FMDatabase*)db andThread:(NSThread*)thread{

    self = [super init];
    if (self) {
        self.worker = thread;
        self.db = db;
        self.lastError = nil;
        self.permissionStatus = CKApplicationPermissionStatusInitialState;
        self.status = NSLocalizedString(@"Stand by", @"iCloud Status");
        // If enabled
        [self startCloudConnection];
    }
    return self;
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if ([db tableExists:@"icloud_users"]) {
        RZEXECUTEUPDATE(db, @"CREATE TABLE icloud_users (userRecordID TEXT,firstName TEXT, lastName TEXT)");
    }
}

-(NSString*)statusDescription{
    if (self.lastError) {
        return [self.lastError localizedDescription];
    }else{
        if (self.permissionStatus!=CKApplicationPermissionStatusGranted) {
            return @"Not permissioned yet";
        }
    }
    if (self.status) {
        return self.status;
    }
    return @"OK";
}

#pragma mark - Connection

-(void)startCloudConnection{
    self.lastError = nil;
    self.status = NSLocalizedString(@"Connecting to iCloud", @"iCloud Status");

    [[CKContainer defaultContainer] requestApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:^(CKApplicationPermissionStatus status, NSError * error){
        if (error) {
            self.lastError = error;
            RZLog(RZLogError, @"Failed to use iCloud %@", error);
        }else{
            self.permissionStatus = status;
            switch (status) {
                case CKApplicationPermissionStatusCouldNotComplete:
                case CKApplicationPermissionStatusDenied:
                case CKApplicationPermissionStatusInitialState:
                    self.enabled = false;
                    RZLog(RZLogInfo, @"Disabled CloudKit %d", (int)status);
                    break;
                case CKApplicationPermissionStatusGranted:
                    self.enabled = true;
                    self.publicDatabase = [[ CKContainer defaultContainer] publicCloudDatabase];
                    self.privateDatabase = [[ CKContainer defaultContainer] privateCloudDatabase];
                    RZLog(RZLogInfo, @"Enabled CloudKit");
                    if (self.worker) {
                        [self performSelector:@selector(fetchCurrentUser) onThread:self.worker withObject:nil waitUntilDone:NO];
                    }else{
                        [self fetchCurrentUser];
                    }
            }
        }
        self.status = nil;
        [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];

    }];
}

#pragma mark - Users

-(NSString*)userName:(CKRecordID*)recordId{
    if (self.discoveredUserNames[recordId.recordName]) {
        return self.discoveredUserNames[recordId.recordName];
    }else{
        return @"Unknown User";
    }
}
-(void)discoverUsers{
    self.lastError = nil;
    self.status = NSLocalizedString(@"Searching for friends", @"iCloud Status");
    CKDiscoverAllContactsOperation *  op = [[CKDiscoverAllContactsOperation alloc] init];
    op.discoverAllContactsCompletionBlock = ^(NSArray * userInfo, NSError * error){
        if (error) {
            self.lastError = error;
            RZLog(RZLogError, @"Failed to query users");
            [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];

        }else{
            self.discoveredUsers = userInfo;
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            NSMutableArray * usersId = [NSMutableArray arrayWithCapacity:userInfo.count];
            for (CKDiscoveredUserInfo * info in userInfo) {
                [usersId addObject:info.userRecordID];
                CNContact * contact = [info displayContact];

                NSLog(@"Discovered %@", [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName]);
                dict[ info.userRecordID.recordName ] = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
            }
            self.discoveredUserNames = dict;
            self.discoveredUserRecordIds = usersId;
            [self listSessions];
            [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
        }
    };
    [[CKContainer defaultContainer] addOperation:op];

}

-(void)fetchCurrentUser{
    self.lastError = nil;
    self.status = NSLocalizedString(@"Connecting to iCloud", @"iCloud Status");

    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID*record,NSError*error){
        if (error) {
            self.lastError = error;
            RZLog(RZLogError, @"Failed to get userRecordId %@", error);
            [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];

        }else{
            self.userRecordId = record;
            [[CKContainer defaultContainer] discoverUserInfoWithUserRecordID:self.userRecordId completionHandler:^(CKDiscoveredUserInfo * info, NSError * error){
                if (error) {
                    self.lastError = error;
                    RZLog(RZLogError, @"Failed to get userRecord %@", error);
                }else{
                    RZLog(RZLogInfo, @"Discovered we are: %@", [CNContactFormatter stringFromContact:info.displayContact style:CNContactFormatterStyleFullName]);
                }
                [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
                [self discoverUsers];
            }];
        }
        self.status = nil;
    }];
}

-(NSUInteger)countOfDiscoveredUsers{
    NSUInteger rv = 0;
    if (self.userRecordId) {
        rv++;
    }
    if (self.discoveredUserRecordIds) {
        rv += self.discoveredUserRecordIds.count;
    }
    return rv;
}

#pragma  mark - TennisSessions

-(void)saveSession:(TSTennisSession*)session{
    if (self.enabled) {
        self.lastError = nil;
        self.status = NSLocalizedString(@"Connecting to iCloud", @"iCloud Status");

        [self ensurePlayerRecords:@[ session.player,session.opponent] completion:^(NSError*error1){
            if (error1) {
                self.lastError = error1;
                RZLog(RZLogError, @"Failed to save session %@", error1);
            }else{
                NSArray * records = @[ session.cloudEventsRecord, session.cloudSessionRecord];

                CKModifyRecordsOperation * op = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:records recordIDsToDelete:nil];
                op.modifyRecordsCompletionBlock= ^(NSArray*r, NSArray*d, NSError*error2){
                    if (error2) {
                        self.lastError = error2;
                        RZLog(RZLogError, @"Failed to save record %@", error2);
                    }else{
                        if (r.count==2) {
                            RZLog(RZLogInfo, @"Saved %@ to CloudKit", session.sessionId);
                            [session noticeCloudRecord:r[1]];
                        }else{
                            RZLog(RZLogError, @"Hum expected 2 record saved");
                        }
                    }
                    self.status = nil;
                    [self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:NO];
                };
                [self.publicDatabase addOperation:op];
            };
        }];
    }
}
-(void)retrieveSessionFromRecord:(CKRecord*)record completion:(cloudOrganizerRetrieveSessionCompletion)completion{
    if (self.enabled && [record.recordType isEqualToString:kTSRecordTypeSession]) {
        CKReference * eventref = record[kTSRecordFieldEventDbReference];
        if (eventref) {
            NSMutableArray * toRetrieve= [NSMutableArray arrayWithObject:eventref.recordID];
            CKReference * playerref = record[kTSRecordFieldPlayer];
            CKReference * opponentref = record[kTSRecordFieldOpponent];
            if (playerref) {
                [toRetrieve addObject:playerref.recordID];
            }
            if (opponentref) {
                [toRetrieve addObject:opponentref.recordID];
            }
            CKFetchRecordsOperation * fetchOp = [[CKFetchRecordsOperation alloc] initWithRecordIDs:toRetrieve];
            fetchOp.fetchRecordsCompletionBlock = ^(NSDictionary*records,NSError*error){
                if (error) {
                    //completion(nil,error);
                    RZLog(RZLogWarning, @"Error %@", error);
                }
                TSPlayer * player = nil;
                TSPlayer * opponent = nil;
                if (playerref) {
                    CKRecord * playerrec = records[playerref.recordID];
                    if (playerrec) {
                        player = [[TSAppGlobal players] playerForRecord:playerrec];
                    }
                }
                if (opponentref) {
                    CKRecord * opponentrec = records[opponentref.recordID];
                    if (opponentrec) {
                        opponent = [[TSAppGlobal players] playerForRecord:opponentrec];
                    }
                }
                CKRecord * eventdb = records[eventref.recordID];
                if (eventdb) {
                    CKAsset * asset = eventdb[kTSRecordFieldEventDb];
                    NSString * dbname = eventdb[kTSRecordFieldEventDbName];
                    if (![dbname hasPrefix:@"cloud_"]) {
                        dbname =[NSString stringWithFormat:@"cloud_%@", dbname];
                    }
                    NSString * dbpath =[RZFileOrganizer writeableFilePath:dbname];
                    NSURL * newfile = [NSURL fileURLWithPath:dbpath];
                    NSError * copyError = nil;
                    if ([[NSFileManager defaultManager] fileExistsAtPath:dbpath isDirectory:nil]) {
                        RZLog(RZLogWarning, @"Session already exists, clearing old file");

                        [[NSFileManager defaultManager] removeItemAtURL:newfile error:&copyError];
                    }
                    [[NSFileManager defaultManager] copyItemAtURL:asset.fileURL toURL:newfile error:&copyError];
                    if (copyError) {
                        RZLog(RZLogWarning, @"Copy Error %@", copyError);
                    }else{

                        FMDatabase * db = [FMDatabase databaseWithPath:dbpath];
                        [db open];
                        TSTennisSession * session = [[TSAppGlobal organizer] sessionFromEventDb:db];
                        RZLog(RZLogInfo, @"Retrieved Event for session %@ [%@]", session.sessionId, [dbpath lastPathComponent]);

                        completion(session,nil);
                    }
                }
            };
            [self.publicDatabase addOperation:fetchOp];
        }
    }
}

-(NSArray*)listSessions{
    return self.foundRecords;
}


-(void)fetchNewSessions{
    if (self.enabled && self.discoveredUserRecordIds) {
        self.lastError = nil;
        self.status = NSLocalizedString(@"Checking new sessions", @"iCloud Status");

        NSPredicate * predicate = nil;
        CKQuery * query = nil;
        CKQueryOperation * qop = nil;

        void (^queryCompletionBlock)( CKQueryCursor *cursor, NSError *operationError) = ^( CKQueryCursor *cursor, NSError *operationError){
            if (operationError) {
                self.lastError = operationError;
                RZLog(RZLogError, @"Failed to execute query %@", operationError);
            }else if(cursor){
                CKQueryOperation * nextop = [[CKQueryOperation alloc] initWithCursor:cursor];
                [self.publicDatabase addOperation:nextop];
            }else{
                RZLog(RZLogInfo,@"Retrieved %d records", (int)self.foundRecords.count);
                [self performSelectorOnMainThread:@selector(notifyForString:) withObject:kNotifyCloudFoundNewSessions waitUntilDone:NO];
            }
        };

        void (^recordFetchedBlock)( CKRecord *record) = ^(CKRecord*record){
            if (self.foundRecords==nil) {
                self.foundRecords = @[record];
            }else{
                self.foundRecords = [[[self foundRecords] arrayByAddingObject:record] sortedArrayUsingComparator:^(CKRecord * r1, CKRecord * r2){
                    NSDate * d1 = r1[kTSRecordFieldStartTime];
                    NSDate * d2 = r2[kTSRecordFieldStartTime];
                    return [d2 compare:d1];
                }];
            }
        };

        self.foundRecords = @[];

        predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"creatorUserRecordID", self.userRecordId];
        query = [[CKQuery alloc] initWithRecordType:kTSRecordTypeSession predicate:predicate];
        qop = [[CKQueryOperation alloc] initWithQuery:query];
        qop.queryCompletionBlock = queryCompletionBlock;
        qop.recordFetchedBlock = recordFetchedBlock;

        [self.publicDatabase addOperation:qop];

        for (CKRecordID * rid in self.discoveredUserRecordIds) {
            // Don't ask for self records twice.
            if (![rid.recordName isEqualToString:self.userRecordId.recordName]) {
                predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"creatorUserRecordID", rid];
                query = [[CKQuery alloc] initWithRecordType:kTSRecordTypeSession predicate:predicate];
                qop = [[CKQueryOperation alloc] initWithQuery:query];
                qop.queryCompletionBlock = queryCompletionBlock;
                qop.recordFetchedBlock = recordFetchedBlock;
                [self.publicDatabase addOperation:qop];
            }
        }
    }
}

#pragma mark - Players

-(void)ensurePlayerRecords:(NSArray*)players completion:(cloudOrganizerCompletion)completionblock{
    NSMutableArray * toRetrieve = [NSMutableArray arrayWithCapacity:players.count];
    NSMutableArray * toSave     = [NSMutableArray arrayWithCapacity:players.count];

    TSPlayerManager * manager = [TSAppGlobal players];

    for (TSPlayer * player in players) {
        if ([player existsInCloud]) {
            [toRetrieve addObject:player];
        }else{
            [toSave addObject:[player cloudPlayerRecord]];
        }
    }
    NSMutableArray * retrieveId = [NSMutableArray arrayWithCapacity:toRetrieve.count];
    for (TSPlayer * player in toRetrieve) {
        [retrieveId addObject:[player recordID]];
    }
    CKFetchRecordsOperation * fetchOp = nil;
    CKModifyRecordsOperation * saveOp = nil;

    if (retrieveId.count) {
        fetchOp = [[CKFetchRecordsOperation alloc] initWithRecordIDs:retrieveId];
    }
    if (toSave.count) {
        saveOp = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:toSave recordIDsToDelete:nil];
        saveOp.modifyRecordsCompletionBlock = ^(NSArray*r, NSArray*d, NSError*error){
            if (error) {
                completionblock(error);
            }else{
                NSUInteger i=0;
                for (TSPlayer * player in players) {
                    if (![player existsInCloud]) {
                        [manager noticeCloudRecord:r[i++] forPlayer:player];
                    }
                }
                completionblock(nil);
            }
        };
    }
    if (fetchOp) {
        fetchOp.fetchRecordsCompletionBlock = ^(NSDictionary * records, NSError * error){
            if (error) {
                completionblock(error);
            }else{
                for (TSPlayer * player in toRetrieve) {
                    CKRecord * record = records[player.recordID];
                    if (record) {
                        [manager noticeCloudRecord:record forPlayer:player];
                    }
                }
                if (saveOp) {
                    [self.publicDatabase addOperation:saveOp];
                }else{
                    completionblock(nil);
                }
            }
        };
        [self.publicDatabase addOperation:fetchOp];
    }else{
        [self.publicDatabase addOperation:saveOp];
    }
}

@end
