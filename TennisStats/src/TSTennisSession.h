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

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "TSTennisEvent.h"
#import "TSTennisSessionState.h"
#import "TSPlayer.h"
#import "TSTennisScore.h"
#import "TSPlayerManager.h"


extern NSString * kNotifySessionNewEvent;
extern NSString * kNotifySessionDataChanged;

@interface TSTennisSession : RZParentObject<RZChildObject>

@property (nonatomic,retain) NSString * sessionId;

@property (nonatomic,assign) BOOL isReadOnly;

@property (nonatomic,retain) NSDate * startTime;
@property (nonatomic,assign) NSTimeInterval duration;

+(TSTennisSession*)sessionWithSummaryFromResultSet:(FMResultSet*)res andThread:(NSThread*)thread;
+(TSTennisSession*)sessionWithId:(NSString*)sessionid forRule:(TSTennisScoreRule*)rule andThread:(NSThread*)thread;
+(TSTennisSession*)sessionFromEventDb:(FMDatabase*)db players:(TSPlayerManager*)players andThread:(NSThread*)thread;

-(void)saveToDb:(FMDatabase*)db;
-(void)updateWithChangesIn:(TSTennisSession*)other;
-(TSTennisSession*)updateWithSummaryResultSet:(FMResultSet*)res andPlayers:(TSPlayerManager*)players;
+(void)ensureDbStructure:(FMDatabase*)db;
-(void)syncEventDb;
-(void)setupForLogging:(BOOL)yesorno;

-(CKRecord*)cloudSessionRecord;
-(CKRecord*)cloudEventsRecord;
-(void)noticeCloudRecord:(CKRecord*)record;
/// Has same values as record (same values or same recordId)
-(BOOL)matchesCloudRecord:(CKRecord*)record;
/// Was synch'd from record (same recordId)
-(BOOL)isSynchedFromCloudRecord:(CKRecord*)record;
-(BOOL)isSameCloudSession:(TSTennisSession*)other;

-(FMDatabase*)eventdb;
-(void)addEvent:(TSTennisEvent*)event;

-(NSUInteger)countOfEvents;
-(NSUInteger)lastEventIdx;
-(void)replayToEventIndex:(NSUInteger)idx;
-(void)replayNextEvent;
-(void)replayToEventMatching:(tsStateMatchingBlock)matching hint:(BOOL)lookBackward;
-(TSTennisEvent*)currentEvent;

-(TSTennisSessionState*)state;
-(TSTennisScoreRule*)scoreRule;
-(TSTennisResult*)result;
-(void)saveResult:(TSTennisResult*)result;

-(NSString*)displayPlayerName;
-(NSString*)displayOpponentName;

-(TSPlayer*)player;
-(TSPlayer*)opponent;

-(void)registerPlayer:(TSPlayer*)player;
-(void)registerOpponent:(TSPlayer*)opponent;
-(tsContestant)contestantWinner;
-(void)registerContestantWinner:(tsContestant)which;

+(void)setSessionFilePrefix:(NSString*)prefix;
+(NSString*)sessionFilePrefix;

@end
