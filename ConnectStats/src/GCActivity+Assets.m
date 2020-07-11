//  MIT License
//
//  Created on 07/07/2020 for ConnectStats
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



#import "GCActivity+Assets.h"
#import "GCAppGlobal.h"
#import "GCMapViewController.h"

@implementation GCActivity (Assets)

#pragma mark - asset Info management

-(NSString*)assetInfoJsonFileName{
    return [NSString stringWithFormat:@"assets_%@.json",self.activityId];
}

-(void)saveAssetInfo{
    if( self.assetsInfo ){
        NSError * error = nil;
        NSData * data = [NSJSONSerialization dataWithJSONObject:self.assetsInfo options:NSJSONWritingSortedKeys error:&error];
        if( data ){
            [data writeToFile:[RZFileOrganizer writeableFilePath:[self assetInfoJsonFileName]] atomically:TRUE];
        }else{
            RZLog(RZLogError, @"Failed to write asset info to %@. %@", [self assetInfoJsonFileName], error);
        }
    }
}
-(void)loadAssetInfo{
    NSString * fp = [RZFileOrganizer writeableFilePathIfExists:[self assetInfoJsonFileName]];
    if( fp ){
        NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer writeableFilePath:[self assetInfoJsonFileName]]];
        NSError * error = nil;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if( [dict isKindOfClass:[NSDictionary class]]){
            self.assetsInfo = dict;
        }else{
            RZLog(RZLogError, @"Invalid Asset File %@, %@", [self assetInfoJsonFileName], error );
        }
    }else{
        self.assetsInfo = [NSDictionary dictionary];
    }
}

-(BOOL)hasAssets{
    return self.hasPhotos || self.hasMapSnapshot;
}

#pragma mark - assets Photos Management

-(BOOL)hasPhotos{
    return self.assetsPhotosLocalIdentifiers.count > 0 ;
}

-(NSArray<NSString*>*)assetsPhotosLocalIdentifiers{
    NSArray * rv = self.assetsInfo[@"PHAssets.localIdentifier"];
    if( [rv isKindOfClass:[NSArray class]]){
        return rv;
    }
    return @[];
}

-(void)setAssetsPhotosLocalIdentifiers:(NSArray<NSString *> *)assetsPhotosLocalIdentifiers{
    NSMutableDictionary * dict =  [NSMutableDictionary dictionaryWithDictionary:self.assetsInfo ?: @{}];
    dict[@"PHAssets.localIdentifier"] = assetsPhotosLocalIdentifiers;
    self.assetsInfo = dict;
}

-(BOOL)updateAssetInfoForImageAssets{
    PHFetchResult * results = [self findImageAssetsDuringActivity];
    
    NSMutableArray * identifiers = [NSMutableArray array];
    for (PHAsset * assets in results) {
        [identifiers addObject:assets.localIdentifier];
    }
    self.assetsPhotosLocalIdentifiers = identifiers;
    return identifiers.count > 0;
}

-(PHFetchResult*)findImageAssetsDuringActivity{
    PHFetchOptions * options = RZReturnAutorelease([[PHFetchOptions alloc] init]);
    
    NSTimeInterval fiveMinutes = 5.*60.;
    options.predicate = [NSPredicate predicateWithFormat:@"creationDate > %@ AND creationDate < %@",
                         [self.startTime dateByAddingTimeInterval:-1 * fiveMinutes],
                         [self.endTime dateByAddingTimeInterval:fiveMinutes]];
    PHFetchResult<PHAsset*>* results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    NSMutableArray * identifiers = [NSMutableArray array];
    for (PHAsset*asset in results) {
        [identifiers addObject:asset.localIdentifier];
    }
    PHFetchResult * physicalAssets = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
    return physicalAssets;
}

#pragma mark - Map Snapshot management

-(NSString*)assetsMapSnapshotFileName{
    return [NSString stringWithFormat:@"assets_%@_map.png", self.activityId];
}

-(UIImage *)assetsMapSnapshot{
    UIImage * rv = nil;
    NSString * fp = [RZFileOrganizer writeableFilePathIfExists:self.assetsMapSnapshotFileName];
    if( fp ){
        NSData * data = [NSData dataWithContentsOfFile:fp];
        rv = [UIImage imageWithData:data];
    }
    return rv;
}

-(void)setAssetsMapSnapshot:(UIImage *)assetsMapSnapshot{
    if( assetsMapSnapshot == nil){
        if( self.assetsInfo[@"snapshot.map"]){
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.assetsInfo ?: @{}];
            [dict removeObjectForKey:@"snapshot.map"];
            [RZFileOrganizer removeEditableFile:self.assetsMapSnapshotFileName];
            self.assetsInfo = dict;
        }
    }else{
        NSData * data = UIImagePNGRepresentation(assetsMapSnapshot);
        if( [data writeToFile:[RZFileOrganizer writeableFilePath:self.assetsMapSnapshotFileName] atomically:YES] ){
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.assetsInfo ?: @{}];
            dict[ @"snapshot.map" ] = self.assetsMapSnapshotFileName;
            self.assetsInfo = dict;
        }
    }
}

-(BOOL)hasMapSnapshot{
    return self.assetsInfo[ @"snapshot.map" ] != nil;
}




@end
