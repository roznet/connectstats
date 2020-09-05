//  MIT License
//
//  Created on 14/03/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCConnectStatsStatus.h"

const NSUInteger kPreviousStatusMaxCount = 4;

@interface GCConnectStatsStatus ()
@property (nonatomic,retain) NSURLSessionTask * messagesTask;
@property (nonatomic,copy) GCConnectStatsStatusCallBack callback;

@property (nonatomic,retain) NSDictionary * remoteStatus;
@property (nonatomic,retain) NSArray<NSDictionary*> * knownStatuses;
@end

@implementation GCConnectStatsStatus

+(GCConnectStatsStatus*)status{
    GCConnectStatsStatus * rv = RZReturnAutorelease([[GCConnectStatsStatus alloc] init]);
    
    [rv loadLocalStatus];
    
    return rv;
}

-(void)dealloc{
    [_messagesTask release];
    [_callback release];
    [_knownStatuses release];
    [_remoteStatus release];
    
    [super dealloc];
}

-(NSString*)localStatusFilePath{
    return [RZFileOrganizer writeableFilePath:@"remote_status.json"];
}

-(void)loadLocalStatus{
    self.knownStatuses = @[];
    NSString * fp = [self localStatusFilePath];
    if( [[NSFileManager defaultManager] isReadableFileAtPath:fp] ){
    
        NSData * data = [NSData dataWithContentsOfFile:fp];
        if( data ){
            NSError * error = nil;
            NSArray * json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if( [json isKindOfClass:[NSArray class]] ){
                self.knownStatuses = json;
            }
        }
    }
}

-(void)saveLocalStatus{
    NSArray * toSave = self.knownStatuses ?: @[];
    if( [self hasNewStatus]){
        toSave = [toSave arrayByAddingObject:self.remoteStatus];
    }
    if( toSave.count > kPreviousStatusMaxCount){
        toSave = [toSave subarrayWithRange:NSMakeRange(toSave.count - kPreviousStatusMaxCount, kPreviousStatusMaxCount)];
    }
    
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:toSave options:0 error:&error];
    if( data ){
        if( ![data writeToFile:[self localStatusFilePath] atomically:YES] ){
            RZLog(RZLogError, @"Failed to write status file");
        }
    }else{
            RZLog(RZLogError, @"Failed to generate json status file %@", error);
    }
}

-(BOOL)hasNewStatus{
    NSUInteger remoteStatusId = [self statusIdFor:self.remoteStatus];
    NSUInteger knownStatusId = [self statusIdFor:[self lastKnownStatus]];
    
    return self.remoteStatus != nil && remoteStatusId > knownStatusId;
}

-(NSUInteger)statusIdFor:(NSDictionary*)dict{
    NSUInteger rv = 0;
    NSNumber * num = dict[@"status_id"];
    if( [num isKindOfClass:[NSNumber class]] ){
        rv = [num unsignedIntegerValue];
    }
    return rv;
}

-(NSUInteger)mostRecentStatusId{
    NSArray * statuses = [self statusSinceId:0];
    NSUInteger rv = 0;
    for (NSDictionary * one in statuses) {
        NSUInteger sid = [self statusIdFor:one];
        if( sid > rv){
            rv = sid;
        }
    }
    return rv;
}

-(NSDictionary*)lastKnownStatus{
    return self.knownStatuses.count == 0 ? nil : self.knownStatuses.lastObject;
}

-(NSArray<NSDictionary*>*)statusSinceId:(NSUInteger)statusId{
    NSMutableArray * rv = [NSMutableArray array];
    if( self.knownStatuses.count ){
        for (NSDictionary * one in self.knownStatuses) {
            if( [self statusIdFor:one] > statusId ){
                [rv addObject:one];
            }
        }
    }
    if( self.remoteStatus && [self statusIdFor:self.remoteStatus] > statusId){
        [rv addObject:self.remoteStatus];
    }
    return rv;
}

