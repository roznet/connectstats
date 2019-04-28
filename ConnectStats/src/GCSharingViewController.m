//  MIT Licence
//
//  Created on 12/01/2013.
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

#import "GCSharingViewController.h"
#import "GCExportGoogleEarth.h"
#import "GCAppGlobal.h"
#import "GCWebUrl.h"
#import <Social/Social.h>
@import RZExternal;
#import "GCActivity+ExportText.h"
#import <MessageUI/MessageUI.h>
#import "Flurry.h"
#import "GCActivityMetaValue.h"
#import "GCViewConfig.h"
#import "GCStravaActivityTransfer.h"
#import "GCSportTracksActivityUpload.h"
#import "GCWebConnect+Requests.h"
#import "GCService.h"
#import "GCActivitiesOrganizer.h"

#define GC_SECTION_SHARING 0
#define GC_SECTION_WAIT    1
#define GC_SECTION_INCLUDE 2
#define GC_SECTION_END     3

#define GC_SHARING_SHARE            0
#define GC_SHARING_GOOGLE_EARTH     1
#define GC_SHARING_EMAIL            2
#define GC_SHARING_END              6

#define GC_SHARING_OPT_INCLUDE_GE_LINK  0
#define GC_SHARING_OPT_INCLUDE_GC_LINK  1
#define GC_SHARING_OPT_INCLUDE_SNAPSHOT 2
#define GC_SHARING_OPT_INCLUDE_CSV      3
#define GC_SHARING_OPT_END              4

@interface GCSharingViewController ()
@property (nonatomic,retain) RZTableIndexRemap * remap;

@end

@implementation GCSharingViewController
@synthesize activity,remoteDownload,hud,presentSelector;

