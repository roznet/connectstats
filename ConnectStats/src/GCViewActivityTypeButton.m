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
@property (nonatomic,retain) UILabel * labelView;
@property (nonatomic,retain) UIImageView * imageView;
@property (nonatomic,retain) UIViewController * presentingViewController;
@property (nonatomic,retain) UITableViewController * popoverViewController;
@end

@implementation GCViewActivityTypeButton

+(GCViewActivityTypeButton*)activityTypeButtonForDelegate:(NSObject<GCViewActivityTypeButtonDelegate>*)del{
    GCViewActivityTypeButton*rv = [[[GCViewActivityTypeButton alloc] init] autorelease];
    if (rv) {
        rv.delegate = del;
        
        //[rv setupBarButtonItem:nil];
    }
    return rv;
}

-(void)dealloc{
    [_popoverViewController release];
    [_presentingViewController release];
    [_imageView release];
    [_labelView release];
    
    [_activityTypeList release];
    [_delegate release];
    [_activityTypeButtonItem release];

    [super dealloc];
}

-(NSArray<NSString*>*)listActivityTypes{
    NSArray * types = nil;
    if ([self.delegate respondsToSelector:@selector(listActivityTypes)]) {
        types = [self.delegate listActivityTypes];
    }else{
        types = [[GCAppGlobal organizer] listActivityTypes];
    }
    return types;
}

-(NSString*)buttonTitleFor:(NSString*)activityType{
    NSString * rv = nil;
    BOOL filter = [self.delegate useFilter];
    
    if ([activityType isEqualToString:GC_TYPE_ALL]) {
        if (filter) {
            rv = NSLocalizedString( @"Search", @"Activity Type Button");
        }else{
            rv = NSLocalizedString(@"All", @"Activity Type Button");
        }
    }else{
        rv = [GCActivityType activityTypeForKey:activityType].displayName;
    }
    return rv;
}

-(UIImage*)imageFor:(NSString*)activityType{
    UIImage * img = [GCViewIcons activityTypeBWIconFor:activityType];
    if (img == nil) {
        if ([self.delegate respondsToSelector:@selector(useColoredIcons)] && [self.delegate useColoredIcons]) {
            img = [GCViewIcons activityTypeColoredIconFor:activityType];
        }
    }
    return img;
}

-(void)longPress:(UIGestureRecognizer*)gesture{
    if( self.presentingViewController && gesture.state == UIGestureRecognizerStateBegan){
        UITableViewController * controller = RZReturnAutorelease([[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped]);
        controller.modalPresentationStyle = UIModalPresentationPopover;
        controller.tableView.dataSource = self;
        controller.tableView.delegate = self;
        self.popoverViewController = controller;
        RZAutorelease([[UIPopoverPresentationController alloc] initWithPresentedViewController:controller
                                                                      presentingViewController:self.presentingViewController]);
        controller.popoverPresentationController.barButtonItem = self.activityTypeButtonItem;
        
        [self.presentingViewController presentViewController:controller animated:YES completion:nil];
    }
}

-(void)shortPress:(UIGestureRecognizer*)gesture{
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

-(BOOL)setupBarButtonItem:(nullable UIViewController*)presentingViewController{
    BOOL rv = false;
    
    self.presentingViewController = presentingViewController;
    
    NSString * activityType = [self.delegate activityType];
    if( activityType ){
        
        NSString * buttonTitle = [self buttonTitleFor:activityType];
        UIImage * img = [self imageFor:activityType];
        
        if (img) {
            if( self.imageView == nil){
                self.imageView = RZReturnAutorelease([[UIImageView alloc] initWithImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]);
                UITapGestureRecognizer * tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shortPress:)];
                tapG.numberOfTapsRequired = 1;
                [self.imageView addGestureRecognizer:tapG];
                [self.imageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
            }else{
                self.imageView.image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            self.imageView.tintColor = [GCViewConfig defaultColor:gcSkinDefaultColorHighlightedText];
            if( self.activityTypeButtonItem == nil){
                self.activityTypeButtonItem = RZReturnAutorelease([[UIBarButtonItem alloc] initWithCustomView:self.imageView]);
            }else{
                self.activityTypeButtonItem.customView = self.imageView;
            }
            rv = true;
        }else{
            if( self.labelView == nil){
                self.labelView = RZReturnAutorelease([[UILabel alloc] initWithFrame:CGRectZero]);
                self.labelView.highlighted = true;
                self.labelView.userInteractionEnabled = true;
                UITapGestureRecognizer * tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shortPress:)];
                tapG.numberOfTapsRequired = 1;
                [self.labelView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
                [self.labelView addGestureRecognizer:tapG];
            }
            self.labelView.text = buttonTitle;
            self.labelView.textColor = [GCViewConfig defaultColor:gcSkinDefaultColorHighlightedText];
            if( self.activityTypeButtonItem == nil){
                self.activityTypeButtonItem = RZReturnAutorelease([[UIBarButtonItem alloc] initWithCustomView:self.labelView]);
            }else{
                self.activityTypeButtonItem.customView = self.labelView;
            }
            rv = true;
        }
    }
    return rv;
}

#pragma mark - UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GCCellGrid * cell = [GCCellGrid gridCell:tableView];
    [cell setupForRows:1 andCols:1];
    
    NSArray * types = self.listActivityTypes;

    if( indexPath.row < types.count ){
        NSString * activityType = types[indexPath.row];
        UIImage * img = [GCViewIcons activityTypeBWIconFor:activityType];
        if (img == nil) {
            if ([self.delegate respondsToSelector:@selector(useColoredIcons)] && [self.delegate useColoredIcons]) {
                img = [GCViewIcons activityTypeColoredIconFor:activityType];
            }
        }
        if( img ){
            [cell setIconImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            cell.iconView.tintColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
        }else{
            [cell setIconImage:nil];
        }
        
        [cell labelForRow:0 andCol:0].text = [GCActivityType activityTypeForKey:activityType].displayName;
    }else{
        [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Index Error",@"Activity Type Button");
    }

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.listActivityTypes.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<NSString*>*types = self.listActivityTypes;
    NSString * type = indexPath.row < types.count ? types[indexPath.row] : types.firstObject;
    
    [self.delegate setupForCurrentActivityType:type andFilter:false];
    [self.popoverViewController dismissViewControllerAnimated:TRUE completion:nil];
}

@end
