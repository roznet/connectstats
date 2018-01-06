//  MIT Licence
//
//  Created on 27/11/2014.
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

#import "TSReportOrganizer.h"
#import "TSSessionReport.h"
#import "TSSessionReportPivot.h"
#import "TSTennisFields.h"
#import "TSReport.h"

@interface TSReportOrganizer ()
@property (nonatomic,retain) NSArray * reports;
@end

@implementation TSReportOrganizer

+(TSReportOrganizer*)defaultOrganizer{
    TSReportOrganizer * rv = [[TSReportOrganizer alloc] init];
    if (rv) {
        rv.reports = [TSReportOrganizer buildDefaultReports];
    }
    return rv;
}

+(NSArray*)buildDefaultReports{
    NSMutableArray * rv = [NSMutableArray array];

    TSSessionReportPivot * one = nil;

    one = [[TSSessionReportPivot alloc] init];
    one.name = @"Points";
    one.rows = @[ kfRallyResult ];

    one.columns = @[kfWinner];
    one.collect = @[kfWinner];

    [rv addObject:one];

    one = [[TSSessionReportPivot alloc] init];
    one.name = @"Points by Score";
    one.rows = @[ kfScoreDifferential, kfRallyResult ];

    one.columns = @[kfWinner];
    one.collect = @[kfWinner];

    [rv addObject:one];

    one = [[TSSessionReportPivot alloc] init];
    one.name = @"Points by Criticality";
    one.rows = @[ kfScoreCriticality, kfRallyResult ];

    one.columns = @[kfWinner];
    one.collect = @[kfWinner];

    [rv addObject:one];

    one = [[TSSessionReportPivot alloc] init];
    one.name = @"Points by length";
    one.rows = @[ kfRallyLength, kfRallyResult];
    one.columns = @[kfWinner];
    one.collect = @[kfWinner];

    [rv addObject:one];

    one = [[TSSessionReportPivot alloc] init];
    one.name = @"Points by Set";
    one.rows = @[ kfSetNumber, kfRallyResult];
    one.columns = @[kfWinner];
    one.collect = @[kfWinner];

    [rv addObject:one];

    one = [[TSSessionReportPivot alloc] init];
    one.granularity = tsReportByShot;
    one.name = @"Shot Analysis";
    one.rows = @[ kfShotPlayer, kfShotAnalysis];
    one.columns = @[kfWinner];
    one.collect = @[kfShotType];

    [rv addObject:one];


    return rv;
}

-(NSUInteger)count{
    return  self.reports.count;
}
-(TSSessionReport*)reportAtIndex:(NSUInteger)idx{
    return idx <self.count ? self.reports[idx] : nil;
}

-(void)writeSummaryForSession:(TSTennisSession*)session toDirectory:(NSString*)dirpath{
    TSReport * report = [TSReport report];

    for (TSSessionReport * one in self.reports) {
        [one addElementToReport:report forSession:session];
    }

    [RZFileOrganizer ensureWriteableFilePath:dirpath];
    NSString * file = [RZFileOrganizer writeableFilePath:[dirpath stringByAppendingPathComponent:@"index.html"]];
    NSError * error = nil;
    [[report html] writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        RZLog(RZLogError, @"Failed to write %@", file);
    }else{
        RZLog(RZLogInfo, @"Wrote report %@", dirpath);
    }
}

@end
