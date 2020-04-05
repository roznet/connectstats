//  MIT Licence
//
//  Created on 09/02/2013.
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

#import "GCSettingsServicesViewController.h"
#import "GCCellGrid+Templates.h"
#import "GCAppGlobal.h"
#import "GCWebConnect+Requests.h"
#import "GCService.h"
#import "GCSportTracksBase.h"
#import "GCSplitViewController.h"
#import "GCHealthKitRequest.h"
#import "GCHealthKitSourcesRequest.h"
#import "GCSettingsSourceTableViewController.h"
#import "GCActivitiesOrganizer.h"
#import "GCHealthOrganizer.h"
#import "GCStravaReqBase.h"
#import "GCWebUrl.h"
#import "GCDebugServiceKeys.h"
#import "GCCellEntryText+GCViewConfig.h"
#import "GCConnectStatsRequest.h"
#import "GCWithingsReqBase.h"
#import "GCSettingsHelpViewController.h"

#import "GCSettingsServicesViewConstants.h"

@interface GCSettingsServicesViewController ()
@property (nonatomic,retain) RZTableIndexRemap * remap;
@end

@interface GCSettingsServicesViewController ()
@property (nonatomic,assign) BOOL changedName;
@property (nonatomic,assign) BOOL changedPwd;

@property (nonatomic,assign) BOOL showGarmin;
@property (nonatomic,assign) BOOL showStrava;
@property (nonatomic,assign) BOOL showBabolat;
@property (nonatomic,assign) BOOL showWithings;
@property (nonatomic,assign) BOOL showHealthKit;
@property (nonatomic,assign) BOOL showConnectStats;

@end

@implementation GCSettingsServicesViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        [[GCAppGlobal web] attach:self];
        self.showBabolat     = false;
        self.showGarmin      = false;
        self.showStrava      = false;
        self.showWithings    = false;
        self.showHealthKit   = false;
        self.showConnectStats = false;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];
        
        [self buildRemap];
        
    }
    return self;
}

-(void)dealloc{
    [[GCAppGlobal web] detach:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_remap release];

    [super dealloc];
}

