//  MIT Licence
//
//  Created on 04/10/2012.
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

#import "GCSettingsViewController.h"
#import "GCAppGlobal.h"
#import "GCCellGrid+Templates.h"
#import "GCSettingsCacheManagementViewController.h"
#import "GCActivitiesCacheManagement.h"
#import "GCSettingsProfilesViewController.h"
#import "GCSettingsBugReportViewController.h"
#import "GCSettingsServicesViewController.h"
#import "GCSettingsHelpViewController.h"
#import "GCSplitViewController.h"
#import "GCSettingsFilterViewController.h"
#import "GCHealthViewController.h"
#import "GCSettingsReloadViewController.h"
#import "GCSettingsLogViewController.h"
#import "GCService.h"
#import "GCDebugActionsTableViewController.h"
@import RZExternal;
@import SafariServices;

#define GC_SECTION_LOGIN    0
#define GC_SECTION_PARAMS   1
#define GC_SECTION_OTHER    2
#define GC_SECTION_ADVANCED 3
#define GC_SECTION_LOG      4
#define GC_SECTION_END      5

#define GC_SETTINGS_SERVICES    0
#define GC_SETTINGS_PROFILE     1
#define GC_SETTINGS_HEALTH      2
#define GC_SETTINGS_BLOG        3
#define GC_SETTINGS_LOGIN_END   4

#define GC_SETTINGS_REFRESH     0
#define GC_SETTINGS_UNITS       1
#define GC_SETTINGS_FIRSTDAY    2
#define GC_SETTINGS_PERIOD      3
#define GC_SETTINGS_FILTER      4
#define GC_SETTINGS_LAPS        5
#define GC_SETTINGS_STRIDE      6
#define GC_SETTINGS_SKIN        7
#define GC_SETTINGS_TO_DATE     8
#define GC_SETTINGS_PARAMS_END  9

#define GC_SETTINGS_INLINE_GRAPHS   0
#define GC_SETTINGS_LAP_OVERLAY     1
#define GC_SETTINGS_MAP             2
#define GC_SETTINGS_FASTMAP         3
#define GC_SETTINGS_CONTINUE_ERROR  4
#define GC_SETTINGS_ENABLE_DERIVED  5
#define GC_SETTINGS_FONT_STYLE      6
#define GC_SETTINGS_SHOW_DOWNLOAD   7
#define GC_SETTINGS_INLINE_GRADIENT 8
#define GC_SETTINGS_LANGUAGE        9
#define GC_SETTINGS_EXTENDED_DISPAY 10
#define GC_SETTINGS_ADVANCED_END    11


//disabled
#define GC_SETTINGS_NEWAPI          1000
#define GC_SETTINGS_RELOAD          1001

#define GC_SETTINGS_HELP            0
#define GC_SETTINGS_BUGREPORT       1
#define GC_SETTINGS_INCLUDEDATA     2
#define GC_SETTINGS_OTHER_END       3

#define GC_SETTINGS_SHOW_LOG        0
#define GC_SETTINGS_TRIGGER_ACTION  1

#define GC_BUTTON_SUBMIT @"Submit"
#define GC_BUTTON_EXCLUDE @"No"
#define GC_BUTTON_INCLUDE @"Yes, include"

@interface GCSettingsViewController ()
@property (nonatomic,retain) RZTableIndexRemap * remap;
@end

@implementation GCSettingsViewController
@synthesize  changedName,changedPwd;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        changedName = false;
        changedPwd   = false;
        [[GCAppGlobal profile] attach:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];

        [self buildRemap];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[GCAppGlobal profile] detach:self];
    [_remap release];

    [super dealloc];
}