-(void)dealloc{
    [[GCAppGlobal web] detach:self];
    [[GCAppGlobal organizer] detach:self];
    [activity release];
    [remoteDownload release];
    [hud release];
    [_remap release];

    [super dealloc];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[GCAppGlobal organizer] attach:self];
        //for testing

        self.remap = [RZTableIndexRemap tableIndexRemap];
        if ([GCAppGlobal connectStatsVersion]) {
            [self.remap addSection:GC_SECTION_SHARING withRows:@[
                                                                 @( GC_SHARING_SHARE ),
                                                                 @( GC_SHARING_GOOGLE_EARTH ),
                                                                 @( GC_SHARING_EMAIL),
                                                                 ]];

            [self.remap addSection:GC_SECTION_WAIT withRowsFunc:^(){
                if([[GCAppGlobal web] isProcessing]){
                    return @[ @( 0 )];
                }else{
                    return @[];
                };
            }];

            [self.remap addSection:GC_SECTION_INCLUDE withRows:@[
                                                                 @( GC_SHARING_OPT_INCLUDE_GE_LINK ),
                                                                 @( GC_SHARING_OPT_INCLUDE_GC_LINK ),
                                                                 @( GC_SHARING_OPT_INCLUDE_SNAPSHOT),
                                                                 @( GC_SHARING_OPT_INCLUDE_CSV )
                                                                 ]];
        }else{
            [self.remap addSection:GC_SECTION_SHARING withRows:@[
                                                                 @( GC_SHARING_SHARE ),
                                                                 @( GC_SHARING_EMAIL),
                                                                 ]];

            [self.remap addSection:GC_SECTION_INCLUDE withRows:@[
                                                                 @( GC_SHARING_OPT_INCLUDE_SNAPSHOT),
                                                                 @( GC_SHARING_OPT_INCLUDE_CSV )
                                                                 ]];

        }

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [GCViewConfig backgroundForGroupedTable];
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
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self.remap reloadData];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    static NSString *CellIdentifier = @"GridCell";
    GCCellGrid *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...

    [cell setupForRows:1 andCols:1];
    if (indexPath.section==GC_SECTION_INCLUDE) {
        if (indexPath.row == GC_SHARING_OPT_INCLUDE_GE_LINK) {
            [cell labelForRow:0 andCol:0].text = NSLocalizedString( @"Include GoogleEarth Link", @"SharingView");
            BOOL addLink = [GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GE_LINK defaultValue:YES];
            [cell setIconImage:[GCViewConfig checkMarkImage:addLink]];
            cell.iconPosition = gcIconPositionLeft;
        }else if (indexPath.row == GC_SHARING_OPT_INCLUDE_GC_LINK) {
            [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Include GarminConnect Link", @"SharingView");
            BOOL addLink = [GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GC_LINK defaultValue:NO];
            [cell setIconImage:[GCViewConfig checkMarkImage:addLink]];
            cell.iconPosition = gcIconPositionLeft;
        }else if (indexPath.row == GC_SHARING_OPT_INCLUDE_SNAPSHOT){
            [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Include Snapshot", @"SharingView");
            BOOL addLink = [GCAppGlobal configGetBool:CONFIG_SHARING_ADD_SNAPSHOT defaultValue:NO];
            [cell setIconImage:[GCViewConfig checkMarkImage:addLink]];
            cell.iconPosition = gcIconPositionLeft;
        }else if (indexPath.row == GC_SHARING_OPT_INCLUDE_CSV){
            [cell labelForRow:0 andCol:0].text = NSLocalizedString(@"Include CSV file", @"SharingView");
            BOOL addLink = [GCAppGlobal configGetBool:CONFIG_SHARING_ADD_CSV defaultValue:NO];
            [cell setIconImage:[GCViewConfig checkMarkImage:addLink]];
            cell.iconPosition = gcIconPositionLeft;
        }
    }else if(indexPath.section == GC_SECTION_SHARING){
        if (indexPath.row == GC_SHARING_SHARE) {
            [cell labelForRow:0 andCol:0].text = NSLocalizedString( @"Share", @"SharingView");
            [cell setIconImage:[UIImage imageNamed:@"702-share"]];
            cell.iconPosition = gcIconPositionLeft;
        }else if(indexPath.row == GC_SHARING_GOOGLE_EARTH){
            [cell labelForRow:0 andCol:0].text = NSLocalizedString( @"GoogleEarth", @"SharingView");
            [cell setIconImage:[UIImage imageNamed:@"googleearth"]];
            cell.iconPosition = gcIconPositionLeft;
        }else if(indexPath.row == GC_SHARING_EMAIL){
            [cell labelForRow:0 andCol:0].text = NSLocalizedString( @"Email", @"SharingView");
            [cell setIconImage:[UIImage imageNamed:@"email"]];
            cell.iconPosition = gcIconPositionLeft;
        }
    }else{
        GCCellActivityIndicator * indic = [GCCellActivityIndicator activityIndicatorCell:tableView parent:[GCAppGlobal web]];
        if ([[GCAppGlobal web] isProcessing]) {
            indic.label.text = [[GCAppGlobal web] currentDescription];
        }else{
            indic.label.text = nil;
        }
        return indic;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    self.activity = [[GCAppGlobal organizer] currentActivity];

    if (indexPath.section == GC_SECTION_INCLUDE) {
        if (indexPath.row==GC_SHARING_OPT_INCLUDE_GE_LINK) {
            BOOL addLink = ![GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GE_LINK defaultValue:YES];
            if (addLink) {
                [GCAppGlobal configSet:CONFIG_SHARING_ADD_GC_LINK boolVal:NO];
                [GCAppGlobal configSet:CONFIG_SHARING_ADD_SNAPSHOT boolVal:NO];
            }
            [GCAppGlobal configSet:CONFIG_SHARING_ADD_GE_LINK boolVal:addLink];
            [GCAppGlobal saveSettings];
            [self.tableView reloadData];
        }else if (indexPath.row==GC_SHARING_OPT_INCLUDE_GC_LINK) {
            BOOL addLink = ![GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GC_LINK defaultValue:NO];
            if (addLink) {
                [GCAppGlobal configSet:CONFIG_SHARING_ADD_GE_LINK boolVal:NO];
                [GCAppGlobal configSet:CONFIG_SHARING_ADD_SNAPSHOT boolVal:NO];
            }
            [GCAppGlobal configSet:CONFIG_SHARING_ADD_GC_LINK boolVal:addLink];
            [GCAppGlobal saveSettings];
            [self.tableView reloadData];
        }else if (indexPath.row==GC_SHARING_OPT_INCLUDE_SNAPSHOT) {
            BOOL addLink = ![GCAppGlobal configGetBool:CONFIG_SHARING_ADD_SNAPSHOT defaultValue:NO];
            if (addLink) {
                [GCAppGlobal configSet:CONFIG_SHARING_ADD_GE_LINK boolVal:NO];
                [GCAppGlobal configSet:CONFIG_SHARING_ADD_GC_LINK boolVal:NO];
            }
            [GCAppGlobal configSet:CONFIG_SHARING_ADD_SNAPSHOT boolVal:addLink];
            [GCAppGlobal saveSettings];
            [self.tableView reloadData];
        }else if (indexPath.row==GC_SHARING_OPT_INCLUDE_CSV){
            BOOL addLink = ![GCAppGlobal configGetBool:CONFIG_SHARING_ADD_CSV defaultValue:NO];
            [GCAppGlobal configSet:CONFIG_SHARING_ADD_CSV boolVal:addLink];
            [GCAppGlobal saveSettings];
            [self.tableView reloadData];
        }
    }else{
        if (indexPath.row == GC_SHARING_GOOGLE_EARTH) {
            [self startGoogleEarth];
        }else if(indexPath.row == GC_SHARING_SHARE){
            [self startSharing];
        }else if(indexPath.row == GC_SHARING_EMAIL){
            [self presentEmail];
        }
    }
}

-(void)dismiss{
    if ([self slidingViewController]) {
        [[self slidingViewController] resetTopViewAnimated:YES];
    }else if(self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)startHud{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Preparing data";
}
-(void)hideHud{
    if (self.hud) {
        [self.hud hide:YES afterDelay:0.];
   }
}

-(NSURL*)urlString{
    NSURL * rv = nil;
    if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GE_LINK defaultValue:YES]) {
        rv = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",GCWebGoogleEarthURL(activity.activityId)]];
    }else if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GC_LINK defaultValue:NO]) {
        rv = [NSURL URLWithString:[NSString stringWithFormat:@"http://connect.garmin.com/activity/%@",activity.activityId]];
    }

    return rv;
}