-(void)buildRemap{
    self.remap = [RZTableIndexRemap tableIndexRemap];

    BOOL debugIsEnabled = [[GCAppGlobal configGetString:CONFIG_ENABLE_DEBUG defaultValue:CONFIG_ENABLE_DEBUG_OFF] isEqualToString:CONFIG_ENABLE_DEBUG_ON];
    
    NSMutableArray * dynamic = [NSMutableArray arrayWithArray:
                                @[
                                    @( GC_GARMIN_SERVICE_NAME  ),
                                    @( GC_GARMIN_ENABLE        ),
                                    @( GC_GARMIN_METHOD        ),
                                ]
                                ];
    
    if (debugIsEnabled) {
        [dynamic addObject:@(GC_CONNECTSTATS_CONFIG)];
        
        GCDebugServiceKeys * debugKeys = [GCDebugServiceKeys serviceKeys];
        if( debugKeys.hasDebugKeys ){
            [dynamic addObject:@(GC_CONNECTSTATS_DEBUGKEY)];
        }
    }
    if( [[GCAppGlobal profile] serviceEnabled:gcServiceGarmin]){
        [dynamic addObjectsFromArray:@[
            @( GC_GARMIN_USERNAME      ),
            @( GC_GARMIN_PASSWORD      ),
        ]
         ];
    }
    if( [[GCAppGlobal profile] serviceEnabled:gcServiceConnectStats]){
        [dynamic addObjectsFromArray:@[
            @( GC_CONNECTSTATS_LOGOUT ),
        ] ];
    }
    [dynamic addObjectsFromArray:@[
        @( GC_CONNECTSTATS_HELP   ),
    ] ];

    [self.remap addSection:GC_SECTIONS_GARMIN withRows:dynamic];
    
    
    if( [[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_AUTO defaultValue:NO] == YES){
        // OBSOLETE: Only showed if AUTO was on before, should not be used anymore
        [self.remap addSection:GC_SECTIONS_STRAVA withRows:@[
                                                             @( GC_STRAVA_NAME      ),
                                                             @( GC_STRAVA_ENABLE    ),
                                                             @( GC_STRAVA_AUTO      ),
                                                             @( GC_STRAVA_LOGOUT    ) ]];
        // OBSOLETE: Only showed if AUTO was on before, should not be used anymore
    }else{
        [self.remap addSection:GC_SECTIONS_STRAVA withRows:@[
                                                             @( GC_STRAVA_NAME      ),
                                                             @( GC_STRAVA_ENABLE    ),
                                                             //@( GC_STRAVA_SEGMENTS   ),
                                                             @( GC_STRAVA_LOGOUT    ) ]];
        
    }
    
    if ([GCAppGlobal healthKitStore]) {
        [self.remap addSection:GC_SECTIONS_HEALTHKIT withRows:@[
                                                                @( GC_HEALTHKIT_NAME       ),
                                                                @( GC_HEALTHKIT_ENABLE     ),
                                                                @( GC_HEALTHKIT_WORKOUT    ),
                                                                @( GC_HEALTHKIT_SOURCE     )]];
    }
        
    // for withings
    [self.remap addSection:GC_SECTIONS_WITHINGS withRows:@[
                                                           @( GC_ROW_SERVICE_NAME ),
                                                           @( GC_ROW_AUTO         ),
                                                           @( GC_ROW_STATUS       )]];

    [self.remap addSection:GC_SECTIONS_OPTIONS withRows:@[
        @( GC_OPTIONS_DOWNLOAD_DETAILS ),
        @( GC_OPTIONS_DUPLICATE_IMPORT ),
        @( GC_OPTIONS_DUPLICATE_LOAD   ),
    ]];
    if( debugIsEnabled ){
        [self.remap addSection:GC_SECTIONS_BABOLAT withRows:@[
            @( GC_BABOLAT_SERVICE_NAME ),
            @( GC_BABOLAT_ENABLE       ),
            @( GC_BABOLAT_USERNAME     ),
            @( GC_BABOLAT_PWD          )]];
    }
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionI
{
    NSInteger nrows = [self.remap numberOfRowsInSection:sectionI];
    NSInteger section = [self.remap section:sectionI];
    if (section == GC_SECTIONS_WITHINGS) {
        return self.showWithings ? nrows : 1;
    }else if (section == GC_SECTIONS_BABOLAT){
        return self.showBabolat ? nrows : 1 ;
    }else if (section == GC_SECTIONS_GARMIN){
        return self.showGarmin ? nrows : 1;
    }else if (section == GC_SECTIONS_STRAVA){
        return self.showStrava ? nrows : 1;
    }else if (section == GC_SECTIONS_HEALTHKIT){
        return self.showHealthKit ? nrows : 1;
    }else if (section == GC_SECTIONS_OPTIONS){
        return nrows;
    }
    // Return the number of rows in the section.
    return 0;
}

-(GCCellEntryText*)textCell:(UITableView*)tableView{
    return [GCCellEntryText textCellViewConfig:tableView];
}


-(GCCellGrid*)gridCell:(UITableView*)tableView{
    return [GCCellGrid gridCell:tableView];
}

-(NSString*)statusForGarmin{
    gcGarminDownloadSource source = [GCViewConfig garminDownloadSource];
    switch( source ){
        case gcGarminDownloadSourceEnd:
            return NSLocalizedString(@"Tap to setup", @"Service Status");
        case gcGarminDownloadSourceConnectStats:
            return [self statusForService:gcServiceConnectStats];
        case gcGarminDownloadSourceGarminWeb:
            return [self statusForService:gcServiceGarmin];
        case gcGarminDownloadSourceBoth:
            if( [[GCAppGlobal profile] serviceSuccess:gcServiceGarmin] && [[GCAppGlobal profile] serviceSuccess:gcServiceConnectStats]){
                return NSLocalizedString(@"Connected Successfully", @"Service status");
            }else if( [[GCAppGlobal profile] serviceIncomplete:gcServiceGarmin] || [[GCAppGlobal profile] serviceIncomplete:gcServiceConnectStats]){
                return NSLocalizedString(@"Needs More Inputs", @"Service status");
            }else{
                NSLocalizedString(@"Enabled", @"Service status");
            }
    }
    return NSLocalizedString(@"Tap to setup", @"Service Status");
}

-(NSString*)statusForService:(gcService)service{
    NSString * rv = NSLocalizedString(@"Tap to setup", @"Service Status");
    if ([[GCAppGlobal profile] serviceEnabled:service]) {
        if ([[GCAppGlobal profile] serviceSuccess:service]) {
            rv = NSLocalizedString(@"Connected Successfully", @"Service status");
        }else if ([[GCAppGlobal profile] serviceIncomplete:service]){
            rv = NSLocalizedString(@"Needs More Inputs", @"Service status");
        }else{
            rv = NSLocalizedString(@"Enabled", @"Service status");
        }
    }
    return rv;
}

-(NSArray<NSString*>*)validYearsForBackfill{
    NSInteger year = [[GCAppGlobal calculationCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSMutableArray * years = [NSMutableArray arrayWithObject:NSLocalizedString(@"No Backfill, Use Website", @"Valid Years")];
    for (NSInteger i = MIN(2100,MAX(year,2005)); i>=2005; i--) {
        [years addObject:[NSString stringWithFormat:@"%@", @(i)]];
    }
    return years;
}

-(void)setupServiceStatusCell:(GCCellGrid*)gridCell forService:(GCService*)service secondary:(GCService*)secondary{
    NSDictionary * summaryDict = [[GCAppGlobal organizer] serviceSummary];
    NSDictionary * details = summaryDict[ service.displayName ];
    NSString * subtitle = NSLocalizedString(@"No activities", @"Service Summary");
    if( details ){
        if( secondary != nil && summaryDict[ secondary.displayName ] ){
            NSDictionary * secondDetails = summaryDict[ secondary.displayName ];
            
            subtitle = [NSString stringWithFormat:@"%@+%@ activities, latest %@", details[@"count"], secondDetails[@"count"], [details[@"latest"] dateShortFormat]];
        }else{
            subtitle = [NSString stringWithFormat:@"%@ activities, latest %@", details[@"count"], [details[@"latest"] dateShortFormat]];
        }
    }

    NSString * title = nil;
    
    if( [[GCAppGlobal profile] serviceSuccess:service.service] ){
        title = NSLocalizedString(@"Successfully Logged in - Tap to logout",@"Services");
    }else{
        if( details ){
            title = NSLocalizedString(@"Previously Logged in - Tap to start again", @"Service" );
        }else{
            title = NSLocalizedString(@"Never Logged in - Tap to start", @"Service" );
        }
    }
    
    [gridCell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attributeBold16] withString:title];
    [gridCell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withString:subtitle];
}


- (UITableViewCell *)withingsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * rv = nil;
    GCCellEntryText * textcell = nil;
    GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;
    GCCellActivityIndicator * activitycell = nil;

    gcService service = gcServiceWithings;

    if (indexPath.row ==GC_ROW_SERVICE_NAME) {
        gridcell =[self gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];

        NSAttributedString * title = nil;
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForService:service]
                                                                       attributes:[GCViewConfig attribute14Gray]] autorelease];

        title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Withings", @"Service") attributes:[GCViewConfig attributeBold16]] autorelease];
        [gridcell setIconImage:[UIImage imageNamed:@"withings"]];

        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        gridcell.iconPosition = gcIconPositionRight;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv = gridcell;
    }else if (indexPath.row == GC_ROW_LOGIN) {
        textcell = [self textCell:tableView];
        [textcell.label setText:NSLocalizedString(@"Login Name", @"")];

        textcell.textField.secureTextEntry = NO;
        (textcell.textField).text = [[GCAppGlobal profile] currentLoginNameForService:service];
        [textcell setIdentifierInt:GC_IDENTIFIER([indexPath section], GC_ROW_LOGIN)];
        textcell.entryFieldDelegate = self;
        rv = textcell;
    }else if(indexPath.row == GC_ROW_PWD){
        textcell = [self textCell:tableView];
        [textcell.label setText:NSLocalizedString(@"Password", @"")];
        textcell.textField.secureTextEntry = YES;
        (textcell.textField).text = [[GCAppGlobal profile] currentPasswordForService:service];
        [textcell setIdentifierInt:GC_IDENTIFIER([indexPath section],GC_ROW_PWD)];
        textcell.entryFieldDelegate = self;
        rv = textcell;
    }else if(indexPath.row == GC_ROW_USER){
        gridcell =[self gridCell:tableView];
        [gridcell setupForRows:2 andCols:2];
        [gridcell setIconImage:nil];
        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"User",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
        NSString * val = [[GCAppGlobal profile] configGetString:CONFIG_WITHINGS_USER defaultValue:@""];
        NSAttributedString * uname =[[[NSAttributedString alloc] initWithString:val attributes:[GCViewConfig attribute16]] autorelease];
        NSArray * users=[[GCAppGlobal profile] configGetArray:CONFIG_WITHINGS_USERSLIST defaultValue:@[]];

        [gridcell labelForRow:0 andCol:0].attributedText=title;
        [gridcell labelForRow:0 andCol:1].attributedText=uname;
        NSString * desc = NSLocalizedString(@"No users", @"Services");
        if (users.count>0) {
            desc = [NSString stringWithFormat:@"%d users available", (int)users.count];

        }
        [gridcell labelForRow:1 andCol:0].attributedText = [[[NSAttributedString alloc] initWithString:desc
                                                                                            attributes:[GCViewConfig attribute14Gray]] autorelease];
        rv=gridcell;
    }else if(indexPath.row == GC_ROW_AUTO){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Auto Refresh", @"Settings")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_WITHINGS_AUTO defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_ROW_AUTO);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if(indexPath.row == GC_ROW_STATUS){
        if (self.updating) {
            activitycell = [GCCellActivityIndicator activityIndicatorCell:tableView parent:[GCAppGlobal web]];
            rv=activitycell;

        }else{

            gridcell =[self gridCell:tableView];
            [gridcell setupForRows:2 andCols:1];
            [gridcell setIconImage:nil];

            NSAttributedString * title = nil;
            NSAttributedString * sub   = nil;

            if ([[GCAppGlobal profile] serviceSuccess:gcServiceWithings]) {
                title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Setup successful - Tap to Logout",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
                NSArray<GCHealthMeasure*>*measures = [GCAppGlobal health].measures;
                NSUInteger count = measures.count;
                GCHealthMeasure * latest = measures.firstObject;
                NSString * subm = [NSString stringWithFormat:NSLocalizedString(@"%d measures, latest %@",@"Withings Status"), count, [latest.date dateShortFormat]];
                sub = [[[NSAttributedString alloc] initWithString:subm attributes:[GCViewConfig attribute14Gray]] autorelease];
            }else{
                title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Tap to login",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
                sub = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"No successful login yet",@"Services") attributes:[GCViewConfig attribute14Gray]] autorelease];
            }

            [gridcell labelForRow:0 andCol:0].attributedText = title;
            [gridcell labelForRow:1 andCol:0].attributedText = sub;
            gridcell.iconPosition = gcIconPositionRight;
            rv = gridcell;
        }
    }
    // Configure the cell...
    return rv;
}
- (UITableViewCell *)garminTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * rv = nil;
    GCCellEntryText * textcell = nil;
    GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;
    //GCCellActivityIndicator * activitycell = nil;

    if (indexPath.row == GC_GARMIN_SERVICE_NAME) {
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Garmin Connect",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForGarmin]
                                                                      attributes:[GCViewConfig attribute14Gray]] autorelease];
        [gridcell setIconImage:[UIImage imageNamed:@"garmin"]];

        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        rv= gridcell;
    }else if (indexPath.row == GC_GARMIN_ENABLE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        gcGarminDownloadSource source = [GCViewConfig garminDownloadSource];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Download Activities",@"Other Service")];
        switchcell.toggle.on = (source != gcGarminDownloadSourceEnd);
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_GARMIN_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }else if (indexPath.row == GC_GARMIN_MODERN_API) {
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Modern API",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_USE_MODERN defaultValue:true];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_GARMIN_MODERN_API);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_GARMIN_METHOD) {
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:2];

        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Source",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];

        [gridcell labelForRow:0 andCol:0].attributedText = title;
        gcGarminDownloadSource source = [GCViewConfig garminDownloadSource];
        NSString * method = [GCViewConfig describeGarminSource:source];
        [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                     withString:method];
        if( source == gcGarminDownloadSourceBoth || source == gcGarminDownloadSourceConnectStats){
            [gridcell labelForRow:1 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withString:@"Weather Powered by DarkSky.net"];
        }
        rv = gridcell;
    }else if (indexPath.row == GC_GARMIN_USERNAME){
        textcell = [GCCellEntryText textCellViewConfig:tableView];
        [textcell.label setText:NSLocalizedString(@"Login Name", @"")];
        rv = textcell;
        textcell.textField.secureTextEntry = NO;
        (textcell.textField).text = [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin];
        [textcell setIdentifierInt:GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_USERNAME)];
        textcell.entryFieldDelegate = self;
    }else if (indexPath.row == GC_GARMIN_PASSWORD){
        textcell = [GCCellEntryText textCellViewConfig:tableView];
        [textcell.label setText:NSLocalizedString(@"Password", @"")];
        textcell.textField.secureTextEntry = YES;
        (textcell.textField).text = [[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin];
        [textcell setIdentifierInt:GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_PASSWORD)];
        textcell.entryFieldDelegate = self;
        rv = textcell;
    }
    if( rv == nil){
        return [self connectStatsTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return rv;
}

-(UITableViewCell*)connectStatsTableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell * rv = nil;
    //GCCellEntryText * textcell = nil;
    GCCellGrid * gridcell = nil;
    //GCCellEntrySwitch * switchcell = nil;
    //GCCellActivityIndicator * activitycell = nil;

    gcService service = gcServiceConnectStats;
    
    if (indexPath.row == GC_CONNECTSTATS_NAME) {
        gridcell =[self gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = nil;
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForService:service]
                                                                       attributes:[GCViewConfig attribute14Gray]] autorelease];
        
        title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Test Garmin via ConnectStats",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
        [gridcell setIconImage:[UIImage imageNamed:@"garmin"]];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        gridcell.iconPosition = gcIconPositionRight;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv = gridcell;
    /*}else if (indexPath.row == GC_CONNECTSTATS_ENABLE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Download Activities",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_CONNECTSTATS_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;*/
    }else if (indexPath.row == GC_CONNECTSTATS_USE ){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:2];
        
        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Use service for",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];
        
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        gcConnectStatsServiceUse method = (gcConnectStatsServiceUse)[[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_USE defaultValue:gcConnectStatsServiceUseValidate];
        NSArray * methods = [GCViewConfig validChoicesForConnectStatsServiceUse];
        if (method < methods.count) {
            [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:methods[method]];
        }else{
            [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:NSLocalizedString(@"Unknown",@"Login Method")];
        }
        rv = gridcell;
    }else if (indexPath.row == GC_CONNECTSTATS_CONFIG ){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:2];
        
        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Config",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];
        
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        gcWebConnectStatsConfig method = (gcWebConnectStatsConfig)[[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_CONFIG   defaultValue:gcWebConnectStatsConfigProduction];
        NSArray * methods = [GCViewConfig validChoicesForConnectStatsConfig];
        if (method < methods.count) {
            [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:methods[method]];
        }else{
            [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:NSLocalizedString(@"Unknown",@"Login Method")];
        }
        

        NSAttributedString * sample = [[[NSAttributedString alloc] initWithString:GCWebConnectStatsSearch(method)
                                                                       attributes:[GCViewConfig attribute14Gray]] autorelease];
        [gridcell labelForRow:1 andCol:0].attributedText = sample;
        [gridcell configForRow:1 andCol:0].horizontalOverflow = true;
        rv = gridcell;

    }else if( indexPath.row == GC_CONNECTSTATS_FILLYEAR){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:2];
        
        NSInteger year = (gcConnectStatsServiceUse)[[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_FILLYEAR defaultValue:CONFIG_CONNECTSTATS_NO_BACKFILL];

        if( year == CONFIG_CONNECTSTATS_NO_BACKFILL ){
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Backfill",@"Services")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];
            [gridcell labelForRow:0 andCol:0].attributedText = title;
            NSString * timeString = [NSString stringWithFormat:@"History will be downloaded from Garmin Connect"];
            [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:@"Disabled"];
            [gridcell labelForRow:1 andCol:0].attributedText = [[[NSAttributedString alloc] initWithString:timeString attributes:[GCViewConfig attribute14Gray]] autorelease];
            [gridcell configForRow:1 andCol:0].horizontalOverflow = true;

        }else{
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Backfill since ",@"Services")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];
            [gridcell labelForRow:0 andCol:0].attributedText = title;
            NSDate * startDate = [NSDate dateForDashedDate:[NSString stringWithFormat:@"%@-01-01", @(year )]];
            NSTimeInterval timeToCover = [[NSDate date] timeIntervalSinceDate:startDate];
            NSTimeInterval timeToBackFill = timeToCover / ( 90.0 * 3600.0 * 24.0) * 120.0;// 2min per 90 days
            GCNumberWithUnit * nu = [GCNumberWithUnit numberWithUnit:GCUnit.second andValue:timeToBackFill];
            
            NSString * timeString = [NSString stringWithFormat:@"Required initial time to synchronise %@", nu];
            [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:[NSString stringWithFormat:@"%@", @(year)]];
            [gridcell labelForRow:1 andCol:0].attributedText = [[[NSAttributedString alloc] initWithString:timeString attributes:[GCViewConfig attribute14Gray]] autorelease];
            [gridcell configForRow:1 andCol:0].horizontalOverflow = true;
        }
        rv = gridcell;

    }else if( indexPath.row == GC_CONNECTSTATS_DEBUGKEY){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:2];
        
        NSUInteger userId = [[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_USER_ID defaultValue:0];
        NSUInteger tokenId = [[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_TOKEN_ID defaultValue:0];
        NSString * current = [NSString stringWithFormat:@"token_id=%lu user_id=%lu", tokenId, userId];

        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Choose Debug Key ",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];
        NSAttributedString * subtitle = [[[NSAttributedString alloc] initWithString:current
                                                                      attributes:[GCViewConfig attribute14Gray]] autorelease];

        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = subtitle;
        rv = gridcell;
    }else if( indexPath.row == GC_CONNECTSTATS_LOGOUT){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];

        [self setupServiceStatusCell:gridcell forService:[GCService service:gcServiceConnectStats] secondary:[GCService service:gcServiceGarmin]];
        
        rv = gridcell;
    }else if( indexPath.row == GC_CONNECTSTATS_HELP){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];

        NSAttributedString * title = [NSAttributedString attributedString:[GCViewConfig attribute16] withString:NSLocalizedString(@"Garmin Service Setup Help", @"ConnectStats Help")];
        //NSAttributedString * subtitle = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withString:NSLocalizedString(@"Information about the different options", @"ConnectStats Help")];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        //[gridcell labelForRow:1 andCol:0].attributedText = subtitle;
        rv = gridcell;
    }
    
    return rv;
}


