//  MIT Licence
//
//  Created on 21/07/2013.
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

#import "GCViewActivityTypeButton.h"
#import "GCActivity.h"
#import "GCViewConfig.h"
#import "GCAppGlobal.h"
#import "GCViewIcons.h"


@interface GCViewActivityTypeButton ()
@property (nonatomic,retain) NSArray * activityTypeList;

@end

@implementation GCViewActivityTypeButton

+(GCViewActivityTypeButton*)activityTypeButtonForDelegate:(NSObject<GCViewActivityTypeButtonDelegate>*)del{
    GCViewActivityTypeButton*rv = [[[GCViewActivityTypeButton alloc] init] autorelease];
    if (rv) {
        rv.delegate = del;
        NSString * activityType = [del activityType];
        UIImage * img = [GCViewIcons activityTypeBWIconFor:activityType];

        if (img) {
            rv.activityTypeButtonItem = [[[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:rv action:@selector(titleSingleTap)] autorelease];
        }else{
            NSString * otherLabel = [activityType isEqualToString:GC_TYPE_DAY] ? NSLocalizedString( @"Day", @"Activity Type Button") :NSLocalizedString( @"Other", @"Activity Type Button");
            rv.activityTypeButtonItem = [[[UIBarButtonItem alloc] initWithTitle:otherLabel
                                                                          style:UIBarButtonItemStylePlain target:rv action:@selector(titleSingleTap)] autorelease];
        }
    }
    return rv;
}

-(void)dealloc{
    [_activityTypeList release];
    [_delegate release];
    [_activityTypeButtonItem release];

    [super dealloc];
}
-(void)titleSingleTap{
    NSArray * types = nil;
    if ([self.delegate respondsToSelector:@selector(listActivityTypes)]) {
        types = [self.delegate listActivityTypes];
    }else{
        types = [[GCAppGlobal organizer] listActivityTypes];
    }

    NSString * atype = nil;
    NSString * activityType = [self.delegate activityType];

    // useFilter will be toggled when activityType = true and filter is on
    // This allows to have a Search type in the case a filter is on.
    //

    BOOL currentFilter = [self.delegate useFilter];
    BOOL ignoreFilter = [self.delegate respondsToSelector:@selector(ignoreFilter)] && [self.delegate ignoreFilter];

    NSUInteger idx = [types indexOfObject:activityType];
    if (idx==NSNotFound) {
        idx = [types indexOfObject:GC_TYPE_ALL];
    }
    if(!ignoreFilter && ([activityType isEqualToString:GC_TYPE_ALL] && currentFilter == false && [[GCAppGlobal organizer] hasFilter])){
        atype = GC_TYPE_ALL;
        currentFilter = true;
    }else{
        if (idx < types.count-1) {
            idx++;
        }else{
            idx=0;
        }
        atype = types[idx];
        currentFilter = false;
    }
    [self.delegate setupForCurrentActivityType:atype andFilter:currentFilter];
}

-(void)setupBarButtonItem{
    NSString * activityType = [self.delegate activityType];
    BOOL filter = [self.delegate useFilter];

    if ([activityType isEqualToString:GC_TYPE_ALL]) {
        [self.activityTypeButtonItem setImage:nil];
        if (filter) {
            [self.activityTypeButtonItem setTitle:NSLocalizedString( @"Search", @"Activity Type Button")];
        }else{
            NSString * allLabel = [GCAppGlobal healthStatsVersion] ? NSLocalizedString(@"Workouts", @"Activity Type Button") : NSLocalizedString(@"All", @"Activity Type Button");
            (self.activityTypeButtonItem).title = allLabel;
        }
    }else{
        UIImage * img = [GCViewIcons activityTypeBWIconFor:activityType];
        if (img == nil) {
            if ([self.delegate respondsToSelector:@selector(useColoredIcons)] && [self.delegate useColoredIcons]) {
                img = [GCViewIcons activityTypeColoredIconFor:activityType];
            }
        }
        if (img) {
            (self.activityTypeButtonItem).image = img;
            [self.activityTypeButtonItem setTitle:nil];
        }else{

            [self.activityTypeButtonItem setImage:nil];
            if( activityType != nil){
                NSString * otherLabel = [GCActivityType activityTypeForKey:activityType].displayName;
                (self.activityTypeButtonItem).title = otherLabel;
            }
        }
    }
}

@end
