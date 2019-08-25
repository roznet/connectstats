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

#define IDX_DEFAULT 0
#define IDX_IOS7    1

NSArray*cellIconDefs(){
    if (!_cellDefs) {
        _cellDefs = @[
                      @[ @"16-line-chart", @"910-graph" ],  //    gcIconCellLineChart,
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
                     @[ @"83-calendar",     @"851-calendar"],
                     @[ @"103-map",         @"852-map" ],
                     @[ @"122-stats",       @"858-line-chart"],
                     @[ @"157-wrench",      @"742-wrench"],
                     @[ @"255-box",         @"755-filing-cabinet"],
                     @[ @"StatsiPad",       @"StatsiPad"],
                     @[ @"day-icon",       @"day-icon"]
                     ];
        [_tabDefs retain];
    }
    return _tabDefs;
}

NSArray*navigationIconDefs(){
    if (!_navDefs) {
        _navDefs = @[
                     @[@"07-map-marker",    @"789-map-location"],       //gcIconNavMarker showLap in map views
                     @[@"15-tags",          @"747-tag"],                //gcIconNavTags
                     @[@"12-eye",           @"751-eye"],                //gcIconNavEye
                     @[@"211-action",       @"702-share"],              //gcIconNavAction
                     @[@"02-redo",          @"759-refresh-2"],          //gcIconNavRedo
                     @[@"106-sliders",      @"968-sliders"],            //gcIconNavSliders (config sliders)
                     @[@"39-back",          @"765-arrow-left"],         //gcIconNavBack
                     @[@"40-forward",       @"766-arrow-right"],        //gcIconNavForward
                     @[@"19-gear",          @"740-gear"],               //gcIconNavGear
                     @[@"83-calendar",      @"851-calendar"],
                     @[@"fullscreen",       @"1067-enter-fullscreen"],
                     @[@"splitscreen",      @"1068-exit-fullscreen"],
                     @[@"715-globe",        @"715-globe"],
                     @[@"1099-list-1",      @"1099-list-1"],            //gcIconNavDetails
                     @[@"sigma",            @"sigma"],                   //gcIconNavAggregated
                     @[@"cal1w",            @"cal1w"],
                     @[@"cal1m",            @"cal1m"],
                     @[@"cal3m",            @"cal3m"],
                     @[@"cal6m",            @"cal6m"],
                     @[@"cal1y",            @"cal1y"],                 //gcIconNavYearly
                     @[@"798-filter",       @"798-filter"],
                     @[@"798-filter-selected", @"798-filter-selected"],
                     ];
        [_navDefs retain];
    }
    return _navDefs;
}

NSString * imageName(NSString * name, gcUIStyle style, NSString*suffix, NSString*bundle){
    if (bundle) {
        return [NSString stringWithFormat:@"%@%@%@.bundle/%@", bundle,suffix?:@"",style==gcUIStyleIOS7?@"-ios7":@"",name];
    }else{
        if(suffix){
            return [name stringByAppendingString:suffix];
        }else{
            return name;
        }
    }
}

UIImage*imageNamedIn(NSArray*defs,NSUInteger idx,gcUIStyle style,NSString*suffix,NSString*bundle){
    UIImage * rv = nil;

    if (idx < defs.count) {
        NSArray * names = defs[idx];
        NSUInteger prefIndex = (style == gcUIStyleIOS7 ? IDX_IOS7 : IDX_DEFAULT);
        if (prefIndex < names.count){
            rv = [UIImage imageNamed:imageName(names[prefIndex], style, suffix, bundle)];
        }
        if (!rv && IDX_DEFAULT < names.count) {
            rv = [UIImage imageNamed:imageName(names[IDX_DEFAULT], style, suffix, bundle)];
        }
    }
    return rv;

}

@implementation GCViewIcons

+(UIImage*)tabBarIconFor:(gcIconTab)name{
    return imageNamedIn(tabBarIconDefs(), name, [GCViewConfig uiStyle],nil,nil);
}


+(UIImage*)navigationIconFor:(gcIconNav)name{
    return imageNamedIn(navigationIconDefs(), name, [GCViewConfig uiStyle],nil,nil);
}

+(UIImage*)activityTypeColoredIconFor:(NSString*)activityType{
    if(activityType == nil){
        return nil;
    }

    UIImage * rv = [UIImage imageNamed:activityType];

    return rv;
}

+(UIImage*)activityTypeDynamicIconFor:(NSString*)activityType{
    UIImage * icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@-dyn", activityType]];
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
    UIImage * rv = [UIImage imageNamed:[NSString stringWithFormat:@"%@-bw", activityType]];
    return rv;

}

+(UIImage*)cellIconFor:(gcIconCell)name{
    return imageNamedIn(cellIconDefs(), name, [GCViewConfig uiStyle], nil, nil);
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
                 @"precision":  @"784-target"
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
