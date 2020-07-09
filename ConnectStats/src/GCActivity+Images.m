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



#import "GCActivity+Images.h"
#import "GCAppGlobal.h"
#import "GCMapViewController.h"

@import Photos;

@implementation GCActivity (Images)

-(void)findImages{
    if( false ){
        dispatch_async([GCAppGlobal worker], ^(){
            PHFetchOptions * options = RZReturnAutorelease([[PHFetchOptions alloc] init]);
            options.predicate = [NSPredicate predicateWithFormat:@"creationDate > %@ AND creationDate < %@",self.startTime ,self.endTime];
            PHFetchResult<PHAsset*>* results = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
            NSMutableArray * identifiers = [NSMutableArray array];
            for (PHAsset*asset in results) {
                [identifiers addObject:asset.localIdentifier];
            }
            PHFetchResult * physicalAssets = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
            
            for( PHAsset * asset in physicalAssets){
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
            
        });
    }
}

@end