- (UITableViewCell *)stravaTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * rv = nil;
    //GCCellEntryText * textcell = nil;
    GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;
    //GCCellActivityIndicator * activitycell = nil;

    gcService service = gcServiceStrava;

    if (indexPath.row ==GC_STRAVA_NAME) {
        gridcell =[self gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = nil;
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForService:service]
                                                                       attributes:[GCViewConfig attribute14Gray]] autorelease];

        title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Strava",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
        [gridcell setIconImage:[UIImage imageNamed:@"strava"]];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        gridcell.iconPosition = gcIconPositionRight;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv = gridcell;
    }else if (indexPath.row == GC_STRAVA_ENABLE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Download Activities",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }else if (indexPath.row == GC_STRAVA_SEGMENTS){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Download Segments",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_SEGMENTS defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_SEGMENTS);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }else if (indexPath.row == GC_STRAVA_AUTO) {
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Upload Activities",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_AUTO defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_AUTO);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_STRAVA_PRIVATE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Export as private",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_PRIVATE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_PRIVATE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_STRAVA_LOGOUT){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        [self setupServiceStatusCell:gridcell forService:[GCService service:gcServiceStrava] secondary:nil];
        
        rv=gridcell;
    }
    return rv;
}

-(UITableViewCell*)healthKitTableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell * rv = nil;
    GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;
    gcService service = gcServiceHealthKit;

    if (indexPath.row == GC_HEALTHKIT_NAME) {
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = nil;
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForService:service]
                                                                       attributes:[GCViewConfig attribute14Gray]] autorelease];

        title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"HealthKit",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
        [gridcell setIconImage:[UIImage imageNamed:@"HealthHeart"]];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        gridcell.iconPosition = gcIconPositionRight;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv= gridcell;

    }else if (indexPath.row == GC_HEALTHKIT_ENABLE){
        if ([GCHealthKitRequest isSupported]) {
            switchcell = [GCCellEntrySwitch switchCell:tableView];
            switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                        withString:NSLocalizedString(@"Use Health Data",@"Other Service")];
            switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_ENABLE defaultValue:[GCAppGlobal healthStatsVersion]];
            switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_HEALTHKIT_ENABLE);
            switchcell.entryFieldDelegate = self;
            rv=switchcell;
        }else{
            gridcell = [GCCellGrid gridCell:tableView];
            [gridcell setupForRows:1 andCols:1];
            [gridcell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:NSLocalizedString(@"Not Supported by device", @"Other Service")];
            rv= gridcell;
        }
    }else if (indexPath.row == GC_HEALTHKIT_WORKOUT){
        if ([GCHealthKitRequest isSupported]) {
            switchcell = [GCCellEntrySwitch switchCell:tableView];
            switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                        withString:NSLocalizedString(@"Include Workouts",@"Other Service")];
            switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_WORKOUT defaultValue:[GCAppGlobal healthStatsVersion]];
            switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_HEALTHKIT_WORKOUT);
            switchcell.entryFieldDelegate = self;
            rv=switchcell;
        }else{
            gridcell = [GCCellGrid gridCell:tableView];
            [gridcell setupForRows:1 andCols:1];
            [gridcell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:NSLocalizedString(@"Not Supported by device", @"Other Service")];
            rv= gridcell;
        }
    }else if (indexPath.row == GC_HEALTHKIT_SOURCE){
        if ([GCHealthKitRequest isSupported]) {
            gridcell = [GCCellGrid gridCell:tableView];
            [gridcell setupForRows:1 andCols:2];
            NSString * source = [[GCAppGlobal profile] configGetString:PROFILE_CURRENT_SOURCE defaultValue:@""];
            if (source.length == 0) {
                if([[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_SOURCE_CHECKED defaultValue:false]){
                    source = NSLocalizedString(@"Not Set", @"Source");
                }else{
                    source = NSLocalizedString(@"Analysing, please wait...", @"Source");
                }
            }else{
                source = [[GCAppGlobal profile] sourceName:source];
            }
            [gridcell labelForRow:0 andCol:1].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:source];
            [gridcell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attributeBold16]
                                                                                         withString: NSLocalizedString(@"Source", @"Other Service")];
            rv= gridcell;
        }else{
            gridcell = [GCCellGrid gridCell:tableView];
            [gridcell setupForRows:1 andCols:1];
            [gridcell labelForRow:0 andCol:0].attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                                         withString:NSLocalizedString(@"Not Supported by device", @"Other Service")];
            rv= gridcell;
        }
    }

    return rv;
}

