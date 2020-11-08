//  MIT Licence
//
//  Created on 25/07/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCViewIcons.h"
#import "GCViewConfig.h"

static NSArray * _navDefs = nil;
static NSArray * _tabDefs = nil;
static NSArray * _cellDefs = nil;

NSArray*cellIconDefs(){
    if (!_cellDefs) {
        _cellDefs = @[
                      @[ @"910-graph" ],  //    gcIconCellLineChart,
                      @[ @"1040-checkmark"],                //gcIconCellCheckmark,
                      @[ @"907-plus-rounded-square"],       //gcIconCellRoundedPlus,
                      @[ @"977-checkbox"],                   //gcIconCellCheckbox,
                      @[ @"731-cloud-download"],            //gcIconCellCloudDownload

                      ];
        [_cellDefs retain];
    }
    return _cellDefs;
}

NSArray*tabBarIconDefs(){
    if (!_tabDefs) {
        _tabDefs = @[
                     @[ @"851-calendar"],
                     @[ @"852-map" ],
                     @[ @"858-line-chart"],
                     @[ @"742-wrench"],
                     @[ @"755-filing-cabinet"],
                     @[ @"StatsiPad"],
                     @[ @"day-icon"]
                     ];
        [_tabDefs retain];
    }
    return _tabDefs;
}

NSArray*navigationIconDefs(){
    if (!_navDefs) {
        _navDefs = @[
                     @[@"789-map-location"],       //gcIconNavMarker showLap in map views
                     @[@"747-tag"],                //gcIconNavTags
                     @[@"751-eye"],                //gcIconNavEye
                     @[@"702-share"],              //gcIconNavAction
                     @[@"759-refresh-2"],          //gcIconNavRedo
                     @[@"968-sliders"],            //gcIconNavSliders (config sliders)
                     @[@"765-arrow-left"],         //gcIconNavBack
                     @[@"766-arrow-right"],        //gcIconNavForward
                     @[@"740-gear"],               //gcIconNavGear
                     @[@"851-calendar"],
                     @[@"1067-enter-fullscreen"],
                     @[@"1068-exit-fullscreen"],
                     @[@"715-globe"],
                     @[@"1099-list-1"],            //gcIconNavDetails
                     @[@"sigma"],                   //gcIconNavAggregated
                     @[@"cal1w"],
                     @[@"cal1m"],
                     @[@"cal3m"],
                     @[@"cal6m"],
                     @[@"cal1y"],                 //gcIconNavYearly
                     @[@"798-filter"],
                     @[@"798-filter-selected"],
                     ];
        [_navDefs retain];
    }
    return _navDefs;
}

NSString * imageName(NSString * name, NSString*suffix, NSString*bundle){
    if (bundle) {
        return [NSString stringWithFormat:@"%@%@%@.bundle/%@", bundle,suffix?:@"",@"-ios7",name];
    }else{
        if(suffix){
            return [name stringByAppendingString:suffix];
        }else{
            return name;
        }
    }
}

UIImage*imageNamedIn(NSArray*defs,NSUInteger idx,NSString*suffix,NSString*bundle){
    UIImage * rv = nil;

    if (idx < defs.count) {
        NSArray * names = defs[idx];
        if(  names.count > 0){
            rv = [UIImage imageNamed:imageName(names[0], suffix, bundle)];
        }
    }
    return rv;

}

@implementation GCViewIcons

+(UIImage*)tabBarIconFor:(gcIconTab)name{
    return imageNamedIn(tabBarIconDefs(), name, nil,nil);
}


+(UIImage*)navigationIconFor:(gcIconNav)name{
    return imageNamedIn(navigationIconDefs(), name,nil,nil);
}

+(UIImage*)activityTypeColoredIconFor:(NSString*)activityType{
    if(activityType == nil){
        return nil;
    }

    UIImage * rv = [UIImage imageNamed:activityType];

    return rv;
}

+(UIImage*)activityTypeDisabledIconFor:(NSString*)activityType{
    UIImage * icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@", activityType]];
    if( icon == nil){
        return nil;
    }
    
    UIImageView * imgView = RZReturnAutorelease([[UIImageView alloc] initWithImage:icon]);
    
    imgView.image = [imgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imgView setTintColor:[GCViewConfig defaultColor:gcSkinDefaultColorSecondaryText]];
    
    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, imgView.isOpaque, 0.0);
    [imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * rv = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return rv;
}

+(UIImage*)activityTypeDynamicIconFor:(NSString*)activityType{
    UIImage * icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@", activityType]];
    if( icon == nil){
        return nil;
    }
    
    UIImageView * imgView = RZReturnAutorelease([[UIImageView alloc] initWithImage:icon]);
    
    if( [GCViewConfig roundedActivityIcons]){
        imgView.backgroundColor = [GCViewConfig cellBackgroundDarkerForActivity:activityType];
        imgView.layer.cornerRadius = 5;
        imgView.layer.mask.masksToBounds = YES;
        imgView.layer.borderWidth = 0;
        imgView.image = [imgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imgView setTintColor:[GCViewConfig cellIconColorForActivity:activityType]];
    }else{
        imgView.image = [imgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imgView setTintColor:[GCViewConfig cellBackgroundDarkerForActivity:activityType]];
    }
    
    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, imgView.isOpaque, 0.0);
    [imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * rv = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return rv;
}

+(UIImage*)activityTypeBWIconFor:(NSString*)activityType{
    UIImage * rv = [UIImage imageNamed:[NSString stringWithFormat:@"%@", activityType]];
    return rv;

}

+(UIImage*)cellIconFor:(gcIconCell)name{
    UIImage * icon = imageNamedIn(cellIconDefs(), name, nil, nil);
    
    UIImageView * imgView = RZReturnAutorelease([[UIImageView alloc] initWithImage:icon]);
    imgView.backgroundColor = [UIColor clearColor];
    imgView.image = [imgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imgView setTintColor:[GCViewConfig colorForGraphElement:gcSkinGraphColorForeground]];
    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, imgView.isOpaque, 0.0);
    [imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * rv = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return rv;
}

+(UIImage*)categoryIconFor:(NSString*)category{
    static NSDictionary * defs = nil;
    if (!defs) {
        defs = @{@"heartrate":  @"748-heart", // 950-ekg.png
                 @"cadence":    @"metronome",
                 @"duration":   @"718-timer-1",
                 @"speed":      @"795-gauge",
                 @"pace":       @"917-speedometer",
                 @"power":      @"1093-lightning-bolt-2",
                 @"elevation":  @"879-mountains",
                 @"training":   @"flame",
                 @"temperature":@"959-thermometer",
                 @"health":     @"scale",
                 @"distance":   @"1061-golf-shot",
                 @"backhands":  @"backhand",
                 @"forehands":  @"forehand",
                 @"serves":     @"serve",
                 @"precision":  @"784-target",
                 };
        [defs retain];
    }
    NSString * filename = defs[category];
    if (filename) {
        return [UIImage imageNamed:filename];
    }
    return nil;
}
@end
