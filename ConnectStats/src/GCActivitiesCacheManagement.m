//  MIT Licence
//
//  Created on 12/11/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCActivitiesCacheManagement.h"

@implementation GCActivitiesCacheFileInfo
@synthesize filename,size,modified,activities;
-(void)dealloc{
    [filename release];
    [modified release];
    [super dealloc];
}
-(NSString*)formattedSize{
    if (size < 1024*1024) {
        return [NSString stringWithFormat:@"%.0f Kb",size/1024.];
    }else{
        return [NSString stringWithFormat:@"%.0f Mb",size/1024./1024.];
    }
}
@end

@implementation GCActivitiesCacheManagement
@synthesize cacheFiles,sizes;

-(GCActivitiesCacheManagement*)init{
    self = [super init];
    if (self) {
        sizes = calloc(gcCacheFileEnd, sizeof(double));
        [self analyze];
    }
    return self;
}

-(void)dealloc{
    [cacheFiles release];
    free(sizes);
    [super dealloc];
}

+(NSArray*)typeNames{
    return @[ @"Activities Database",
              @"Tennis Database",
              @"Track Database",
              @"Calculated Data",
              @"Json Files",
              @"TCX Files",
              @"Html Files",
              @"Kmz Files",
              @"Health",
              @"Other Files"];
}

+(NSArray*)errorFiles{
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];
    NSError * e;
    NSArray * files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&e];
    if(!files){
        RZLog(RZLogError, @"Failed to read %@. %@", documentsDirectory, e.localizedDescription);
        return @[];
    }
    NSMutableArray * results = [NSMutableArray arrayWithCapacity:10];
    for (NSString * file in files) {
        if ([file hasPrefix:@"error_"]) {
            [results addObject:file];
        }
    }
    return [NSArray arrayWithArray:results];
}

+(NSArray*)crashFiles{
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];
    NSError * e;
    NSArray * files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&e];
    if(!files){
        RZLog(RZLogError, @"Failed to read %@. %@", documentsDirectory, e.localizedDescription);
        return @[];
    }

    NSMutableArray * results = [NSMutableArray arrayWithCapacity:10];
    for (NSString * file in files) {
        if ([file hasSuffix:@"plcrash"]) {
            [results addObject:file];
        }
    }
    return [NSArray arrayWithArray:results];
}

-(NSString*)documentDirectory{
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];

    if (self.useBundlePath) {
        return [NSBundle mainBundle].resourcePath;
    }else{
        return documentsDirectory;
    }
}

-(void)analyze{
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSString	*	documentsDirectory	= [self documentDirectory];
    NSError * e;
    NSArray * files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&e];
    if(!files){
        RZLog(RZLogError, @"Failed to read %@. %@", documentsDirectory, e.localizedDescription);
    }

    NSMutableArray * results = [NSMutableArray arrayWithCapacity:gcCacheFileEnd];
    for (NSUInteger i = 0; i<gcCacheFileEnd; i++) {
        [results addObject:[NSMutableArray arrayWithCapacity:10]];
        sizes[i]=0.;
    }

    for (NSString * file in files) {
        GCActivitiesCacheFileInfo * info = [[GCActivitiesCacheFileInfo alloc] init];

        gcCacheFile type;
        if ([file hasPrefix:@"activities"] && [file hasSuffix:@".db"]) {
            type = gcCacheFileActivityDb;
        }else if([file hasPrefix:@"tennis_activities"] && [file hasSuffix:@".db"]){
            type = gcCacheFileTennisDb;
        }else if([file hasPrefix:@"track_"] && [file hasSuffix:@".db"]){
            type = gcCacheFileTrackDb;
        }else if ([file hasPrefix:@"derived_"]){
            type = gcCacheFileDerivedData;
        }else if ([file hasSuffix:@"json"]){
            type = gcCacheFileJson;
        }else if ([file hasSuffix:@"tcx"]){
            type = gcCacheFileTcx;
        }else if ([file hasSuffix:@"kmz"]){
            type = gcCacheFileKmz;
        }else if ([file hasSuffix:@"html"]){
            type = gcCacheFileHtml;
        }else if ([file hasSuffix:@".data"]){
            type = gcCacheFileHealth;
        }else{
            type=gcCacheFileOther;
        }
        NSDictionary * att = [fileManager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:file] error:&e ];
        info.modified = att[NSFileModificationDate];
        info.size = [att[NSFileSize] doubleValue];
        info.filename = file;
        sizes[type]+=info.size;

        if (type == gcCacheFileActivityDb) {
            FMDatabase * db = [FMDatabase databaseWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file]];
            [db open];
            info.activities = [db intForQuery:@"SELECT count(*) from gc_activities"];
            [db close];
        }else if (type == gcCacheFileTennisDb){
            FMDatabase * db = [FMDatabase databaseWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file]];
            [db open];
            info.activities = [db intForQuery:@"SELECT count(*) from babolat_sessions"];
            [db close];

        }
        [results[type] addObject:info];

        [info release];
    }
    self.cacheFiles = [NSArray arrayWithArray:results];
    //[self printSummary];
}

-(void)cleanupFiles:(gcCacheFile)type{
    if (type!=gcCacheFileActivityDb) {
        [self analyze];
        if (type < cacheFiles.count) {
            NSArray * array = cacheFiles[type];
            for (GCActivitiesCacheFileInfo * info in array) {
                if (![info.filename hasSuffix:@"plist"]) {
                    [RZFileOrganizer removeEditableFile:info.filename];
                }
            }
        }
    }
}

-(void)printSummary{
    NSArray * typeNames = [GCActivitiesCacheManagement typeNames];
    for (NSUInteger i=0; i<gcCacheFileEnd; i++) {
        RZLog(RZLogInfo,@"Type: %@ Size=%.0fkb count=%d", typeNames[i], sizes[i]/1024.,(int)[cacheFiles[i] count]);
        if (i==gcCacheFileActivityDb){
            NSArray * array = cacheFiles[gcCacheFileActivityDb];
            for(NSUInteger j=0;j<array.count;j++){
                GCActivitiesCacheFileInfo * info = array[j];
                RZLog(RZLogInfo,@"  db: %@ %d activities, %.0fkb", info.filename, info.activities, info.size/1024. );
            }
        }
    }
}
@end
