//  MIT License
//
//  Created on 13/02/2018 for ConnectStatsXCTests
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "GCTestCase.h"
#import "GCTestsHelper.h"
#import "GCAppGlobal.h"
#import "ConnectStats-Swift.h"
@interface GCTestCase  ()
@property (nonatomic,retain) GCTestsHelper * helper;
@end

@implementation GCTestCase

-(void)dealloc{
    [_helper release];
    [super dealloc];
}

- (void)setUp
{
    if( self.helper == nil){
        self.helper = [GCTestsHelper helper];
    }else{
        [self.helper setUp];
    }
    
    [super setUp];
}

- (void)tearDown
{
    [self.helper tearDown];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(RZRegressionManager*)regressionManager{
    
    RZRegressionManager * manager = [RZRegressionManager managerForTestClass:[self class]
                                                               directoryName:@"ReferenceObjects"
                                                           referenceFilePath:[RZFileOrganizer bundleFilePath:@"ReferenceObjects" forClass:[self class]]];
    manager.recordMode = false;
    return manager;
}

-(GCActivitiesOrganizer*)createEmptyOrganizer:(NSString*)dbname{
    NSString * dbfp = [RZFileOrganizer writeableFilePath:dbname];
    [RZFileOrganizer removeEditableFile:dbname];
    FMDatabase * db = [FMDatabase databaseWithPath:dbfp];
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    [GCHealthOrganizer ensureDbStructure:db];
    [GCConnectStatsRequestRegisterNotifications ensureDbStructureWithDb:db];
    GCActivitiesOrganizer * organizer = [[[GCActivitiesOrganizer alloc] initTestModeWithDb:db] autorelease];
    GCHealthOrganizer * health = [[[GCHealthOrganizer alloc] initTestModeWithDb:db andThread:nil] autorelease];
    organizer.health = health;

    return organizer;
}

-(GCDerivedOrganizer*)createEmptyDerived:(NSString*)name{
    NSString * dbname = [NSString stringWithFormat:@"%@.db", name];
    [RZFileOrganizer removeEditableFile:dbname];
    FMDatabase * deriveddb = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:dbname]];
    [deriveddb open];
    [GCDerivedOrganizer ensureDbStructure:deriveddb];
    
    [[GCAppGlobal profile] configSet:CONFIG_ENABLE_DERIVED boolVal:false];
    GCDerivedOrganizer * derived = [[GCDerivedOrganizer alloc] initTestModeWithDb:deriveddb thread:nil andFilePrefix:name];
    return derived;
}

-(GCActivitiesOrganizer*)createTemporaryInMemoryOrganizer{
    FMDatabase * memDb = [FMDatabase databaseWithPath:nil];
    [memDb open];
    [GCActivitiesOrganizer ensureDbStructure:memDb];

    GCActivitiesOrganizer * rv = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:memDb]);
    return rv;
}

-(GCActivitiesOrganizer*)setupSampleState:(NSString*)name{
    [RZFileOrganizer createEditableCopyOfFile:name forClass:[self class]];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:name]];
    
    [db open];
    [GCActivitiesOrganizer ensureDbStructure:db];
    GCActivitiesOrganizer * rv = RZReturnAutorelease([[GCActivitiesOrganizer alloc] initTestModeWithDb:db]);
    
    return rv;
}


-(void)setupForTest:(GCActivity*)act{
    act.settings.worker = nil;
}

@end
