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
@interface GCActivitiesCacheFileInfo ()
-(void)updateWithFile:(NSString*)filePath;
@end

@implementation GCActivitiesCacheFileInfo

+(NSArray<NSString*>*)typeNames{
    return @[ @"Activities Database",
              @"Tennis Database",
              @"Track Database",
              @"FIT Files",
              @"Calculated Data",
              @"Json Files",
              @"TCX Files",
              @"Html Files",
              @"Kmz Files",
              @"Health",
              @"Other Files"];
}

+(GCActivitiesCacheFileInfo*)cacheFileInfoForType:(gcCacheFile)type{
    GCActivitiesCacheFileInfo * rv = RZReturnAutorelease([[GCActivitiesCacheFileInfo alloc] init]);
    if( rv ){
        rv.type = type;
    }
    return rv;
}

-(void)dealloc{
    [_earliest release];
    [_latest release];
    [super dealloc];
}
-(NSString*)formattedSize{
    if (self.totalSize < 1024*1024) {
        return [NSString stringWithFormat:@"%.0f Kb",self.totalSize/1024.];
    }else{
        return [NSString stringWithFormat:@"%.0f Mb",self.totalSize/1024./1024.];
    }
}
-(NSString*)typeKey{
    return [GCActivitiesCacheFileInfo typeNames][self.type];
}
+(gcCacheFile)typeForFile:(NSString*)file{
    gcCacheFile type;
    if ([file hasPrefix:@"activities"] && [file hasSuffix:@".db"]) {
        type = gcCacheFileActivityDb;
    }else if([file hasPrefix:@"tennis_activities"] && [file hasSuffix:@".db"]){
        type = gcCacheFileTennisDb;
    }else if([file hasPrefix:@"track_"] && [file hasSuffix:@".db"]){
        type = gcCacheFileTrackDb;
    }else if ([file hasPrefix:@"derived_"]){
        type = gcCacheFileDerivedData;
    }else if ([file hasSuffix:@"fit"]){
        type = gcCacheFileFit;
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
    return type;
}

-(void)updateWithFile:(NSString*)filePath{
    NSError * e = nil;
    NSDictionary * att = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&e ];
    
    NSDate * modified = att[NSFileModificationDate];
    if( self.earliest == nil || [self.earliest compare:modified] == NSOrderedDescending){
        self.earliest = modified;
    }
    if( self.latest == nil || [self.latest compare:modified] != NSOrderedDescending){
        self.latest = modified;
    }
    
    self.totalSize += [att[NSFileSize] doubleValue];
    self.filesCount += 1;

    if (self.type == gcCacheFileActivityDb) {
        FMDatabase * db = [FMDatabase databaseWithPath:filePath];
        [db open];
        self.activitiesCount += [db intForQuery:@"SELECT count(*) from gc_activities"];
        [db close];
    }else if (self.type == gcCacheFileTennisDb){
        FMDatabase * db = [FMDatabase databaseWithPath:filePath];
        [db open];
        self.activitiesCount += [db intForQuery:@"SELECT count(*) from babolat_sessions"];
        [db close];
    }
}

-(NSString*)description{
    NSString * typeString = [GCActivitiesCacheFileInfo typeNames][self.type];
    NSString * info = @"No Files";
    if( self.filesCount > 0){
        NSMutableArray<NSString*>*infos = [NSMutableArray arrayWithArray:@[
            [NSString stringWithFormat:@"%lu files", self.filesCount],
            [self formattedSize],
        ]];
        if( self.activitiesCount > 0){
            [infos addObject:[NSString stringWithFormat:@"%lu activities", self.activitiesCount]];
        }
        if( self.earliest ){
            [infos addObject:[self.earliest dateShortFormat]];
        }
        info = [infos componentsJoinedByString:@", "];
    }
    return [NSString stringWithFormat:@"<%@:%@ %@>", NSStringFromClass([self class]), typeString, info];
}

@end

@interface GCActivitiesCacheManagement ()
@property (nonatomic,retain) NSDictionary<NSString*,GCActivitiesCacheFileInfo*> * cacheFiles;


@end

@implementation GCActivitiesCacheManagement

-(GCActivitiesCacheManagement*)init{
    self = [super init];
    if (self) {
        [self analyze];
    }
    return self;
}

-(void)dealloc{
    [_cacheFiles release];
    [super dealloc];
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

-(NSArray<NSString*>*)fileNamesForType:(gcCacheFile)type{
    NSError * e;
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self documentDirectory] error:&e];
    if(!files){
        RZLog(RZLogError, @"Failed to read %@. %@", [self documentDirectory], e.localizedDescription);
    }

    NSMutableArray*results = [NSMutableArray array];
    
    for (NSString * file in files) {
        gcCacheFile filetype = [GCActivitiesCacheFileInfo typeForFile:file];
        if( filetype == type ){
            [results addObject:file];
        }
    }
    return results;
}

-(void)analyze{
    NSString * documentsDirectory = [self documentDirectory];
    NSError * e;
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&e];
    if(!files){
        RZLog(RZLogError, @"Failed to read %@. %@", documentsDirectory, e.localizedDescription);
    }

    NSMutableDictionary*results = [NSMutableDictionary dictionary];
    NSArray * types = [GCActivitiesCacheFileInfo typeNames];
    
    for (NSString * file in files) {
        gcCacheFile type = [GCActivitiesCacheFileInfo typeForFile:file];

        NSString * typeKey = type < types.count ? types[type] : nil;
        NSString * filePath = [documentsDirectory stringByAppendingPathComponent:file];
        
        if( typeKey ){
            GCActivitiesCacheFileInfo * info = results[typeKey];
            if( info == nil){
                info = [GCActivitiesCacheFileInfo cacheFileInfoForType:type];
                results[typeKey] = info;
            }
            
            [info updateWithFile:filePath];
        }
    }
    self.cacheFiles = results;
    [self printSummary];
}

-(NSArray<GCActivitiesCacheFileInfo*>*)infos{
    return [self.cacheFiles.allValues sortedArrayUsingComparator:^(GCActivitiesCacheFileInfo*i1, GCActivitiesCacheFileInfo*i2){
        return (i1.totalSize > i2.totalSize) ? NSOrderedAscending : ( (i1.totalSize<i2.totalSize) ? NSOrderedDescending : NSOrderedSame );
    }];
}
-(void)cleanupFiles:(gcCacheFile)type{
    if (type!=gcCacheFileActivityDb) {
        NSFileManager    *    fileManager            = [NSFileManager defaultManager];
        NSString    *    documentsDirectory    = [self documentDirectory];
        NSError * e;
        NSArray * files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&e];
        if(!files){
            RZLog(RZLogError, @"Failed to read %@. %@", documentsDirectory, e.localizedDescription);
        }
        NSMutableArray * toDelete = [NSMutableArray array];
        for (NSString * file in files) {
            gcCacheFile thisType = [GCActivitiesCacheFileInfo typeForFile:file];
            if( thisType == type ){
                [toDelete addObject:file];
            }
        }
        for (NSString * file in toDelete) {
            if (![file hasSuffix:@"plist"]) {
                [RZFileOrganizer removeEditableFile:file];
            }
        }
        RZLog(RZLogInfo, @"Deleted %@ files of type %@", @(toDelete.count), [GCActivitiesCacheFileInfo typeNames][type]);
    }
}

-(void)printSummary{
    for (NSString * type in self.cacheFiles) {
        GCActivitiesCacheFileInfo * info = self.cacheFiles[type];
        RZLog(RZLogInfo,@"Cache: %@", info);
    }
}
@end