- (UITableViewCell *)babolatTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * rv = nil;
    GCCellEntryText * textcell = nil;
    GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;
    //GCCellActivityIndicator * activitycell = nil;

    gcService service = gcServiceBabolat;

    if (indexPath.row == GC_BABOLAT_SERVICE_NAME){
        gridcell =[self gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = nil;
        title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Babolat",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForService:service]
                                                                       attributes:[GCViewConfig attribute14Gray]] autorelease];

        //[gridcell setIconImage:[UIImage imageNamed:@"strava"]];
        //[gridcell setIconPosition:gcIconPositionLeft];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv = gridcell;

    }else if (indexPath.row == GC_BABOLAT_USERNAME){
        textcell = [self textCell:tableView];
        [textcell.label setText:NSLocalizedString(@"Login Name", @"")];

        textcell.textField.secureTextEntry = NO;
        (textcell.textField).text = [[GCAppGlobal profile] currentLoginNameForService:service];
        [textcell setIdentifierInt:GC_IDENTIFIER([indexPath section], GC_BABOLAT_USERNAME)];
        textcell.entryFieldDelegate = self;
        rv = textcell;
    }else if(indexPath.row == GC_BABOLAT_PWD){
        textcell = [self textCell:tableView];
        [textcell.label setText:NSLocalizedString(@"Password", @"")];
        textcell.textField.secureTextEntry = YES;
        (textcell.textField).text = [[GCAppGlobal profile] currentPasswordForService:service];
        [textcell setIdentifierInt:GC_IDENTIFIER([indexPath section],GC_BABOLAT_PWD)];
        textcell.entryFieldDelegate = self;
        rv = textcell;
    }else if(indexPath.row == GC_BABOLAT_ENABLE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Enable",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_BABOLAT_ENABLE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_BABOLAT_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }
    return rv;
}

