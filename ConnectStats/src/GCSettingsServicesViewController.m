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
#import "GCStravaActivityTransfer.h"
#import "GCWebConnect+Requests.h"
#import "GCService.h"
#import "GCSportTracksBase.h"
#import "GCSplitViewController.h"
#import "GCSettingsManualLoginViewController.h"
#import "GCHealthKitRequest.h"
#import "GCHealthKitSourcesRequest.h"
#import "GCSettingsSourceTableViewController.h"
#import "GCActivitiesOrganizer.h"
#import "GCHealthOrganizer.h"

#define GC_SECTIONS_GARMIN      0
#define GC_SECTIONS_STRAVA      1
#define GC_SECTIONS_HEALTHKIT   2
#define GC_SECTIONS_SPORTTRACKS 3
#define GC_SECTIONS_FITBIT      4
#define GC_SECTIONS_WITHINGS    5
#define GC_SECTIONS_BABOLAT     6
#define GC_SECTIONS_OPTIONS     7
#define GC_SECTIONS_END         8

#define GC_SPORTTRACKS_SERVICE_NAME 0
#define GC_SPORTTRACKS_ENABLE       1
#define GC_SPORTTRACKS_END          2

#define GC_GARMIN_SERVICE_NAME  0
#define GC_GARMIN_ENABLE        1
#define GC_GARMIN_USERNAME      2
#define GC_GARMIN_PASSWORD      3
#define GC_GARMIN_METHOD        4
#define GC_GARMIN_MANUAL_LOGIN  5
#define GC_GARMIN_MODERN_API    6
#define GC_GARMIN_END           7

#define GC_STRAVA_NAME      0
#define GC_STRAVA_ENABLE    1
#define GC_STRAVA_AUTO      2
#define GC_STRAVA_LOGOUT    3
#define GC_STRAVA_SEGMENTS  4
#define GC_STRAVA_END       5
//Disabled
#define GC_STRAVA_PRIVATE   6

#define GC_HEALTHKIT_NAME       0
#define GC_HEALTHKIT_ENABLE     1
#define GC_HEALTHKIT_WORKOUT    2
#define GC_HEALTHKIT_SOURCE     3
#define GC_HEALTHKIT_END        4

#define GC_FITBIT_NAME          0
#define GC_FITBIT_ENABLE        1
#define GC_FITBIT_SEARCH_OLDER  2
#define GC_FITBIT_END           3

#define GC_BABOLAT_SERVICE_NAME 0
#define GC_BABOLAT_ENABLE       1
#define GC_BABOLAT_USERNAME     2
#define GC_BABOLAT_PWD          3
#define GC_BABOLAT_END          4

#define GC_OPTIONS_MERGE         0
#define GC_OPTIONS_END           1

// for withings
#define GC_ROW_SERVICE_NAME 0
#define GC_ROW_AUTO         1
#define GC_ROW_LOGIN        2
#define GC_ROW_PWD          3
#define GC_ROW_USER         4
#define GC_ROW_STATUS       5
#define GC_ROW_END          6


@interface GCSettingsServicesViewController ()
@property (nonatomic,retain) RZTableIndexRemap * remap;
@end

@interface GCSettingsServicesViewController ()
@property (nonatomic,assign) BOOL changedName;
@property (nonatomic,assign) BOOL changedPwd;