#pragma mark - all

-(void)publishEventSharing:(NSString*)which{

#ifdef GC_USE_FLURRY
    NSString * what = @"None";
    if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GE_LINK defaultValue:YES]) {
        what = @"GoogleEarth";
    }else if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GC_LINK defaultValue:NO]) {
        what = @"GarminConnect";
    }else if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_SNAPSHOT defaultValue:NO]) {
        what = @"Snapshot";
    }
    [Flurry logEvent:EVENT_SHARING withParameters:@{@"service":which,@"include":what}];
#endif
}

-(void)publishEventGoogleEarth{
#ifdef GC_USE_FLURRY
    [Flurry logEvent:EVENT_GOOGLE_EARTH];
#endif
}

-(void)publishEventEmail{
#ifdef GC_USE_FLURRY
    [Flurry logEvent:EVENT_SHARING_EMAIL];
#endif
}


-(void)startForSelector:(SEL)selector{
    presentSelector = selector;
    [self dismiss];

    if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GE_LINK defaultValue:YES]) {
        dispatch_async([GCAppGlobal worker],^(){
            [self exportGoogleEarth];
        });
        [self startHud];
    }else{
        [self performSelectorOnMainThread:presentSelector withObject:nil waitUntilDone:NO];
    }
}

-(void)presentForServiceType:(NSString*)serviceType{
    
    NSMutableArray * toShare = [NSMutableArray arrayWithObject:[activity exportPost]];
    
    NSURL * url = [self urlString];
    if (url) {
        [toShare addObject:url];
        
    }
    UIImage * image = [self exportImage];
    if (image) {
        [toShare addObject:image];
    }

    
    UIActivityViewController * controller = RZReturnAutorelease([[UIActivityViewController alloc] initWithActivityItems:toShare applicationActivities:nil]);
    controller.popoverPresentationController.sourceView = self.view;
    [self presentViewController:controller animated:true completion:nil];
}


#pragma mark - Sharing

-(void)startSharing{
    [self startForSelector:@selector(presentSharing)];
}

-(void)presentSharing{
    [self presentForServiceType:@"sharing"];
}

#pragma mark - Email

-(void)presentEmail{
    [self dismiss];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self startEmail];
    });
}

