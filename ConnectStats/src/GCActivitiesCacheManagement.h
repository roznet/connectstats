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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, gcCacheFile){
    gcCacheFileActivityDb,
    gcCacheFileTennisDb,
    gcCacheFileTrackDb,
    gcCacheFileFit,
    gcCacheFileDerivedData,
    gcCacheFileJson,
    gcCacheFileTcx,
    gcCacheFileHtml,
    gcCacheFileKmz,
    gcCacheFileHealth,
    gcCacheFileOther,
    gcCacheFileEnd
};

@interface GCActivitiesCacheFileInfo : NSObject

@property (nonatomic,assign) gcCacheFile type;
@property (nonatomic,retain) NSDate * latest;
@property (nonatomic,retain) NSDate * earliest;
@property (nonatomic,assign) double totalSize;
@property (nonatomic,assign) NSUInteger activitiesCount;
@property (nonatomic,assign) NSUInteger filesCount;
@property (nonatomic,readonly) NSString * typeKey;

+(GCActivitiesCacheFileInfo*)cacheFileInfoForType:(gcCacheFile)type;
+(NSArray<NSString*>*)typeNames;

@end


@interface GCActivitiesCacheManagement : NSObject

@property (nonatomic,assign) BOOL useBundlePath;



-(void)analyze;

+(NSArray*)errorFiles;
+(NSArray*)crashFiles;
-(void)cleanupFiles:(gcCacheFile)type;
-(NSArray<GCActivitiesCacheFileInfo*>*)infos;

@end