@property (nonatomic,assign) BOOL showGarmin;
@property (nonatomic,assign) BOOL showStrava;
@property (nonatomic,assign) BOOL showSportTracks;
@property (nonatomic,assign) BOOL showBabolat;
@property (nonatomic,assign) BOOL showWithings;
@property (nonatomic,assign) BOOL showHealthKit;
@property (nonatomic,assign) BOOL showFitbit;

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
        self.showSportTracks = false;
        self.showStrava      = false;
        self.showWithings    = false;
        self.showHealthKit   = false;
        self.showFitbit      = false;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];


        self.remap = [RZTableIndexRemap tableIndexRemap];
        BOOL connectStatsVersion = [GCAppGlobal connectStatsVersion];
        BOOL healthStatsVersion  = [GCAppGlobal healthStatsVersion];

        if (connectStatsVersion) {
            gcGarminLoginMethod method = (gcGarminLoginMethod)[[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:GARMINLOGIN_DEFAULT];
            if (method != gcGarminLoginMethodDirect) {
                [self.remap addSection:GC_SECTIONS_GARMIN withRows:@[
                                                                     @( GC_GARMIN_SERVICE_NAME  ),
                                                                     @( GC_GARMIN_ENABLE        ),
                                                                     @( GC_GARMIN_USERNAME      ),
                                                                     @( GC_GARMIN_PASSWORD      ),
                                                                     @( GC_GARMIN_METHOD        ),
                                                                     @( GC_GARMIN_MODERN_API    ),
                                                                     //@( GC_GARMIN_MANUAL_LOGIN  )
                                                                     ]];
            }else{
                [self.remap addSection:GC_SECTIONS_GARMIN withRows:@[
                                                                     @( GC_GARMIN_SERVICE_NAME  ),
                                                                     @( GC_GARMIN_ENABLE        ),
                                                                     @( GC_GARMIN_USERNAME      ),
                                                                     @( GC_GARMIN_PASSWORD      ),
                                                                     @( GC_GARMIN_MODERN_API    ),
                                                                     ]];

            }
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

            [self.remap addSection:GC_SECTIONS_SPORTTRACKS withRows:@[
                                                                      @( GC_SPORTTRACKS_SERVICE_NAME ),
                                                                      @( GC_SPORTTRACKS_ENABLE       )
                                                                      ]];
        }

#ifdef GC_USE_HEALTHKIT
        if (healthStatsVersion) {
            self.showHealthKit   = true;

            [self.remap addSection:GC_SECTIONS_HEALTHKIT withRows:@[
                                                                    @( GC_HEALTHKIT_NAME       ),
                                                                    @( GC_HEALTHKIT_ENABLE     ),
                                                                    @( GC_HEALTHKIT_WORKOUT    ),
                                                                    @( GC_HEALTHKIT_SOURCE     )]];
            [self.remap addSection:GC_SECTIONS_FITBIT withRows:@[
                                                                 @( GC_FITBIT_NAME          ),
                                                                 @( GC_FITBIT_SEARCH_OLDER  ),
                                                                 @( GC_FITBIT_ENABLE        ) ]];
            if ([[GCAppGlobal configGetString:CONFIG_ENABLE_DEBUG defaultValue:@""] isEqualToString:CONFIG_ENABLE_DEBUG_ON]) {
                [self.remap addSection:GC_SECTIONS_GARMIN withRows:@[
                                                                     @( GC_GARMIN_SERVICE_NAME  ),
                                                                     @( GC_GARMIN_ENABLE        ),
                                                                     @( GC_GARMIN_USERNAME      ),
                                                                     @( GC_GARMIN_PASSWORD      ),
                                                                     @( GC_GARMIN_METHOD        ),
                                                                     //@( GC_GARMIN_MANUAL_LOGIN  )
                                                                     ]];
                [self.remap addSection:GC_SECTIONS_STRAVA withRows:@[
                                                                     @( GC_STRAVA_NAME      ),
                                                                     @( GC_STRAVA_ENABLE    ),
                                                                     @( GC_STRAVA_AUTO      ),
                                                                     @( GC_STRAVA_LOGOUT    ) ]];

            }

        }

#endif
        // for withings
#ifdef WITHINGS_OAUTH
        [self.remap addSection:GC_SECTIONS_WITHINGS withRows:@[
                                                               @( GC_ROW_SERVICE_NAME ),
                                                               @( GC_ROW_AUTO         ),
                                                               @( GC_ROW_STATUS       )]];
#else
        [self.remap addSection:GC_SECTIONS_WITHINGS withRows:@[
                                                               @( GC_ROW_SERVICE_NAME ),
                                                               @( GC_ROW_AUTO         ),
                                                               @( GC_ROW_LOGIN        ),
                                                               @( GC_ROW_PWD          ),
                                                               @( GC_ROW_USER         ),
                                                               @( GC_ROW_STATUS       )]];
#endif
        if (connectStatsVersion) {

            [self.remap addSection:GC_SECTIONS_OPTIONS withRows:@[
                                                                  @( GC_OPTIONS_MERGE         )]];
            [self.remap addSection:GC_SECTIONS_BABOLAT withRows:@[
                                                                  @( GC_BABOLAT_SERVICE_NAME ),
                                                                  @( GC_BABOLAT_ENABLE       ),
                                                                  @( GC_BABOLAT_USERNAME     ),
                                                                  @( GC_BABOLAT_PWD          )]];

        }


    }
    return self;
}