-(void)buildRemap{
    self.remap = [RZTableIndexRemap tableIndexRemap];
    
    BOOL allSections = [GCAppGlobal connectStatsVersion];
    
    if ([[GCAppGlobal configGetString:CONFIG_ENABLE_DEBUG defaultValue:CONFIG_ENABLE_DEBUG_OFF] isEqualToString:CONFIG_ENABLE_DEBUG_ON]) {
        [self.remap addSection:GC_SECTION_LOG withRows:@[ @( GC_SETTINGS_SHOW_LOG),
                                                          @( GC_SETTINGS_TRIGGER_ACTION)]];
    }
    
    if (allSections) {
        [self.remap addSection:GC_SECTION_LOGIN withRows:@[
                                                           @( GC_SETTINGS_SERVICES    ),
                                                           @( GC_SETTINGS_PROFILE     ),
                                                           @( GC_SETTINGS_BLOG        ),
                                                           @( GC_SETTINGS_HEALTH      )]];
    }else{
        [self.remap addSection:GC_SECTION_LOGIN withRows:@[
                                                           @( GC_SETTINGS_SERVICES    ),
                                                           @( GC_SETTINGS_PROFILE     ),
                                                           @( GC_SETTINGS_BLOG        )
                                                           ]];
        
    }
    
    if (allSections) {
        [self.remap addSection:GC_SECTION_PARAMS withRows:@[
                                                            @( GC_SETTINGS_REFRESH     ),
                                                            @( GC_SETTINGS_SKIN        ),
                                                            @( GC_SETTINGS_UNITS       ),
                                                            @( GC_SETTINGS_FIRSTDAY    ),
                                                            @( GC_SETTINGS_PERIOD      ),
                                                            @( GC_SETTINGS_TO_DATE     ),
                                                            @( GC_SETTINGS_FILTER      ),
                                                            @( GC_SETTINGS_LAPS        ),
                                                            @( GC_SETTINGS_STRIDE      )]];
    }else{
        [self.remap addSection:GC_SECTION_PARAMS withRows:@[
                                                            @( GC_SETTINGS_REFRESH     ),
                                                            @( GC_SETTINGS_SKIN        ),
                                                            @( GC_SETTINGS_UNITS       ),
                                                            @( GC_SETTINGS_FIRSTDAY    ),
                                                            @( GC_SETTINGS_STRIDE      )]];
        
    }
    
    [self.remap addSection:GC_SECTION_OTHER withRows:@[
                                                       @( GC_SETTINGS_HELP            ),
                                                       @( GC_SETTINGS_BUGREPORT       ),
                                                       @( GC_SETTINGS_INCLUDEDATA     ),
                                                       ]];
    
    if (allSections) {
        [self.remap addSection:GC_SECTION_ADVANCED withRows:@[
                                                              @( GC_SETTINGS_LANGUAGE        ),
                                                              @( GC_SETTINGS_INLINE_GRAPHS   ),
                                                              @( GC_SETTINGS_INLINE_GRADIENT ),
                                                              @( GC_SETTINGS_LAP_OVERLAY     ),
                                                              @( GC_SETTINGS_FASTMAP         ),
                                                              @( GC_SETTINGS_CONTINUE_ERROR  ),
                                                              @( GC_SETTINGS_ENABLE_DERIVED  ),
                                                              @( GC_SETTINGS_EXTENDED_DISPAY ),
                                                              @( GC_SETTINGS_SHOW_DOWNLOAD   ),
                                                              @( GC_SETTINGS_MAP             ),
                                                              @( GC_SETTINGS_FONT_STYLE) ]];
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorGroupedTable];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GCViewConfig setupViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.remap numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.remap numberOfRowsInSection:section];
//        case GC_SECTION_LOG:
//            return [[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin] isEqualToString:@"bricerosenzweig"] ? 1 : 0;
    // Return the number of rows in the section.
    //return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    UITableViewCell * rv = nil;
    GCCellEntrySwitch * switchcell = nil;
    //GCCellEntryText * textcell = nil;
    GCCellGrid * gridcell = nil;

    if (indexPath.section == GC_SECTION_PARAMS) {
        switch (indexPath.row) {
            case GC_SETTINGS_SKIN:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];
                
                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Theme",@"Profile Skin")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                NSString * skin = [[GCAppGlobal profile] configGetString:CONFIG_SKIN_NAME defaultValue:kGCSkinNameOriginal];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:skin
                                                                                attributes:[GCViewConfig attribute16]] autorelease];
                
                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                
                rv = gridcell;
                break;

            }
            case GC_SETTINGS_REFRESH:
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16] withString:NSLocalizedString(@"Refresh on startup",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_REFRESH)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [[GCAppGlobal profile] configGetBool:CONFIG_REFRESH_STARTUP defaultValue:[GCAppGlobal healthStatsVersion]];
                break;
            case GC_SETTINGS_UNITS:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Units",@"Profile units")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                NSArray * systems = [GCViewConfig unitSystemDescriptions];
                NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_UNIT_SYSTEM defaultValue:GCUnitSystemDefault];
                NSString * value = selected < systems.count ? systems[selected] : systems[0];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:value
                                                                                attributes:[GCViewConfig attribute16]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_STRIDE:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Stride Units",@"Profile units")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                NSArray * stridestyles = [GCUnit strideStyleDescriptions];
                NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_STRIDE_STYLE defaultValue:GCUnitStrideSameFoot];
                NSString * value = selected < stridestyles.count ? stridestyles[selected] : stridestyles[0];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:value
                                                                                attributes:[GCViewConfig attribute16]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;

            }
            case GC_SETTINGS_FILTER:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Filter bad values",@"Profile units")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                BOOL selected = [GCAppGlobal configGetBool:CONFIG_FILTER_BAD_VALUES defaultValue:true];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:selected ? NSLocalizedString(@"On", @"Settings") : NSLocalizedString(@"Off", @"Settings")
                                                                                attributes:[GCViewConfig attribute16]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_FIRSTDAY:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"First Day of Week",@"Profile Week Start")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                NSArray * choices = [GCViewConfig weekStartDescriptions];
                NSUInteger selected = [GCViewConfig weekDayIndex:[GCAppGlobal configGetInt:CONFIG_FIRST_DAY_WEEK defaultValue:1]];
                NSString * value = selected < choices.count ? choices[selected] : choices[0];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:value
                                                                                attributes:[GCViewConfig attribute16]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_PERIOD:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Period for Stats",@"Profile Period")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                NSArray * choices = [GCViewConfig periodDescriptions];
                NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_PERIOD_TYPE defaultValue:0];
                NSString * value = selected < choices.count ? choices[selected] : choices[0];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:value
                                                                                attributes:[GCViewConfig attribute16]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;

            }
            case GC_SETTINGS_TO_DATE:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16] withString:NSLocalizedString(@"To Date use last activity",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_TO_DATE)];
                switchcell.entryFieldDelegate = self;
                switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_TODATE_LAST_ACTIVITY defaultValue:true];
                break;
            }

            case GC_SETTINGS_LAPS:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];
                NSString * value = nil;
                if ([GCAppGlobal configGetBool:CONFIG_USE_MOVING_ELAPSED defaultValue:false]) {
                    value = NSLocalizedString( @"Time Moving", @"Moving Elapsed" );
                }else{
                    value = NSLocalizedString( @"Actual Time", @"Moving Elapsed" );
                }
                [gridcell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:@"Laps use" attribute:@selector(attributeBold16)];
                [gridcell labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:value attribute:@selector(attribute16)];
                rv = gridcell;
                break;
            }
        }
    }else if (indexPath.section==GC_SECTION_ADVANCED){
        switch (indexPath.row) {
            case GC_SETTINGS_LANGUAGE:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];
                NSString * msg = NSLocalizedString(@"Language", @"Settings");
                NSArray * choices = [GCViewConfig languageSettingChoices];
                NSUInteger choice = [GCAppGlobal configGetInt:CONFIG_LANGUAGE_SETTING defaultValue:gcLanguageSettingAsDownloaded];
                NSString * current = @"MISSING";
                if (choice < choices.count) {
                    current = choices[choice];
                }
                [gridcell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:msg attribute:@selector(attributeBold16)];
                [gridcell labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:current attribute:@selector(attribute16)];
                rv = gridcell;
                break;

            }
            case GC_SETTINGS_NEWAPI:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16] withString:NSLocalizedString(@"New track download api",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_NEWAPI)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_USE_NEW_TRACK_API defaultValue:true];
                break;

            }
            case GC_SETTINGS_RELOAD:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:1];
                NSString * msg = NSLocalizedString(@"Reload Activities", @"Settings");
                [gridcell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:msg attribute:@selector(attributeBold16)];
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_FONT_STYLE:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];
                NSString * msg = NSLocalizedString(@"Font Style", @"Settings");
                NSString * style = NSLocalizedString(@"Dynamic", @"Settings");
                if ([GCViewConfig fontStyle] != gcFontStyleDynamicType) {
                    style = NSLocalizedString(@"Helvetica", @"Settings");
                }
                [gridcell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:msg attribute:@selector(attributeBold16)];
                [gridcell labelForRow:0 andCol:1].attributedText = [GCViewConfig attributedString:style attribute:@selector(attribute16)];
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_MAP:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:1 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Map",@"Profile map")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                gcMapType selected = (gcMapType)[GCAppGlobal configGetInt:CONFIG_USE_MAP defaultValue:gcMapBoth];
                NSArray * types = [GCViewConfig mapTypes];
                NSString * value = selected < types.count ? types[selected] : types[0];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:value
                                                                                attributes:[GCViewConfig attribute16]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_EXTENDED_DISPAY:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Activity List shows more Data",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_EXTENDED_DISPAY)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_CELL_EXTENDED_DISPLAY defaultValue:true];
                break;

            }
            case GC_SETTINGS_SHOW_DOWNLOAD:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Show Download Icon",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_SHOW_DOWNLOAD)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_SHOW_DOWNLOAD_ICON defaultValue:true];
                break;

            }
            case GC_SETTINGS_INLINE_GRADIENT:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Map Gradient in Tables",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_INLINE_GRADIENT)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_MAPS_INLINE_GRADIENT defaultValue:true];
                break;

            }
            case GC_SETTINGS_INLINE_GRAPHS:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Graphs in Tables",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_INLINE_GRAPHS)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_STATS_INLINE_GRAPHS defaultValue:true];
                break;

            }
            case GC_SETTINGS_ENABLE_DERIVED:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Compute Best Overall",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_ENABLE_DERIVED)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [[GCAppGlobal profile] configGetBool:CONFIG_ENABLE_DERIVED defaultValue:[GCAppGlobal connectStatsVersion]];
                break;
            }
            case GC_SETTINGS_LAP_OVERLAY:
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Laps Overlay in Graphs", @"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_LAP_OVERLAY)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_GRAPH_LAP_OVERLAY defaultValue:true];
                break;
            case GC_SETTINGS_FASTMAP:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Map skip points",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_FASTMAP)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_FASTER_MAPS defaultValue:true];
                break;
            }
            case GC_SETTINGS_CONTINUE_ERROR:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Continue on Error",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_CONTINUE_ERROR)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_CONTINUE_ON_ERROR defaultValue:false];
                break;

            }
            default:
                break;
        }

    }else if(indexPath.section == GC_SECTION_LOGIN){
        switch (indexPath.row) {
            case GC_SETTINGS_SERVICES:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:2 andCols:1];
                NSAttributedString * services = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Services and Accounts", @"Settings") attributes:[GCViewConfig attributeBold16]] autorelease];

                NSMutableArray * statuses = [NSMutableArray arrayWithCapacity:5];
                NSString * status = nil;
                status = [[GCService service:gcServiceGarmin] statusDescription];
                if (status.length>0) {
                    [statuses addObject:status];
                }
                status = [[GCService service:gcServiceStrava] statusDescription];
                if (status.length>0) {
                    [statuses addObject:status];
                }
                status = [statuses componentsJoinedByString:@", "];

                NSAttributedString * other =[[[NSAttributedString alloc] initWithString:status attributes:[GCViewConfig attribute14Gray]] autorelease];
                [gridcell labelForRow:0 andCol:0].attributedText = services;
                [gridcell labelForRow:1 andCol:0].attributedText = other;
                rv= gridcell;
                break;
            }
            case GC_SETTINGS_HEALTH:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:2 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Health and Zones",@"Settings")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_PROFILE:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:2 andCols:2];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Current Profile", @"Settings")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                NSAttributedString * current = [[[NSAttributedString alloc] initWithString:[[GCAppGlobal profile] currentProfileName]
                                                                                attributes:[GCViewConfig attribute16]] autorelease];
                NSAttributedString * count = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d profiles",
                                                                                          (int)[[GCAppGlobal profile] countOfProfiles]]
                                                                              attributes:[GCViewConfig attribute14Gray]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:0 andCol:1].attributedText = current;
                [gridcell labelForRow:1 andCol:0].attributedText = count;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;
            }
            case GC_SETTINGS_BLOG:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:2 andCols:1];
                
                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Blog", @"Settings")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];
                
                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:1 andCol:0].attributedText = nil;
                
                NSArray * messages = [GCAppGlobal recentRemoteMessages];
                
                if( messages.count > 0 ){
                    CGFloat size = 25;
                    UIImageView * iv = [[[UIImageView alloc] initWithFrame:CGRectMake(0., 0., size, size)] autorelease];
                    UILabel * count = [[[UILabel alloc] initWithFrame:CGRectMake(0., 0, size, size)] autorelease];
                    count.text = [@(messages.count) stringValue];
                    count.textColor = [UIColor whiteColor];
                    count.backgroundColor = [UIColor redColor];
                    count.layer.cornerRadius = size/2.0;
                    count.layer.masksToBounds = true;
                    count.textAlignment = NSTextAlignmentCenter;
                    [iv addSubview:count];
                    [gridcell setIconView:iv withSize:CGSizeMake(30, 20)];
                    NSString * desc = messages.lastObject[@"description"];
                    if( [desc isKindOfClass:[NSString class]]){
                        [gridcell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withString:desc];
                    }
                }
                rv = gridcell;
                break;
            }
        }
    }else if(indexPath.section == GC_SECTION_OTHER){
        switch (indexPath.row) {
            case GC_SETTINGS_INCLUDEDATA:
            {
                switchcell = [GCCellEntrySwitch switchCell:tableView];
                switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                            withString:NSLocalizedString(@"Bug Report Include Activity",@"Settings")];
                rv = switchcell;
                [switchcell setIdentifierInt:GC_IDENTIFIER(GC_SECTION_OTHER, GC_SETTINGS_INCLUDEDATA)];
                switchcell.entryFieldDelegate = self;
                (switchcell.toggle).on = [GCAppGlobal configGetBool:CONFIG_BUG_INCLUDE_DATA defaultValue:true];
                break;

            }
            case  GC_SETTINGS_BUGREPORT:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:2 andCols:1];

                RZLogStatus stat = RZLogCheckStatus();
                NSArray * errors = [GCActivitiesCacheManagement errorFiles];
                stat.errors +=errors.count;

                NSAttributedString * title = [GCViewConfig attributedString:NSLocalizedString(@"Send Bug Report or Feedback", @"Settings") attribute:@selector(attributeBold16)];

                NSString * msg = NSLocalizedString(@"No Diagnostics to report", @"Settings");
                if (stat.exists || errors.count) {
                    msg = NSLocalizedString(@"No errors detected",@"Settings");
                    if (stat.errors !=0 || stat.crashes !=0 ) {
                        NSMutableString * msgm = [NSMutableString string];
                        if (stat.errors > 0) {
                            [msgm appendFormat:@"%d Errors", (int)stat.errors];
                        }
                        if (stat.crashes > 0) {
                            [msgm appendFormat:@" %d Crashes", (int)stat.crashes];
                        }
                        [msgm appendString:@" detected"];
                        msg = msgm;
                    }
                }

                NSAttributedString * details = [[[NSAttributedString alloc] initWithString:msg
                                                                                attributes:[GCViewConfig attribute14Gray]] autorelease];

                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:1 andCol:0].attributedText = details;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;
            }
            case  GC_SETTINGS_HELP:
            {
                gridcell = [GCCellGrid cellGrid:tableView];
                [gridcell setupForRows:2 andCols:2];

                NSString * versionS = [NSString stringWithFormat:@"Version %@", [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"]];
                NSString * buildS= @(__DATE__);
                NSAttributedString * version = [[[NSAttributedString alloc] initWithString:versionS attributes:[GCViewConfig attribute14Gray]] autorelease];
                NSAttributedString * build =[[[NSAttributedString alloc] initWithString:buildS attributes:[GCViewConfig attribute14Gray]] autorelease];

                NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Help", @"Setting")
                                                                              attributes:[GCViewConfig attributeBold16]] autorelease];


                [gridcell labelForRow:0 andCol:0].attributedText = title;
                [gridcell labelForRow:1 andCol:0].attributedText = version;
                [gridcell labelForRow:1 andCol:1].attributedText = build;
                //[GCViewConfig setupGradientForDetails:gridcell.gradientLayer];
                rv = gridcell;
                break;
            }


        }

    }else if (indexPath.section==GC_SECTION_LOG){
        if (indexPath.row==GC_SETTINGS_TRIGGER_ACTION) {
            gridcell  = [GCCellGrid cellGrid:tableView];
            [gridcell setupForRows:1 andCols:1];
            [gridcell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:NSLocalizedString( @"Debug Actions", @"SettingsView")];
            rv=gridcell;
        }else if (indexPath.row == GC_SETTINGS_SHOW_LOG){
            gridcell  = [GCCellGrid cellGrid:tableView];
            [gridcell setupForRows:1 andCols:1];
            [gridcell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:NSLocalizedString( @"Log", @"SettingsView")];
            rv=gridcell;
        }
    }
    
    rv.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
    
    return rv ?: [GCCellGrid cellGrid:tableView];
}

