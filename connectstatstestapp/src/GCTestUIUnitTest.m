//  MIT Licence
//
//  Created on 04/11/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "GCTestUIUnitTest.h"
@import RZExternalTestUtils;
#import "GCTestUISamples.h"
#import "GCAppGlobal.h"

@interface GCTestUIUnitTest ()
@property (nonatomic,retain) NSArray * cellDataSource;
@property (nonatomic,retain) NSArray * graphDataSource;
@property (nonatomic,assign) BOOL recordMode;
@end

@implementation GCTestUIUnitTest

-(void)dealloc{
    [_cellDataSource release];
    [_graphDataSource release];
    [super dealloc];
}

-(NSArray*)testDefinitions{
    return @[ @{TK_SEL:NSStringFromSelector(@selector(testSimpleGraph)),
                TK_DESC:@"Test SimpleGraph Snapshots",
                TK_SESS:@"UI SimpleGraph"},
              @{TK_SEL:NSStringFromSelector(@selector(testCellGrid)),
                TK_DESC:@"Test CellGrid Snapshots",
                TK_SESS:@"UI CellGrid"}
              ];
}

-(void)testSimpleGraph{
    [self startSession:@"UI SimpleGraph"];
    //Rebase on iPhone 12 Pro and iPhone 8 for two screen sizes
    self.recordMode = false;
    dispatch_sync(dispatch_get_main_queue(), ^(){
        [self checkSimpleGraphSnapshot];
    });
}

-(void)testCellGrid{
    [self startSession:@"UI CellGrid"];
    //Rebase on iPhone 12 Pro and iPhone 8 for two screen sizes
    self.recordMode = false;
    dispatch_sync(dispatch_get_main_queue(), ^(){
        [self checkGridCellSnapshot];
    });
}

-(void)buildGraphDataSource{
    GCTestUISamples * samples = [[GCTestUISamples alloc] init];
    self.graphDataSource = [samples dataSourceSamples];
    [samples release];
}


-(void)checkSimpleGraphSnapshot{
    dispatch_sync([GCAppGlobal worker],^(){
        [self buildGraphDataSource];
    });


    FBSnapshotTestController * snapshotTestController = [[FBSnapshotTestController alloc] initWithTestClass:[self class]];
    snapshotTestController.ksDiffScriptFilePath = [RZFileOrganizer writeableFilePath:@"ksdiff_graphs.ksh"];
    [[NSString stringWithFormat:@"# Started at %@\n", [NSDate date]] writeToFile:snapshotTestController.ksDiffScriptFilePath
                                                                      atomically:YES
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:nil];

    //REBASE
    snapshotTestController.recordMode = self.recordMode;
    NSString *envReferenceImageDirectory = [NSProcessInfo processInfo].environment[@"FB_REFERENCE_IMAGE_DIR"];

    snapshotTestController.referenceImagesDirectory = envReferenceImageDirectory;
    NSError * error = nil;

    BOOL someErrors = false;

    for (GCTestUISampleDataSourceHolder * holder in self.graphDataSource) {
        GCCellSimpleGraph * cell = [[GCCellSimpleGraph alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGraph"];
        cell.frame = CGRectMake(0., 0., 320., 150.);
        [cell setDataSource:holder.source andConfig:holder.source];
        BOOL success = [snapshotTestController compareSnapshotOfView:cell selector:@selector(checkSimpleGraphSnapshot)
                                                          identifier:holder.identifier error:&error];
        RZ_ASSERT(success, @"SimpleGraph Snapshot Matched: %@. %@", holder.identifier, error ?: @"(null error)");

        someErrors = someErrors || !success;
        [cell release];
    }
    if (someErrors) {
        RZLog(RZLogError, @"ksdiff cmd in %@", snapshotTestController.ksDiffScriptFilePath);
    }
    [snapshotTestController release];
    self.graphDataSource = nil;

    [self endSession:@"UI SimpleGraph"];
}

-(void)buildCellDataSource{
    @autoreleasepool {
        GCTestUISamples * samples = [[GCTestUISamples alloc] init];
        self.cellDataSource = [[samples gridCellSamples] arrayFlattened];
        [samples release];
    };
}

-(void)checkGridCellSnapshot{
    dispatch_sync([GCAppGlobal worker],^(){
        [self buildCellDataSource];
    });

    FBSnapshotTestController * snapshotTestController = [[FBSnapshotTestController alloc] initWithTestClass:[self class]];
    snapshotTestController.ksDiffScriptFilePath = [RZFileOrganizer writeableFilePath:@"ksdiff_cells.ksh"];
    [[NSString stringWithFormat:@"# Started at %@\n", [NSDate date]] writeToFile:snapshotTestController.ksDiffScriptFilePath
                                                                      atomically:YES
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:nil];
    //REBASE
    snapshotTestController.recordMode = self.recordMode;
    NSString *envReferenceImageDirectory = [NSProcessInfo processInfo].environment[@"FB_REFERENCE_IMAGE_DIR"];

    snapshotTestController.referenceImagesDirectory = envReferenceImageDirectory;
    NSError * error = nil;

    for (GCTestUISampleCellHolder * holder in self.cellDataSource) {
        UITableViewCell * cell = holder.cell;
        cell.frame = CGRectMake(0., 0., 320., holder.height);

        BOOL success = [snapshotTestController compareSnapshotOfView:cell selector:@selector(checkGridCellSnapshot)
                                                          identifier:holder.identifier error:&error];
        RZ_ASSERT(success, @"%@ Snapshot Matched: %@. %@", NSStringFromClass([holder class]), holder.identifier, error ?: @"(null error)");
    }
    [snapshotTestController release];
    self.cellDataSource = nil;

    [self endSession:@"UI CellGrid"];
}
@end