-(void)dealloc{
    [[GCAppGlobal web] detach:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_remap release];

    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    }else if (section == GC_SECTIONS_SPORTTRACKS){
        return self.showSportTracks ? nrows : 1;
    }else if (section == GC_SECTIONS_HEALTHKIT){
        return self.showHealthKit ? nrows : 1;
    }else if (section == GC_SECTIONS_OPTIONS){
        return nrows;
    }else if (section == GC_SECTIONS_FITBIT){
        return self.showFitbit ? nrows : 1;
    }
    // Return the number of rows in the section.
    return 0;
}

-(GCCellEntryText*)textCell:(UITableView*)tableView{
    GCCellEntryText * cell = (GCCellEntryText*)[tableView dequeueReusableCellWithIdentifier:@"GCText"];
    if (cell == nil) {
        cell = [[[GCCellEntryText alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCText"] autorelease];
    }
    return cell;
}


-(GCCellGrid*)gridCell:(UITableView*)tableView{
    GCCellGrid*cell=(GCCellGrid*)[tableView dequeueReusableCellWithIdentifier:@"GCGrid"];
    if (cell==nil) {
        cell=[[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCGrid"] autorelease  ];
    }
    return cell;
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
        switchcell.label.text = NSLocalizedString(@"Auto Refresh", @"Settings");
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

            BOOL error = false;

            if ([[GCAppGlobal profile] serviceSuccess:service] && error==false) {
                title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Setup successful",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
                NSUInteger count = [GCAppGlobal health].measures.count;
                NSString * subm = [NSString stringWithFormat:NSLocalizedString(@"%d measures",@"Withings Status"), count];
                sub = [[[NSAttributedString alloc] initWithString:subm attributes:[GCViewConfig attribute14Gray]] autorelease];
            }else{
                title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Press to login",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
                sub = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"No successful login yet",@"Services") attributes:[GCViewConfig attribute14Gray]] autorelease];
                if (error) {
                    sub = [GCViewConfig attributedString:@"An error occured - no successful login yet" attribute:@selector(attribute14Gray)];
                }
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

    gcService service= gcServiceGarmin;

    if (indexPath.row == GC_GARMIN_SERVICE_NAME) {
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Garmin Connect",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForService:service]
                                                                      attributes:[GCViewConfig attribute14Gray]] autorelease];
        [gridcell setIconImage:[UIImage imageNamed:@"garmin"]];

        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        rv= gridcell;
    }else if (indexPath.row == GC_GARMIN_ENABLE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Download Activities",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_ENABLE defaultValue:true];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_GARMIN_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }else if (indexPath.row == GC_GARMIN_MODERN_API) {
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Alternative API",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_GARMIN_USE_MODERN defaultValue:true];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_GARMIN_MODERN_API);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_GARMIN_METHOD) {
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:2];

        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login Method",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];

        [gridcell labelForRow:0 andCol:0].attributedText = title;
        gcGarminLoginMethod method = (gcGarminLoginMethod)[[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:GARMINLOGIN_DEFAULT];
        NSArray * methods = [GCViewConfig validChoicesForGarminLoginMethod];
        if (method < methods.count) {
            [gridcell labelForRow:0 andCol:1].text = methods[method];
        }else{
            [gridcell labelForRow:0 andCol:1].text = NSLocalizedString(@"Unknown",@"Login Method");
        }
        rv = gridcell;
    }else if (indexPath.row == GC_GARMIN_USERNAME){
        textcell = [GCCellEntryText textCell:tableView];
        [textcell.label setText:NSLocalizedString(@"Login Name", @"")];
        rv = textcell;
        textcell.textField.secureTextEntry = NO;
        (textcell.textField).text = [[GCAppGlobal profile] currentLoginNameForService:gcServiceGarmin];
        [textcell setIdentifierInt:GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_USERNAME)];
        textcell.entryFieldDelegate = self;
    }else if (indexPath.row == GC_GARMIN_PASSWORD){
        textcell = [GCCellEntryText textCell:tableView];
        [textcell.label setText:NSLocalizedString(@"Password", @"")];
        textcell.textField.secureTextEntry = YES;
        (textcell.textField).text = [[GCAppGlobal profile] currentPasswordForService:gcServiceGarmin];
        [textcell setIdentifierInt:GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_PASSWORD)];
        textcell.entryFieldDelegate = self;
        rv = textcell;
    }else if (indexPath.row==GC_GARMIN_MANUAL_LOGIN){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];

        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Manual Login",@"Services")
                                                                      attributes:[GCViewConfig attributeBold16]] autorelease];

        NSString * msg = NSLocalizedString(@"Used to investigate login failures",@"Services");
        NSAttributedString * details = [[[NSAttributedString alloc] initWithString:msg
                                                                        attributes:[GCViewConfig attribute14Gray]] autorelease];

        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = details;
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
        switchcell.label.text = NSLocalizedString(@"Download Activities",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }else if (indexPath.row == GC_STRAVA_SEGMENTS){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Download Segments",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_SEGMENTS defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_SEGMENTS);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;

    }else if (indexPath.row == GC_STRAVA_AUTO) {
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Upload Activities",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_AUTO defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_AUTO);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_STRAVA_PRIVATE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Export as private",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_SHARING_STRAVA_PRIVATE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_STRAVA_PRIVATE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_STRAVA_LOGOUT){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSDate * last = [GCStravaActivityTransfer lastSync:nil];
        if (last) {
            // Message for upload
            [gridcell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"Signout", @"Other Service") attribute:@selector(attributeBold16)];
            NSString * msg = [NSString stringWithFormat:NSLocalizedString(@"Last sync %@", @"Other Service"), last];
            [gridcell labelForRow:1 andCol:0].attributedText = [GCViewConfig attributedString:msg attribute:@selector(attribute14Gray)];
        }else{
            // Message for download
            if ([[GCAppGlobal profile] serviceSuccess:service]){
                [gridcell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"Logged in", @"Other Service") attribute:@selector(attributeBold16)] ;
                if ([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:false]) {
                    [gridcell labelForRow:1 andCol:0].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"Pull down activity list to refresh activities", @"Strava Info") attribute:@selector(attribute14Gray)];
                }
            }else{
                [gridcell labelForRow:0 andCol:0].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"Never logged in - Tap to start", @"Other Service") attribute:@selector(attributeBold16)] ;
                if ([[GCAppGlobal profile] configGetBool:CONFIG_STRAVA_ENABLE defaultValue:false]) {
                    [gridcell labelForRow:1 andCol:0].attributedText = [GCViewConfig attributedString:NSLocalizedString(@"Or pull down activity list to login and download", @"Strava Info") attribute:@selector(attribute14Gray)];
                }
            }
        }
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
            switchcell.label.text = NSLocalizedString(@"Use Health Data",@"Other Service");
            switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_ENABLE defaultValue:[GCAppGlobal healthStatsVersion]];
            switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_HEALTHKIT_ENABLE);
            switchcell.entryFieldDelegate = self;
            rv=switchcell;
        }else{
            gridcell = [GCCellGrid gridCell:tableView];
            [gridcell setupForRows:1 andCols:1];
            [gridcell labelForRow:0 andCol:0].text = NSLocalizedString(@"Not Supported by device", @"Other Service");
            rv= gridcell;
        }
    }else if (indexPath.row == GC_HEALTHKIT_WORKOUT){
        if ([GCHealthKitRequest isSupported]) {
            switchcell = [GCCellEntrySwitch switchCell:tableView];
            switchcell.label.text = NSLocalizedString(@"Include Workouts",@"Other Service");
            switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_HEALTHKIT_WORKOUT defaultValue:[GCAppGlobal healthStatsVersion]];
            switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_HEALTHKIT_WORKOUT);
            switchcell.entryFieldDelegate = self;
            rv=switchcell;
        }else{
            gridcell = [GCCellGrid gridCell:tableView];
            [gridcell setupForRows:1 andCols:1];
            [gridcell labelForRow:0 andCol:0].text = NSLocalizedString(@"Not Supported by device", @"Other Service");
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
            [gridcell labelForRow:0 andCol:0].text = NSLocalizedString(@"Not Supported by device", @"Other Service");
            rv= gridcell;
        }
    }

    return rv;
}

