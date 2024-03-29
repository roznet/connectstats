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
#import "GCActivityType.h"
#import "GCActivityType+Icon.h"
#import "ConnectStats-Swift.h"

@interface GCViewActivityTypeButton ()
@property (nonatomic,readonly) NSArray<GCActivityType*> * activityTypeList;
@property (nonatomic,retain) UILabel * labelView;
@property (nonatomic,retain) UIImageView * imageView;
@property (nonatomic,retain) UIViewController * presentingViewController;
@property (nonatomic,retain) GCActivityTypeSelectionViewController * popoverViewController;
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

    [_delegate release];
    [_activityTypeButtonItem release];

    [super dealloc];
}

-(BOOL)matchPrimaryType{
    return self.delegate.activityTypeSelection.matchPrimaryType;
}

-(void)setMatchPrimaryType:(BOOL)matchPrimaryType{
    [self.delegate.activityTypeSelection setMatchPrimaryType:matchPrimaryType];
}

-(NSArray<GCActivityType*>*)activityTypeList{
    NSArray<GCActivityType*> * types = nil;
    if ([self.delegate respondsToSelector:@selector(listActivityTypes)]) {
        types = [self.delegate listActivityTypes];
    }else{
        types = [[GCAppGlobal organizer] listActivityTypes];
    }
    if( self.matchPrimaryType ){
        NSMutableArray<GCActivityType*>*primaryTypes = [NSMutableArray array];
        for (GCActivityType * one in types) {
            GCActivityType * primary = one.primaryActivityType;
            if( ! [primaryTypes containsObject:primary]){
                [primaryTypes addObject:primary];
            }
        }
        types = primaryTypes;
    }
    
    return types;
}

-(NSString*)buttonTitleFor:(GCActivityType*)activityType{
    NSString * rv = nil;
    BOOL filter = [self.delegate useFilter];
    
    if ([activityType.key isEqualToString:GC_TYPE_ALL]) {
        if (filter) {
            rv = NSLocalizedString( @"Search", @"Activity Type Button");
        }else{
            rv = NSLocalizedString(@"All", @"Activity Type Button");
        }
    }else{
        rv = activityType.displayName;
    }
    return rv;
}

-(UIImage*)imageFor:(GCActivityType*)activityType{
    UIImage * img = activityType.icon;
    if (img == nil) {
        if ([self.delegate respondsToSelector:@selector(useColoredIcons)] && [self.delegate useColoredIcons]) {
            img = activityType.coloredIcon;
        }
    }
    return img;
}

-(void)longPress:(UIGestureRecognizer*)gesture{
    if( self.presentingViewController && gesture.state == UIGestureRecognizerStateBegan){
        GCActivityTypeSelectionViewController * controller = RZReturnAutorelease([[GCActivityTypeSelectionViewController alloc] initWithNibName:@"GCActivityTypeSelectionViewController" bundle:nil]);
        controller.modalPresentationStyle = UIModalPresentationPopover;
        controller.activityTypeButton = self;
        self.popoverViewController = controller;
        RZAutorelease([[UIPopoverPresentationController alloc] initWithPresentedViewController:controller
                                                                      presentingViewController:self.presentingViewController]);
        controller.popoverPresentationController.barButtonItem = self.activityTypeButtonItem;
        
        [self.presentingViewController presentViewController:controller animated:YES completion:nil];
    }
}

-(void)shortPress:(UIGestureRecognizer*)gesture{
    NSArray<GCActivityType*> * types = self.activityTypeList;

    GCActivityTypeSelection * selection = self.delegate.activityTypeSelection;

    // useFilter will be toggled when activityType = true and filter is on
    // This allows to have a Search type in the case a filter is on.
    //

    BOOL currentFilter = [self.delegate useFilter];
    BOOL ignoreFilter = [self.delegate respondsToSelector:@selector(ignoreFilter)] && [self.delegate ignoreFilter];

    NSUInteger idx = [types indexOfObject:selection.activityTypeDetail];
    if (idx==NSNotFound) {
        idx = [types indexOfObject:GCActivityType.all];
    }
    if(!ignoreFilter && ([selection.activityTypeDetail isEqualToActivityType:GCActivityType.all] && currentFilter == false && [[GCAppGlobal organizer] hasFilter])){
        currentFilter = true;
    }else{
        if (idx < types.count-1) {
            idx++;
        }else{
            idx=0;
        }
        selection = RZReturnAutorelease([[GCActivityTypeSelection alloc] initWithSelection:selection]);
        selection.activityTypeDetail = types[idx];
        currentFilter = false;
    }
    
    [self.delegate setupForCurrentActivityTypeSelection:selection andFilter:currentFilter];
}

-(BOOL)setupBarButtonItem:(nullable UIViewController*)presentingViewController{
    BOOL rv = false;
    
    self.presentingViewController = presentingViewController;
    
    GCActivityType * activityType = self.delegate.activityTypeSelection.activityTypeDetail;
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
    GCCellGrid * cell = [GCCellGrid cellGrid:tableView];
    [cell setupForRows:1 andCols:1];
    
    NSArray<GCActivityType*> * types = self.activityTypeList;

    if( indexPath.row < types.count ){
        GCActivityType * activityType = types[indexPath.row];
        UIImage * img = activityType.icon;
        if (img == nil) {
            if ([self.delegate respondsToSelector:@selector(useColoredIcons)] && [self.delegate useColoredIcons]) {
                img = activityType.coloredIcon;
            }
        }
        if( img ){
            [cell setIconImage:[img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            cell.iconView.tintColor = [GCViewConfig defaultColor:gcSkinDefaultColorPrimaryText];
        }else{
            [cell setIconImage:nil];
        }
        
        [cell labelForRow:0 andCol:0].text = activityType.displayName;
    }else{
        [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Index Error",@"Activity Type Button");
    }

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.activityTypeList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<GCActivityType*>*types = self.activityTypeList;
    GCActivityType * type = indexPath.row < types.count ? types[indexPath.row] : types.firstObject;
    
    GCActivityTypeSelection * selection = RZReturnAutorelease([[GCActivityTypeSelection alloc] initWithActivityTypeDetail:type matchPrimaryType:self.matchPrimaryType]);
    
    [self.delegate setupForCurrentActivityTypeSelection:selection andFilter:false];


    [self.popoverViewController dismissViewControllerAnimated:TRUE completion:nil];
}

@end