-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    switch ([cell identifierInt]) {
        case GC_IDENTIFIER(GC_SECTION_OTHER, GC_SETTINGS_INCLUDEDATA):
            [GCAppGlobal configSet:CONFIG_BUG_INCLUDE_DATA boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_REFRESH):
            [[GCAppGlobal profile] configSet:CONFIG_REFRESH_STARTUP boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_UNITS):
            [GCAppGlobal configSet:CONFIG_UNIT_SYSTEM intVal:[cell selected]];
            [GCUnit setGlobalSystem:(gcUnitSystem)[cell selected]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_SKIN):
        {
            NSString * newSkin = [[GCViewConfigSkin availableSkinNames] objectAtIndex:cell.selected];
            GCViewConfigSkin * skin = [GCViewConfigSkin skinForName:newSkin];
            if( skin ){
                [GCViewConfig setSkin:skin];
                [GCViewConfig setupViewController:self];
                // Spacial case, somehow when you change the settings, the navigationbar
                // didn't change color unless done expliciatly
                self.navigationController.navigationBar.barTintColor = [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
                self.navigationController.navigationBar.tintColor = [GCViewConfig
                                                                     defaultColor:gcSkinDefaultColorHighlightedText];
                 
                [[GCAppGlobal profile] configSet:CONFIG_SKIN_NAME stringVal:newSkin];
                [GCAppGlobal saveSettings];
            }
            break;
        }
        case GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_FIRSTDAY):
            [GCAppGlobal configSet:CONFIG_FIRST_DAY_WEEK intVal:[GCViewConfig weekDayValue:[cell selected]]];
            [NSDate cc_setCalculationCalendar:[GCAppGlobal calculationCalendar]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_PERIOD):
            [GCAppGlobal configSet:CONFIG_PERIOD_TYPE intVal:[cell selected]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_TO_DATE):
            [[GCAppGlobal  profile] configSet:CONFIG_TODATE_LAST_ACTIVITY boolVal:cell.on];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_MAP):
            [GCAppGlobal configSet:CONFIG_USE_MAP intVal:[cell selected]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_INLINE_GRAPHS):
            [GCAppGlobal configSet:CONFIG_STATS_INLINE_GRAPHS boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_INLINE_GRADIENT):
            [GCAppGlobal configSet:CONFIG_MAPS_INLINE_GRADIENT boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_SHOW_DOWNLOAD):
            [GCAppGlobal configSet:CONFIG_SHOW_DOWNLOAD_ICON boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_EXTENDED_DISPAY):
            [GCAppGlobal configSet:CONFIG_CELL_EXTENDED_DISPLAY boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_LAP_OVERLAY):
            [GCAppGlobal configSet:CONFIG_GRAPH_LAP_OVERLAY boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_FASTMAP):
            [GCAppGlobal configSet:CONFIG_FASTER_MAPS boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_CONTINUE_ERROR):
            [GCAppGlobal configSet:CONFIG_CONTINUE_ON_ERROR boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_ENABLE_DERIVED):
            [[GCAppGlobal profile] configSet:CONFIG_ENABLE_DERIVED boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;

        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_NEWAPI):
            [GCAppGlobal configSet:CONFIG_USE_NEW_TRACK_API boolVal:[cell on]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_STRIDE):
            [GCAppGlobal configSet:CONFIG_STRIDE_STYLE intVal:[cell selected]];
            [GCUnit setStrideStyle:(GCUnitStrideStyle)[cell selected]];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_LANGUAGE):
            [GCAppGlobal configSet:CONFIG_LANGUAGE_SETTING intVal:[cell selected]];
            [GCAppGlobal setupFieldCache];
            [GCAppGlobal saveSettings];
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self reloadView];
    });
}