-(UITableViewCell*)fitbitTableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell * rv = nil;
    GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;
    gcService service = gcServiceFitBit;

    if (indexPath.row == GC_FITBIT_NAME) {
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = nil;
        NSAttributedString * status = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withString:[self statusForService:service]];
        title = [NSAttributedString attributedString:[GCViewConfig attributeBold16] withString:@"FitBit"];
        [gridcell setIconImage:[UIImage imageNamed:@"fitbit"]];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        gridcell.iconPosition = gcIconPositionRight;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv= gridcell;

    }else if (indexPath.row == GC_FITBIT_ENABLE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Use FitBit",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_FITBIT_ENABLE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_FITBIT_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }else if (indexPath.row == GC_FITBIT_SEARCH_OLDER){
        gridcell = [GCCellGrid gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = nil;
        NSDate * last = [[GCAppGlobal organizer] oldestActivity].date;
        NSAttributedString * status = [NSAttributedString attributedString:[GCViewConfig attribute14Gray] withFormat:NSLocalizedString(@"Before %@", @"FitBit Old Date"), [last dateShortFormat]];
        title = [NSAttributedString attributedString:[GCViewConfig attributeBold16] withString:NSLocalizedString(@"Search Older Days", @"")];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        gridcell.iconPosition = gcIconPositionRight;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv= gridcell;

    }

    return rv;
}