-(void)startEmail{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController * o = [[[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        o.mailComposeDelegate = self;
        [o setSubject:[activity exportTitle]];

        NSString * body = [activity exportPost];
        if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GC_LINK defaultValue:NO]) {
            body = [NSString stringWithFormat:@"<p>%@</p><p><a href=\"http://connect.garmin.com/activity/%@\">Garmin Connect</a></p>",body,activity.activityId ];
        }
        [o setMessageBody:body isHTML:YES];

        if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_GE_LINK defaultValue:YES]) {
            [self saveGoogleEarchFile];
            NSData * data = [NSData dataWithContentsOfFile:[RZFileOrganizer writeableFilePath:[self googleFilename]]];
            [o addAttachmentData:data
                        mimeType:@"application/vnd.google-earth.kmz"
                        fileName:[NSString stringWithFormat:@"%@.kmz", activity.activityId]];
        }

        UIImage * image = [self exportImage];
        if (image) {
            NSData *data = UIImagePNGRepresentation(image);
            [o addAttachmentData:data
                               mimeType:@"image/png"
                               fileName:@"ConnectStats Screenshot.png"];
        }
        if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_CSV defaultValue:NO]) {
            NSData *data = [[activity exportCsv] dataUsingEncoding:NSUTF8StringEncoding];
            [o addAttachmentData:data mimeType:@"text/csv" fileName:[activity exportFileName:@"csv"]];
#if TARGET_IPHONE_SIMULATOR
            NSString * filename = [RZFileOrganizer writeableFilePath:[activity exportFileName:@"csv"]];
            [data writeToFile:filename atomically:YES];
            NSLog(@"Saved %@", filename);
#endif
        }

        [self publishEventEmail];
        [self presentViewController:o animated:YES completion:nil];
        [self dismiss];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        RZLog(RZLogError, @"mail error %@",error);
    }
}


#pragma mark - Google Earth

-(void)startGoogleEarth{
    [self startHud];
    presentSelector = @selector(presentGoogleEarth);
    dispatch_async([GCAppGlobal worker],^(){
        [self exportGoogleEarth];
    });
}

-(void)presentGoogleEarth{
    [self dismiss];
    [self hideHud];
    NSString *stringURL = [NSString stringWithFormat:@"comgoogleearth://%@",GCWebGoogleEarthURL(activity.activityId)];
    [self publishEventGoogleEarth];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(NSString*)googleFilename{
    return [NSString stringWithFormat:@"%@.kmz",activity.activityId];
}

-(void)saveGoogleEarchFile{
    GCExportGoogleEarth * goog = [[[GCExportGoogleEarth alloc] init] autorelease];
    goog.activity = activity;
    [goog saveKMZFile:[self googleFilename]];
}

-(void)exportGoogleEarth{
    [self saveGoogleEarchFile];
    NSData  * data = [NSData dataWithContentsOfFile:[RZFileOrganizer writeableFilePath:[self googleFilename]]];
    NSString * device = [activity metaValueForField:@"device"].display;
    NSDictionary * postData=@{@"activityId": activity.activityId,
                             @"activityType": activity.activityType,
                             @"location": activity.location,
                             @"sumDistance": [NSString stringWithFormat:@"%.f",activity.sumDistance],
                             @"sumDuration": [NSString stringWithFormat:@"%.f",activity.sumDuration],
                             @"device": device?:@""};
    RZRemoteDownload * rl = [[RZRemoteDownload alloc] initWithURL:GCWebUploadURL(@"kml") postData:postData fileName:[self googleFilename] fileData:data andDelegate:self];
    self.remoteDownload = rl;
    [rl release];
}


-(void)downloadFailed:(id)connection{
#if !TARGET_IPHONE_SIMULATOR
    [RZFileOrganizer removeEditableFile:[self googleFilename]];
#endif
}
-(void)downloadArraySuccessful:(id)connection array:(NSArray*)theArray{

}
-(void)downloadStringSuccessful:(id)connection string:(NSString*)theString{
    if (presentSelector) {
        [self performSelectorOnMainThread:presentSelector withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - Image attachment

-(id<GCSharingImageExporter>)imageExporter{
    if (self.slidingViewController) {
        UIViewController * topViewController = self.slidingViewController.topViewController;
        if ([topViewController conformsToProtocol:@protocol(GCSharingImageExporter)] ) {
            return (id<GCSharingImageExporter>)topViewController;
        }
    }
    return nil;
}

-(UIImage*)exportImage{
    UIImage * image = nil;
    if ([GCAppGlobal configGetBool:CONFIG_SHARING_ADD_SNAPSHOT defaultValue:NO]) {
        id<GCSharingImageExporter> exporter = [self imageExporter];
        if (exporter) {
            image = [exporter exportImage];
        }
    }
    return image;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPathI{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    if (indexPath.section == GC_SECTION_WAIT) {
        return [GCCellActivityIndicator height];
    }

    return tableView.rowHeight;
}


@end