-(UITableViewCell*)optionsTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * rv = nil;
    //GCCellEntryText * textcell = nil;
    //GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;

    if (indexPath.row == GC_OPTIONS_DUPLICATE_IMPORT) {
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Ignore Duplicate from Services",@"Other Service")];
        if( [[GCAppGlobal profile] configGetBool:CONFIG_DUPLICATE_CHECK_ON_IMPORT defaultValue:true] ){
            switchcell.detailTextLabel.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString(@"Save only one version of duplicates", @"Other Service")];
        }else{
            switchcell.detailTextLabel.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString(@"Save all versions of duplicates", @"Other Service")];
        }
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_DUPLICATE_CHECK_ON_IMPORT defaultValue:true];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_OPTIONS_DUPLICATE_IMPORT);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_OPTIONS_DUPLICATE_LOAD){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Ignore Existing Duplicate",@"Other Service")];
        if( [[GCAppGlobal profile] configGetBool:CONFIG_DUPLICATE_CHECK_ON_LOAD defaultValue:true] ){
            switchcell.detailTextLabel.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString(@"Hide existing duplicates", @"Other Service")];
        }else{
            switchcell.detailTextLabel.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString(@"Show existing duplicates", @"Other Service")];
        }
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_DUPLICATE_CHECK_ON_LOAD defaultValue:true];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_OPTIONS_DUPLICATE_LOAD);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }else if (indexPath.row == GC_OPTIONS_DOWNLOAD_DETAILS) {
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.attributedText = [NSAttributedString attributedString:[GCViewConfig attribute16]
                                                                    withString:NSLocalizedString(@"Download Details Pre-emptively",@"Other Service")];
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_WIFI_DOWNLOAD_DETAILS defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_OPTIONS_DOWNLOAD_DETAILS);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }
    
    return rv;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    UITableViewCell * rv = nil;
    
    if (indexPath.section == GC_SECTIONS_WITHINGS) {
        rv = [self withingsTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_GARMIN){
        rv = [self garminTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section==GC_SECTIONS_STRAVA){
        rv = [self stravaTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_BABOLAT){
        rv = [self babolatTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_OPTIONS){
        rv = [self optionsTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_HEALTHKIT){
        rv = [self healthKitTableView:tableView cellForRowAtIndexPath:indexPath];
    }else{
        rv = [GCCellGrid gridCell:tableView];
    }
    rv.backgroundColor = [GCViewConfig defaultColor:gcSkinDefaultColorBackground];
    return rv;
}
-(UINavigationController*)baseNavigationController{
    return( self.navigationController );
}
-(UINavigationItem*)baseNavigationItem{
    return( self.navigationItem );
}


-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    gcService service = gcServiceWithings;

    switch ([cell identifierInt]) {
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_USERNAME):
            if (![[cell text] isEqualToString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin]]) {
                [[GCAppGlobal profile] configSet:PROFILE_NAME_PWD_SUCCESS boolVal:false];
                [[GCAppGlobal profile] setLoginName:[cell text] forService:gcServiceGarmin];
                _changedName = true;
                NSArray * specialChars = [cell.text specialCharacters];
                if (specialChars.count) {
                    RZLog(RZLogInfo, @"Garmin: Changed Username with special char %@", [specialChars componentsJoinedByString:@", "]);
                }else{
                    RZLog(RZLogInfo, @"Garmin: Changed Username");
                }
                if (_changedPwd) {
                    _changedName = false;
                    _changedPwd  = false;
                    [cell resignFirstResponder];
                    [GCAppGlobal login];
                }else{
                    [[GCAppGlobal web] garminLogin];
                }
            }
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_PASSWORD):
            if (![[cell text] isEqualToString:[[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin]]) {
                [[GCAppGlobal profile] configSet:PROFILE_NAME_PWD_SUCCESS boolVal:false];
                [[GCAppGlobal profile] setPassword:[cell text] forService:gcServiceGarmin];
                _changedPwd = true;
                NSArray * specialChars = [cell.text specialCharacters];
                if (specialChars.count) {
                    RZLog(RZLogInfo, @"Garmin: Changed Password with special char %@", [specialChars componentsJoinedByString:@", "]);
                }else{
                    RZLog(RZLogInfo, @"Garmin: Changed Password");
                }

                if (_changedName) {
                    _changedName = false;
                    _changedPwd  = false;
                    [cell resignFirstResponder];
                    [GCAppGlobal login];
                }else{
                    [[GCAppGlobal web] garminLogin];
                }
            }
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_METHOD):
        {
            [GCViewConfig setGarminDownloadSource:[cell selected]];
            // adapt choices to new source
            [self buildRemap];
            
            [[GCAppGlobal profile] configSet:CONFIG_GARMIN_LAST_SOURCE intVal:cell.selected];
            NSString * choice = [GCViewConfig describeGarminSource:cell.selected];
            RZLog(RZLogInfo, @"Garmin: Changed Source %@ Web=%lu ConnectStats=%lu",
                  choice,
                  (long unsigned)[[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:false],
                  (long unsigned)[[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:false]
                  );
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_WITHINGS, GC_ROW_LOGIN):
            if (![[cell text] isEqualToString:[[GCAppGlobal profile] currentLoginNameForService:service]]) {
                [[GCAppGlobal profile] serviceSuccess:service set:NO];
                [[GCAppGlobal profile] setLoginName:[cell text] forService:service];
                [GCAppGlobal saveSettings];
            }
            break;
        case GC_IDENTIFIER(GC_SECTIONS_WITHINGS,GC_ROW_PWD):
            if (![[cell text] isEqualToString:[[GCAppGlobal profile] currentPasswordForService:service]]) {
                [[GCAppGlobal profile] serviceSuccess:service set:NO];
                [[GCAppGlobal profile] setPassword:[cell text] forService:service];
                [GCAppGlobal saveSettings];
            }
            break;
        case GC_IDENTIFIER(GC_SECTIONS_WITHINGS, GC_ROW_AUTO):
            [[GCAppGlobal profile] configToggleBool:CONFIG_WITHINGS_AUTO];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_ENABLE):
        {
            if( cell.on ){
                gcGarminDownloadSource lastSource = [[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LAST_SOURCE defaultValue:gcGarminDownloadSourceBoth];
                [GCViewConfig setGarminDownloadSource:lastSource];
                
                RZLog(RZLogInfo, @"Garmin: Enabled Source %@ Web=%lu ConnectStats=%lu",
                      [GCViewConfig describeGarminSource:lastSource],
                      (long unsigned)[[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:false],
                      (long unsigned)[[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:false]
                      );
            }else{
                // Make sure we save the last source used
                gcGarminDownloadSource lastSource = [GCViewConfig garminDownloadSource];
                [[GCAppGlobal profile] configSet:CONFIG_GARMIN_LAST_SOURCE intVal:lastSource];
                [GCViewConfig setGarminDownloadSource:gcGarminDownloadSourceEnd];
                RZLog(RZLogInfo, @"Garmin: Disabled Source %@ Web=%lu ConnectStats=%lu",
                      [GCViewConfig describeGarminSource:lastSource],
                      (long unsigned)[[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:false],
                      (long unsigned)[[GCAppGlobal profile] configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:false]
                      );
            }
            
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_MODERN_API):
            if([[GCAppGlobal profile] configToggleBool:CONFIG_GARMIN_USE_MODERN]){
                RZLog(RZLogInfo, @"Garmin: Modern");
            }else{
                RZLog(RZLogInfo, @"Garmin: Legacy");
            }
            [GCAppGlobal saveSettings];
            break;

        case GC_IDENTIFIER(GC_SECTIONS_BABOLAT, GC_BABOLAT_ENABLE):
            [[GCAppGlobal profile] configToggleBool:CONFIG_BABOLAT_ENABLE];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_BABOLAT, GC_BABOLAT_USERNAME):
        {
            if (![[cell text] isEqualToString:[[GCAppGlobal profile] currentLoginNameForService:gcServiceBabolat]]) {
                [[GCAppGlobal profile] serviceSuccess:gcServiceBabolat set:NO];
                [[GCAppGlobal profile] setLoginName:[cell text] forService:gcServiceBabolat];
                [GCAppGlobal saveSettings];
            }
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_BABOLAT,GC_BABOLAT_PWD):
            if (![[cell text] isEqualToString:[[GCAppGlobal profile] currentPasswordForService:gcServiceBabolat]]) {
                [[GCAppGlobal profile] serviceSuccess:gcServiceBabolat set:NO];
                [[GCAppGlobal profile] setPassword:[cell text] forService:gcServiceBabolat];
                [GCAppGlobal saveSettings];
            }
            break;

        case GC_IDENTIFIER(GC_SECTIONS_WITHINGS, GC_ROW_USER):
        {
            if (self.updating == false) {
                NSString * user = [cell choices][[cell selected]];
                [GCAppGlobal configSet:CONFIG_WITHINGS_USER stringVal:user];
                self.updating = true;
                [[GCAppGlobal web] withingsChangeUser:user];
                [GCAppGlobal saveSettings];
            }
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_STRAVA, GC_STRAVA_AUTO):
            [[GCAppGlobal profile] configToggleBool:CONFIG_SHARING_STRAVA_AUTO];
            if ([[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_AUTO defaultValue:NO]==YES) {
                [[GCAppGlobal profile] configSet:CONFIG_STRAVA_ENABLE boolVal:NO];
            }
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_STRAVA, GC_STRAVA_PRIVATE):
            [[GCAppGlobal profile] configToggleBool:CONFIG_SHARING_STRAVA_PRIVATE];
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_STRAVA, GC_STRAVA_ENABLE):
            [[GCAppGlobal profile] configToggleBool:CONFIG_STRAVA_ENABLE];
            if ([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:NO]==YES) {
                RZLog(RZLogInfo,@"Strava: Enabled");
                [[GCAppGlobal profile] configSet:CONFIG_SHARING_STRAVA_AUTO boolVal:NO];
            }else{
                RZLog(RZLogInfo,@"Strava: Disabled");
            }
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_STRAVA, GC_STRAVA_SEGMENTS):
            [[GCAppGlobal profile] configToggleBool:CONFIG_STRAVA_SEGMENTS];
            if ([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_SEGMENTS defaultValue:NO]==YES) {
                RZLog(RZLogInfo,@"Strava Segments: Enabled");
            }else{
                RZLog(RZLogInfo,@"Strava Segments: Disabled");
            }
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_OPTIONS, GC_OPTIONS_DUPLICATE_IMPORT):
        {
            [[GCAppGlobal profile] configToggleBool:CONFIG_DUPLICATE_CHECK_ON_IMPORT];
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_OPTIONS, GC_OPTIONS_DUPLICATE_LOAD):
        {
            [[GCAppGlobal profile] configToggleBool:CONFIG_DUPLICATE_CHECK_ON_LOAD];
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_OPTIONS, GC_OPTIONS_DOWNLOAD_DETAILS):
        {
            
            [[GCAppGlobal profile] configToggleBool:CONFIG_WIFI_DOWNLOAD_DETAILS];
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_HEALTHKIT, GC_HEALTHKIT_ENABLE):
        {
            [[GCAppGlobal profile] configToggleBool:CONFIG_HEALTHKIT_ENABLE];
            if([[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_ENABLE defaultValue:[GCAppGlobal healthStatsVersion]]){
                [[GCAppGlobal web] addRequest:[GCHealthKitSourcesRequest request]];
                RZLog(RZLogInfo,@"Healthkit: Enabled");
            }else{
                RZLog(RZLogInfo,@"Healthkit: Disabled");
            }
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_HEALTHKIT, GC_HEALTHKIT_WORKOUT):
        {
            [[GCAppGlobal profile] configToggleBool:CONFIG_HEALTHKIT_WORKOUT];
            if([[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_WORKOUT defaultValue:[GCAppGlobal healthStatsVersion]]){
                RZLog(RZLogInfo,@"Healthkit: Workout Enabled");
            }else{
                RZLog(RZLogInfo,@"Healthkit: Workout Disabled");
            }
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_CONNECTSTATS_USE):
        {
            [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_USE intVal:cell.selected];
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_CONNECTSTATS_CONFIG):
        {
            [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_CONFIG intVal:cell.selected];
            [GCAppGlobal saveSettings];
            break;
        }

        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_CONNECTSTATS_FILLYEAR):
        {
            if( cell.selected == 0){
                [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_FILLYEAR intVal:CONFIG_CONNECTSTATS_NO_BACKFILL];
            }else{
                NSString * selected = [self validYearsForBackfill][cell.selected];
                [[GCAppGlobal profile] configSet:CONFIG_CONNECTSTATS_FILLYEAR intVal:selected.integerValue];
            }
            [GCAppGlobal saveSettings];
            break;
        }
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_CONNECTSTATS_DEBUGKEY):
        {
            NSUInteger index = cell.selected;
            GCDebugServiceKeys * debugKeys = [GCDebugServiceKeys serviceKeys];
            NSArray * available = debugKeys.availableTokenIds;
            if( cell.selected < available.count ){
                NSString * token_id = available[index];
                [debugKeys useKeyForTokenId:token_id];
            }
        }

    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    if (indexPath.row == 0) {
        if (indexPath.section == GC_SECTIONS_GARMIN) {
            self.showGarmin = ! self.showGarmin;
        }else if (indexPath.section==GC_SECTIONS_STRAVA){
            self.showStrava = ! self.showStrava;
        }else if (indexPath.section==GC_SECTIONS_WITHINGS){
            self.showWithings = ! self.showWithings;
        }else if (indexPath.section==GC_SECTIONS_BABOLAT){
            self.showBabolat = ! self.showBabolat;
        }else if (indexPath.section==GC_SECTIONS_HEALTHKIT){
            self.showHealthKit = ! self.showHealthKit;
        }
        [tableView reloadData];
    }

    if (indexPath.section==GC_SECTIONS_WITHINGS&&indexPath.row==GC_ROW_STATUS) {
        if( [[GCAppGlobal profile] serviceSuccess:gcServiceWithings] ){
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Confirm Logout" message:NSLocalizedString(@"Do you want to log out from withings",nil) preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addCancelAction];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Logout",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                RZLog(RZLogInfo, @"Log out of Withings");
                [GCWithingsReqBase signout];
            }]];
            [self presentViewController:alert animated:YES completion:nil];

        }else{
            if (self.updating == false) {
                self.updating = true;
                [[GCAppGlobal web] withingsUpdate];
                [self.tableView reloadData];
            }
        }
    }else if (indexPath.section==GC_SECTIONS_WITHINGS&&indexPath.row==GC_ROW_USER){
        NSArray * list = [[GCAppGlobal profile] configGetArray:CONFIG_WITHINGS_USERSLIST defaultValue:@[]];
        if (list.count > 0) {
            NSMutableArray * choices = [NSMutableArray arrayWithCapacity:list.count];
            NSMutableArray * subtext = [NSMutableArray arrayWithCapacity:list.count];
            NSString * current = [[GCAppGlobal profile] configGetString:CONFIG_WITHINGS_USER defaultValue:@""];
            NSUInteger selected = 0;
            NSUInteger idx = 0;
            for (NSDictionary * one in list) {
                NSString * shortname = one[@"shortname"];
                if (shortname) {
                    if ([shortname isEqualToString:current]) {
                        selected = idx;
                    }
                    NSString * name = [NSString stringWithFormat:@"%@ %@",  one[@"firstname"], one[@"lastname"]];
                    [choices addObject:shortname];
                    [subtext addObject:name];
                    idx++;
                }
            }
            GCCellEntryListViewController * lc = [GCViewConfig standardEntryListViewController:choices selected:selected];
            lc.subtext = subtext;
            lc.entryFieldDelegate = self;
            lc.identifierInt= GC_IDENTIFIER(GC_SECTIONS_WITHINGS, GC_ROW_USER);
            [self.navigationController pushViewController:lc animated:YES];
        }
    }else if (indexPath.section==GC_SECTIONS_STRAVA&&indexPath.row==GC_STRAVA_LOGOUT){
        if( [[GCAppGlobal profile] serviceSuccess:gcServiceStrava] ){
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Logout",nil) message:NSLocalizedString(@"Are you sure you want to log out from strava",nil) preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addCancelAction];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Logout",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                RZLog(RZLogInfo, @"Log out of Strava");
                [GCStravaReqBase signout];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [GCAppGlobal searchAllActivities];
        }
        [GCAppGlobal searchAllActivities];
    }else if (indexPath.section == GC_SECTIONS_HEALTHKIT && indexPath.row == GC_HEALTHKIT_SOURCE){
        GCSettingsSourceTableViewController * source = [[GCSettingsSourceTableViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:source animated:YES];
        [source release];
    }else if (indexPath.section==GC_SECTIONS_GARMIN && indexPath.row==GC_GARMIN_METHOD){
        gcGarminDownloadSource source = [GCViewConfig garminDownloadSource];
        if( source < gcGarminDownloadSourceEnd ){
            GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:[GCViewConfig validChoicesForGarminSource]
                                                                                        selected:source];
            list.entryFieldDelegate = self;
            list.identifierInt = GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_METHOD);
            [self.navigationController pushViewController:list animated:YES];
        }
    }else if (indexPath.section == GC_SECTIONS_GARMIN && indexPath.row == GC_CONNECTSTATS_LOGOUT){
        if( [[GCAppGlobal profile] serviceSuccess:gcServiceConnectStats] ){
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Logout",nil) message:NSLocalizedString(@"Do you want to log out from connectstats",nil) preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addCancelAction];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Logout",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                RZLog(RZLogInfo, @"Log out of ConnectStats");
                [GCConnectStatsRequest logout];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [GCAppGlobal searchAllActivities];
        }
    }else if( indexPath.section == GC_SECTIONS_GARMIN && indexPath.row == GC_CONNECTSTATS_USE){
        GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:[GCViewConfig validChoicesForConnectStatsServiceUse] selected:[[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_USE defaultValue:gcConnectStatsServiceUseValidate]];
        list.entryFieldDelegate = self;
        list.identifierInt = GC_IDENTIFIER(GC_SECTIONS_GARMIN,GC_CONNECTSTATS_USE);
        [self.navigationController pushViewController:list animated:YES];
    }else if( indexPath.section == GC_SECTIONS_GARMIN && indexPath.row == GC_CONNECTSTATS_CONFIG){
        GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:[GCViewConfig validChoicesForConnectStatsConfig] selected:[[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_CONFIG defaultValue:gcWebConnectStatsConfigProduction]];
        list.entryFieldDelegate = self;
        list.identifierInt = GC_IDENTIFIER(GC_SECTIONS_GARMIN,GC_CONNECTSTATS_CONFIG);
        [self.navigationController pushViewController:list animated:YES];
    }else if( indexPath.section == GC_SECTIONS_GARMIN && indexPath.row == GC_CONNECTSTATS_FILLYEAR){
        NSArray<NSString*>* years = [self validYearsForBackfill];
        NSUInteger index = 0;
        NSUInteger currentYear = [[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_FILLYEAR defaultValue:CONFIG_CONNECTSTATS_NO_BACKFILL];
        for (NSString * one in years) {
            if( one.integerValue == currentYear){
                break;
            }
            index++;
        }

        GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:[self validYearsForBackfill] selected:index];
        list.entryFieldDelegate = self;
        list.identifierInt = GC_IDENTIFIER(GC_SECTIONS_GARMIN,GC_CONNECTSTATS_FILLYEAR);
        [self.navigationController pushViewController:list animated:YES];
    }else if( indexPath.section == GC_SECTIONS_GARMIN && indexPath.row == GC_CONNECTSTATS_DEBUGKEY ){
        GCDebugServiceKeys * debugKeys = [GCDebugServiceKeys serviceKeys];
        NSArray<NSString*>*display = debugKeys.displayAvailableKeys;
        NSUInteger index = 0;
        NSUInteger current_token_id = [[GCAppGlobal profile] configGetInt:CONFIG_CONNECTSTATS_TOKEN_ID defaultValue:0];
        
        for (NSString * one in display) {
            if( one.integerValue == current_token_id){
                break;
            }
            index++;
        }
        if( index >= display.count){
            index = 0;
        }
        
        GCCellEntryListViewController * list = [GCViewConfig standardEntryListViewController:display selected:index];
        list.entryFieldDelegate = self;
        list.identifierInt = GC_IDENTIFIER(GC_SECTIONS_GARMIN,GC_CONNECTSTATS_DEBUGKEY);
        [self.navigationController pushViewController:list animated:YES];

    }else if( indexPath.section == GC_SECTIONS_GARMIN && indexPath.row == GC_CONNECTSTATS_HELP){
        NSURL * helpURL = [NSURL URLWithString:@"https://ro-z.net/blog/services-for-garmin-data"];
        GCSettingsHelpViewController * helpVC = [GCSettingsHelpViewController helpViewControllerFor:helpURL];
        [self.navigationController pushViewController:helpVC animated:YES];
    }
}

-(void)notifyCallBack:(id)theParent{
    [self buildRemap];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if ([theInfo.stringInfo isEqualToString:NOTIFY_END]) {
        self.updating = false;
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPathI{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    if (self.updating && indexPath.section == GC_SECTIONS_WITHINGS && indexPath.row == GC_ROW_STATUS) {
        return [GCCellActivityIndicator height];
    }

    return 58.;
}


@end