-(NSArray<NSDictionary*>*)messagesSinceId:(NSUInteger)statusId{
    NSMutableArray * rv = [NSMutableArray array];
    
    NSMutableDictionary * remember = [NSMutableDictionary dictionary];

    if( self.knownStatuses==nil){
        self.knownStatuses = @[];
    }
    
    NSArray * lookat = self.remoteStatus ? [self.knownStatuses arrayByAddingObject:self.remoteStatus] : self.knownStatuses;

    if( lookat.count ){
        for (NSDictionary * one in lookat) {
            if( [self statusIdFor:one] > statusId ){
                NSArray * messages = one[@"messages"];
                if( [messages isKindOfClass:[NSArray class]]){
                    for (NSDictionary * message in messages) {
                        NSUInteger messageId = [self statusIdFor:message];
                        if( messageId > statusId){
                            if( remember[@(messageId)] == nil){
                                [self statusIdFor:message];
                                remember[@(messageId)] = @1;
                                [rv addObject:message];
                            }
                        }
                    }
                }
            }
        }
    }
    return rv;
}

-(NSArray<NSDictionary*>*)recentMessagesSinceId:(NSUInteger)statusId withinDays:(NSUInteger)ndays{
    NSArray<NSDictionary*>*messages = [self messagesSinceId:statusId];
    NSMutableArray * rv = [NSMutableArray array];
    
    NSDate * threshold = [[NSDate date] dateByAddingTimeInterval:-(3600.*24.0*ndays)];
    
    for (NSDictionary * one in messages) {
        NSNumber * unixtime = one[@"unixtime"];
        if( [unixtime respondsToSelector:@selector(doubleValue)] ){
            NSDate * date = [NSDate dateWithTimeIntervalSince1970:unixtime.doubleValue];
            if( [date compare:threshold] == NSOrderedDescending){
                [rv addObject:one];
            }
        }
    }
    return rv;
}

-(NSString*)description{
    if( self.remoteStatus ){
        NSMutableString * msg = [NSMutableString stringWithFormat:@"status %@", self.remoteStatus[@"status"]];
        
        if( [self hasNewStatus] ){
            [msg appendString:@" NEW"];
        }
        
        if( [self.remoteStatus[@"messages"] isKindOfClass:[NSArray class]]){
            [msg appendFormat:@" messages %@", @([self.remoteStatus[@"messages"] count] ) ];
        }
        if( self.remoteStatus[@"error"]){
            [msg appendFormat:@" error %@", self.remoteStatus[@"error"] ];
        }
        
        return [NSString stringWithFormat:@"<%@: %@ >", NSStringFromClass([self class]), msg];
    }else{
        return [NSString stringWithFormat:@"<%@: status pending>", NSStringFromClass([self class])];
    }
}


-(void)check:(GCConnectStatsStatusCallBack) cb{
    self.callback = cb;
    
    NSString * statusURL = @"https://connectstats.app/prod/api/status/app";
#if TARGET_IPHONE_SIMULATOR
    statusURL = @"https://localhost.ro-z.me/prod/api/status/app";
#endif
    
    self.messagesTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:statusURL] completionHandler:^(NSData * data, NSURLResponse*response, NSError * error ){
        
        NSHTTPURLResponse * httpResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpResponse = (NSHTTPURLResponse*)response;
        }
        
        if( error ){
            self.remoteStatus = @{ @"status" : @0, @"error": [error description]};
        }else if( httpResponse.statusCode == 200){
            NSError * parsingError = nil;
            NSDictionary * rv = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parsingError];
            if( rv == nil ){
                self.remoteStatus = @{ @"status" : @0, @"error": [parsingError localizedDescription]};
            }else if( [rv isKindOfClass:[NSDictionary class]]){
                self.remoteStatus = rv;
            }else{
                self.remoteStatus = @{ @"status" : @0, @"error": [NSString stringWithFormat:@"Invalid type from json, expected dict"]};
            }
        }else{
            self.remoteStatus = @{ @"status" : @0, @"error": [NSString stringWithFormat:@"Request failed with code %@", @(httpResponse.statusCode)]};
        }
        
        if( [self hasNewStatus] ){
            RZLog(RZLogInfo, @"New Status saved" );
            [self saveLocalStatus];
        }
        if( self.callback ){
            self.callback(self);
        }
    }];
    self.remoteStatus = nil;
    [self.messagesTask resume];
}

@end