- (UITableViewCell *)sportTracksTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * rv = nil;
    //GCCellEntryText * textcell = nil;
    GCCellGrid * gridcell = nil;
    GCCellEntrySwitch * switchcell = nil;
    //GCCellActivityIndicator * activitycell = nil;
    gcService service = gcServiceSportTracks;
    if (indexPath.row ==GC_SPORTTRACKS_SERVICE_NAME) {
        gridcell =[self gridCell:tableView];
        [gridcell setupForRows:2 andCols:1];
        NSAttributedString * title = nil;
        NSAttributedString * status = [[[NSAttributedString alloc] initWithString:[self statusForService:service]
                                                                       attributes:[GCViewConfig attribute14Gray]] autorelease];

        title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"SportTracks",@"Services") attributes:[GCViewConfig attributeBold16]] autorelease];
        [gridcell setIconImage:[UIImage imageNamed:@"sporttracks"]];
        [gridcell labelForRow:0 andCol:0].attributedText = title;
        [gridcell labelForRow:1 andCol:0].attributedText = status;
        gridcell.iconPosition = gcIconPositionRight;
        [GCViewConfig setupGradientForDetails:gridcell];
        rv = gridcell;
    }else if (indexPath.row == GC_SPORTTRACKS_ENABLE){
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Download Activities",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_SPORTTRACKS_ENABLE defaultValue:false];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_SPORTTRACKS_ENABLE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
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
        switchcell.label.text = NSLocalizedString(@"Enable",@"Other Service");
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

    if (indexPath.row == GC_OPTIONS_MERGE) {
        switchcell = [GCCellEntrySwitch switchCell:tableView];
        switchcell.label.text = NSLocalizedString(@"Ignore Duplicate on Download",@"Other Service");
        switchcell.toggle.on = [[GCAppGlobal profile] configGetBool:CONFIG_MERGE_IMPORT_DUPLICATE defaultValue:true];
        switchcell.identifierInt = GC_IDENTIFIER([indexPath section], GC_OPTIONS_MERGE);
        switchcell.entryFieldDelegate = self;
        rv=switchcell;
    }

    return rv;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    if (indexPath.section == GC_SECTIONS_WITHINGS) {
        return [self withingsTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_GARMIN){
        return [self garminTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section==GC_SECTIONS_STRAVA){
        return [self stravaTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_SPORTTRACKS){
        return [self sportTracksTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_BABOLAT){
        return [self babolatTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_OPTIONS){
        return [self optionsTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_HEALTHKIT){
        return [self healthKitTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (indexPath.section == GC_SECTIONS_FITBIT){
        return [self fitbitTableView:tableView cellForRowAtIndexPath:indexPath];
    }

    return [GCCellGrid gridCell:tableView];
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
            [[GCAppGlobal profile] configSet:CONFIG_GARMIN_LOGIN_METHOD intVal:[cell selected]];
            RZLog(RZLogInfo, @"Garmin: Changed Method %lu", (unsigned long)[cell selected]);
            [GCAppGlobal saveSettings];
            [[GCAppGlobal web] garminLogin];
            break;

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
            if([[GCAppGlobal profile] configToggleBool:CONFIG_GARMIN_ENABLE]){
                RZLog(RZLogInfo, @"Garmin: Enabled");
            }else{
                RZLog(RZLogInfo, @"Garmin: Disabled");
            }
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_MODERN_API):
            if([[GCAppGlobal profile] configToggleBool:CONFIG_GARMIN_USE_MODERN]){
                RZLog(RZLogInfo, @"Garmin: Modern");
            }else{
                RZLog(RZLogInfo, @"Garmin: Legacy");
            }
            [GCAppGlobal saveSettings];
            break;
        case GC_IDENTIFIER(GC_SECTIONS_SPORTTRACKS, GC_SPORTTRACKS_ENABLE):
            [[GCAppGlobal profile] configToggleBool:CONFIG_SPORTTRACKS_ENABLE];
            [GCAppGlobal saveSettings];
            if ([[GCAppGlobal profile] configGetBool:CONFIG_SPORTTRACKS_ENABLE defaultValue:NO] == NO) {
                [GCSportTracksBase signout];
            }
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
        case GC_IDENTIFIER(GC_SECTIONS_OPTIONS, GC_OPTIONS_MERGE):
        {
            [[GCAppGlobal profile] configToggleBool:CONFIG_MERGE_IMPORT_DUPLICATE];
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
        case GC_IDENTIFIER(GC_SECTIONS_FITBIT, GC_FITBIT_ENABLE):
        {
            [[GCAppGlobal profile] configToggleBool:CONFIG_FITBIT_ENABLE];
            [GCAppGlobal saveSettings];
            break;
        }

    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
-(UINavigationController*)baseNavigationController{
	return( self.navigationController );
}
-(UINavigationItem*)baseNavigationItem{
	return( self.navigationItem );
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
        }else if (indexPath.section==GC_SECTIONS_SPORTTRACKS){
            self.showSportTracks = ! self.showSportTracks;
        }else if (indexPath.section==GC_SECTIONS_HEALTHKIT){
            self.showHealthKit = ! self.showHealthKit;
        }else if (indexPath.section==GC_SECTIONS_FITBIT){
            self.showFitbit = ! self.showFitbit;
        }
        [tableView reloadData];
    }

    if (indexPath.section==GC_SECTIONS_WITHINGS&&indexPath.row==GC_ROW_STATUS) {
        if (self.updating == false) {
            self.updating = true;
            [[GCAppGlobal web] withingsUpdate];
            [self.tableView reloadData];
        }
    }else if (indexPath.section==GC_SECTIONS_GARMIN && indexPath.row==GC_GARMIN_METHOD){
        GCCellEntryListViewController * list = [GCCellEntryListViewController entryListViewController:[GCViewConfig validChoicesForGarminLoginMethod] selected:[[GCAppGlobal profile] configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:gcGarminLoginMethodDirect]];
        list.entryFieldDelegate = self;
        list.identifierInt = GC_IDENTIFIER(GC_SECTIONS_GARMIN, GC_GARMIN_METHOD);
        [self.navigationController pushViewController:list animated:YES];
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
            GCCellEntryListViewController * lc = [GCCellEntryListViewController entryListViewController:choices selected:selected];
            lc.subtext = subtext;
            lc.entryFieldDelegate = self;
            lc.identifierInt= GC_IDENTIFIER(GC_SECTIONS_WITHINGS, GC_ROW_USER);
            [self.navigationController pushViewController:lc animated:YES];
        }
    }else if (indexPath.section==GC_SECTIONS_STRAVA&&indexPath.row==GC_STRAVA_LOGOUT){
        NSDate * last = [GCStravaActivityTransfer lastSync:nil];
        if (last) {
            [GCStravaActivityTransfer signout];
        }else{
            [GCAppGlobal searchAllActivities];
        }
    }else if (indexPath.section==GC_SECTIONS_GARMIN&&indexPath.row == GC_GARMIN_MANUAL_LOGIN){
        GCSettingsManualLoginViewController * detail = [[GCSettingsManualLoginViewController alloc] initWithNibName:nil bundle:nil];
        if (self.splitViewController) {
            GCSplitViewController*sp = (GCSplitViewController*)self.splitViewController;
            [sp.activityDetailViewController.navigationController pushViewController:detail animated:YES];
        }else{
            [self.navigationController pushViewController:detail animated:YES];
        }
        [detail release];

    }else if (indexPath.section == GC_SECTIONS_FITBIT && indexPath.row == GC_FITBIT_SEARCH_OLDER){
        [[GCAppGlobal web] fitBitUpdateFromDate:[[GCAppGlobal organizer] oldestActivity].date];
    }else if (indexPath.section == GC_SECTIONS_HEALTHKIT && indexPath.row == GC_HEALTHKIT_SOURCE){
        GCSettingsSourceTableViewController * source = [[GCSettingsSourceTableViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:source animated:YES];
        [source release];
    }
}

-(void)notifyCallBack:(id)theParent{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    if ([theInfo.stringInfo isEqualToString:NOTIFY_END]) {
        self.updating = false;
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPathI{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    if (self.updating && indexPath.section == GC_SECTIONS_WITHINGS && indexPath.row == GC_ROW_STATUS) {
        return [GCCellActivityIndicator height];
    }

    return 58.;
}


@end