#pragma mark - Table view delegate

-(void)showServices{
    GCSettingsServicesViewController * detail = [[GCSettingsServicesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    NSInteger section = indexPath.section;

    if (section == GC_SECTION_LOGIN) {
        if (indexPath.row == GC_SETTINGS_PROFILE){
            GCSettingsProfilesViewController * detail =[[GCSettingsProfilesViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:detail animated:YES];
            [detail release];
        }else if (indexPath.row == GC_SETTINGS_HEALTH){
            GCHealthViewController * detail = [[[GCHealthViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            [self.navigationController pushViewController:detail animated:YES];
        }else if (indexPath.row == GC_SETTINGS_SERVICES) {
            [self showServices];
        }else if( indexPath.row == GC_SETTINGS_BLOG) {
            NSURL * url = [NSURL URLWithString:@"https://ro-z.net"];
            NSArray * messages = [GCAppGlobal recentRemoteMessages];
            if( messages.count > 0){
                NSDictionary * latest = messages.lastObject;
                if( [latest isKindOfClass:[NSDictionary class]] ){
                    if( [latest[@"url"] isKindOfClass:[NSString class]]){
                        url = [NSURL URLWithString:latest[@"url"]];
                    }
                    if( [latest[@"status_id"] isKindOfClass:[NSNumber class]]){
                        RZLog(RZLogInfo, @"Blog message %@ with URL: %@", latest[@"status_id"], latest[@"url"]);
                        
                    }
                }
                [GCAppGlobal recentRemoteMessagesReceived];
            }
            
            SFSafariViewController * vc = RZReturnAutorelease([[SFSafariViewController alloc] initWithURL:url]);
            [self presentViewController:vc animated:YES completion:^(){}];
        }
    }else if(section == GC_SECTION_OTHER){
        if(indexPath.row == GC_SETTINGS_BUGREPORT ){
            [self showBugReport];
        } else if (indexPath.row == GC_SETTINGS_HELP){
            GCSettingsHelpViewController * detail = [GCSettingsHelpViewController helpViewControllerFor:nil];
            if (self.splitViewController) {
                GCSplitViewController*sp = (GCSplitViewController*)self.splitViewController;
                [sp.activityDetailViewController.navigationController pushViewController:detail animated:YES];
            }else{
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
    }else if (section == GC_SECTION_PARAMS){
        if(indexPath.row == GC_SETTINGS_UNITS){
            NSArray * systems = [GCViewConfig unitSystemDescriptions];
            NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_UNIT_SYSTEM defaultValue:GCUnitSystemDefault];
            GCCellEntryListViewController * choices = [GCViewConfig standardEntryListViewController:systems selected:selected];
            choices.entryFieldDelegate = self;
            choices.identifierInt = GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_UNITS);
            [self.navigationController pushViewController:choices animated:YES];
        }else if( indexPath.row == GC_SETTINGS_SKIN){
            NSArray * skins = [GCViewConfigSkin availableSkinNames];
            NSString * skin = [[GCAppGlobal profile] configGetString:CONFIG_SKIN_NAME defaultValue:kGCSkinNameOriginal];
            NSUInteger selected = [skins indexOfObject:skin];
            GCCellEntryListViewController * choices = [GCViewConfig standardEntryListViewController:skins selected:selected];
            choices.entryFieldDelegate = self;
            choices.identifierInt = GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_SKIN);
            [self.navigationController pushViewController:choices animated:YES];
        }else if(indexPath.row == GC_SETTINGS_PERIOD){
            NSArray * choices = [GCViewConfig periodDescriptions];
            NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_PERIOD_TYPE defaultValue:0];
            GCCellEntryListViewController * choicesC = [GCViewConfig standardEntryListViewController:choices selected:selected];
            choicesC.entryFieldDelegate = self;
            choicesC.identifierInt = GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_PERIOD);
            [self.navigationController pushViewController:choicesC animated:YES];
        }else if(indexPath.row == GC_SETTINGS_FIRSTDAY){
            NSArray * choices = [GCViewConfig weekStartDescriptions];
            NSUInteger selected = [GCViewConfig weekDayIndex:[GCAppGlobal configGetInt:CONFIG_FIRST_DAY_WEEK defaultValue:1]];
            GCCellEntryListViewController * choicesC = [GCViewConfig standardEntryListViewController:choices selected:selected];
            choicesC.entryFieldDelegate = self;
            choicesC.identifierInt = GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_FIRSTDAY);
            [self.navigationController pushViewController:choicesC animated:YES];
        }else if(indexPath.row==GC_SETTINGS_FILTER){
            GCSettingsFilterViewController * filter = [[GCSettingsFilterViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:filter animated:YES];
            [filter release];
        }else if(indexPath.row==GC_SETTINGS_LAPS){
            BOOL current = [GCAppGlobal configGetBool:CONFIG_USE_MOVING_ELAPSED defaultValue:false];
            [GCAppGlobal configSet:CONFIG_USE_MOVING_ELAPSED boolVal:!current];
            [GCAppGlobal saveSettings];
        }else if(indexPath.row==GC_SETTINGS_STRIDE){
            NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_STRIDE_STYLE defaultValue:GCUnitStrideSameFoot];
            NSArray * types = [GCUnit strideStyleDescriptions];
            GCCellEntryListViewController * choices = [GCViewConfig standardEntryListViewController:types selected:selected];
            choices.entryFieldDelegate = self;
            choices.identifierInt = GC_IDENTIFIER(GC_SECTION_PARAMS, GC_SETTINGS_STRIDE);
            [self.navigationController pushViewController:choices animated:YES];
        }

    }else if (section == GC_SECTION_ADVANCED){
        if (indexPath.row==GC_SETTINGS_RELOAD) {
            GCSettingsReloadViewController * detail = [[[GCSettingsReloadViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            [self.navigationController pushViewController:detail animated:YES];
        }else if(indexPath.row==GC_SETTINGS_MAP){
            NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_USE_MAP defaultValue:gcMapBoth];
            NSArray * types = [GCViewConfig mapTypes];
            GCCellEntryListViewController * choices = [GCViewConfig standardEntryListViewController:types selected:selected];
            choices.entryFieldDelegate = self;
            choices.identifierInt = GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_MAP);
            [self.navigationController pushViewController:choices animated:YES];
        }else if (indexPath.row==GC_SETTINGS_FONT_STYLE){
            if ([RZViewConfig fontStyle] == gcFontStyleDynamicType) {
                [RZViewConfig setFontStyle: gcFontStyleHelveticaNeue];
                [GCAppGlobal configSet:CONFIG_FONT_STYLE intVal:gcFontStyleHelveticaNeue];
                [GCAppGlobal saveSettings];
            }else{
                [RZViewConfig setFontStyle: gcFontStyleDynamicType];
                [GCAppGlobal configSet:CONFIG_FONT_STYLE intVal:gcFontStyleDynamicType];
                [GCAppGlobal saveSettings];
            }
            [tableView reloadData];
        }else if (indexPath.row == GC_SETTINGS_LANGUAGE){
            NSUInteger selected = [GCAppGlobal configGetInt:CONFIG_LANGUAGE_SETTING defaultValue:gcLanguageSettingAsDownloaded];
            NSArray * types = [GCViewConfig languageSettingChoices];
            GCCellEntryListViewController * choices = [GCViewConfig standardEntryListViewController:types selected:selected];
            choices.entryFieldDelegate = self;
            choices.identifierInt = GC_IDENTIFIER(GC_SECTION_ADVANCED, GC_SETTINGS_LANGUAGE);
            [self.navigationController pushViewController:choices animated:YES];

        }
    }else if (section == GC_SECTION_LOG){
        if (indexPath.row == GC_SETTINGS_SHOW_LOG) {
            GCSettingsLogViewController * detail = [[[GCSettingsLogViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            if ([UIViewController useIOS7Layout]) {
                [UIViewController setupEdgeExtendedLayout:detail];
            }
            UINavigationController * nav = [GCAppGlobal currentNavigationController];
            if (nav == nil) {
                nav = self.navigationController;
            }
            [nav pushViewController:detail animated:YES];
        }else if(indexPath.row == GC_SETTINGS_TRIGGER_ACTION){

            GCDebugActionsTableViewController * vc = [[[GCDebugActionsTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
            UINavigationController * nav = [GCAppGlobal currentNavigationController];
            if (nav == nil) {
                nav = self.navigationController;
            }
            [nav pushViewController:vc animated:YES];


        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self reloadView];
    });
}

-(void)showBugReport{
    RZLogStatus stat = RZLogCheckStatus();
    if (stat.exists) {
#if TARGET_IPHONE_SIMULATOR
        [GCWebConnect sanityCheck];
        NSLog(@"%@", RZLogFileContent());
#endif
        NSString * msg = NSLocalizedString(@"Submitting a bug report will send some debug diagnostic. It does not contains any of your activity data and will help make this app better. Thank you!",nil);
        if ([GCAppGlobal configGetBool:CONFIG_BUG_INCLUDE_DATA defaultValue:true]) {
            msg = NSLocalizedString(@"Submitting a bug report will send some debug diagnostic. It will help make this app better. Thank you!",nil);
        }
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Bug Report", @"Bug Report")
                                                                        message:msg
                                                                 preferredStyle:UIAlertControllerStyleAlert];


        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Bug Report")
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * action){

                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Submit", @"Bug Report")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction*action){
                                                    NSArray * errors = [GCActivitiesCacheManagement errorFiles];

                                                    if (errors.count && ![GCAppGlobal configGetBool:CONFIG_BUG_INCLUDE_DATA defaultValue:true]) {
                                                        [self showBugReportConfirm];
                                                    }else{
                                                        [self showBugReport:NO];
                                                    }

                                                }]];

        [self presentViewController:alert animated:YES completion:^(){}];
    }else{
        [self presentSimpleAlertWithTitle:NSLocalizedString(@"Bug Report", @"Bug Report")
                                  message:NSLocalizedString(@"No Diagnostic to report at this time", @"Bug Report")];
    }
}

-(void)showBugReportConfirm{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Parse Error Data", @"Bug Report")
                                                                    message:NSLocalizedString(@"Some data that failed to parse was detected. These may include some of your activity data. Do you want to include them in the report?", @"Bug Report")
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Exclude", @"Bug Report")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action){
                                                [self showBugReport:NO];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Include", @"Bug Report")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                [self showBugReport:YES];
                                            }]];
    [self presentViewController:alert animated:YES completion:^(){}];
}

-(void)showBugReport:(BOOL)include{
    GCSettingsBugReportViewController * bug = [[GCSettingsBugReportViewController alloc] initWithNibName:nil bundle:nil];
    bug.parent = self;
    bug.includeErrorFiles = include;
    if ([GCAppGlobal configGetBool:CONFIG_BUG_INCLUDE_DATA defaultValue:true]) {
        bug.includeErrorFiles=true;
        bug.includeActivityFiles=true;
    }
    [[GCAppGlobal currentNavigationController] pushViewController:bug animated:YES];
    [bug release];
}

-(void)reloadView{
    [self.tableView reloadData];
}

-(UINavigationController*)baseNavigationController{
	return( self.navigationController );
}
-(UINavigationItem*)baseNavigationItem{
	return( self.navigationItem );
}

-(void)notifyCallBack:(id)theParent{
    [self buildRemap];
    dispatch_async( dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self.tableView reloadData];
}

@end
