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

@interface GCWebImagesRequests ()
@property (nonatomic,retain) GCActivity * activity;
@property (nonatomic,retain) GCMapViewController * mapViewController;
@end
@implementation GCWebImagesRequests

+(GCWebImagesRequests*)imagesRequestFor:(GCActivity*)act{
    GCWebImagesRequests * rv = RZReturnAutorelease([[GCWebImagesRequests alloc] init]);
    rv.activity = act;
    return rv;
}

-(void)dealloc{
    [_activity release];
    [_mapViewController release];
    [super dealloc];
}

-(NSString*)debugDescription{
    return [NSString stringWithFormat:@"<%@: Disabled>", NSStringFromClass([self class])];
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
    [self processGetMapImage];
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
                    NSData * data = UIImagePNGRepresentation(img);
                    NSString * imgfn = [NSString stringWithFormat:@"activity_%@_map.png", self.activity.activityId ];
                    [data writeToFile:[RZFileOrganizer writeableFilePath:imgfn] atomically:YES];
                    RZLog(RZLogInfo, @"Wrote %@", imgfn);
                    
                    [self processDone];
                }];
            });
        });
    }else{
        [self processDone];
    }
}

@end
