//  MIT License
//
//  Created on 09/07/2020 for ConnectStats
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



#import "GCWebImagesRequests.h"
#import "GCActivity.h"
#import "GCAppGlobal.h"
#import "GCMapViewController.h"
#import "GCActivity+Assets.h"

@import Photos;

static BOOL gcDownloadPhotos = false;

@interface GCWebImagesRequests ()
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,retain) GCMapViewController * mapViewController;
@property (nonatomic,retain) PHFetchResult*foundAssets;
@property (nonatomic,assign) CGSize size;
@end

@implementation GCWebImagesRequests

+(GCWebImagesRequests*)imagesRequestFor:(GCActivity*)act{
    GCWebImagesRequests * rv = RZReturnAutorelease([[GCWebImagesRequests alloc] init]);
    rv.activity = act;
    rv.size = CGSizeMake(250.0, 250.);
    return rv;
}

-(void)dealloc{
    [_activity release];
    [_mapViewController release];
    [super dealloc];
}

-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), self.activity];
}

-(NSString*)description{
    return @"Image Requests";
}
-(NSString*)url{
    return nil;
}
-(NSDictionary*)postData{
    return nil;
}
-(NSDictionary*)deleteData{
    return nil;
}
-(NSData*)fileData{
    return nil;
}
-(NSString*)fileName{
    return nil;
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    self.delegate = delegate;
    if( gcDownloadPhotos ){
        if( [self.activity updateAssetInfoForImageAssets] ){
            [self.activity saveAssetInfo];
        }
        [self processGetMapImage];
    }else{
        [self processDone];
    }
}
    

-(void)processGetMapImage{
    self.status = GCWebStatusOK;
    GCActivity * act = self.activity;
    if( act.validCoordinate ){
        dispatch_async([GCAppGlobal worker], ^(){
            [act trackpoints];
            dispatch_async(dispatch_get_main_queue(), ^(){
                self.mapViewController = RZReturnAutorelease([[GCMapViewController alloc] initWithNibName:nil bundle:nil]);
                [self.mapViewController mapImageForActivity:act size:CGSizeMake( 150., 150.) completion:^(UIImage * img){
                    self.activity.assetsMapSnapshot = img;
                    RZLog(RZLogInfo, @"Saved map snapshot %@", self.activity.assetsMapSnapshotFileName);
                    [self.activity saveAssetInfo];
                    [self processDone];
                }];
            });
        });
    }else{
        [self processDone];
    }
}

-(void)findPhotoAssets{
    PHFetchOptions * options = RZReturnAutorelease([[PHFetchOptions alloc] init]);
    
    NSTimeInterval fiveMinutes = 5.*60.;
    options.predicate = [NSPredicate predicateWithFormat:@"creationDate > %@ AND creationDate < %@",
                         [self.activity.startTime dateByAddingTimeInterval:-1 * fiveMinutes],
                         [self.activity.endTime dateByAddingTimeInterval:fiveMinutes]];
    PHFetchResult<PHAsset*>* results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    NSMutableArray * identifiers = [NSMutableArray array];
    for (PHAsset*asset in results) {
        [identifiers addObject:asset.localIdentifier];
    }
    PHFetchResult * physicalAssets = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
    self.foundAssets = physicalAssets;
}

-(void)grabPhotoAssetSnapshot:(PHAsset*)asset{
    PHImageRequestOptions * imageOptions = RZReturnAutorelease([[PHImageRequestOptions alloc] init]);
    imageOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    imageOptions.synchronous = true;
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset
                       targetSize:CGSizeMake(150., 150.)
                      contentMode:PHImageContentModeDefault
                          options:imageOptions
                    resultHandler:^void(UIImage *image, NSDictionary *info) {
        @autoreleasepool {
            
            if(image!=nil){
                NSLog(@"%@ %@", asset.localIdentifier, image);
            }
        }
    }];
}

@end
