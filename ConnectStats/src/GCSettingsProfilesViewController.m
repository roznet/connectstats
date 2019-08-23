//  MIT Licence
//
//  Created on 19/11/2012.
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

#import "GCSettingsProfilesViewController.h"
#import "GCAppGlobal.h"
#import "GCCellGrid+Templates.h"
#import "GCViewConfig.h"
#import "GCSettingsCacheManagementViewController.h"
#import "GCWebConnect+Requests.h"
#import "GCActivitiesOrganizer.h"

#define GC_SECTION_PROFILES 0
#define GC_SECTION_ADVANCED 1
#define GC_SECTION_END      2

#define GC_ADVANCED_NEW     0
#define GC_ADVANCED_DELETE  1
#define GC_ADVANCED_CACHE   2
#define GC_ADVANCED_DERIVED 3
#define GC_ADVANCED_DETAILS 4
#define GC_ADVANCED_RELOAD  5
#define GC_ADVANCED_END     6

@interface GCSettingsProfilesViewController ()
@property (nonatomic,retain) RZTableIndexRemap * remap;
@end

@implementation GCSettingsProfilesViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyCallBack:) name:kNotifySettingsChange object:nil];
        self.remap = [RZTableIndexRemap tableIndexRemap];
        [self.remap addSection:GC_SECTION_PROFILES withRowsFunc:^(){
            return [RZTableIndexRemap rowsWithNumbersFrom:0 to:[[GCAppGlobal profile] countOfProfiles]];
        }];
        [self.remap addSection:GC_SECTION_ADVANCED withRows:@[
                                                              @(GC_ADVANCED_NEW),
                                                              @(GC_ADVANCED_DELETE),
                                                              @(GC_ADVANCED_DERIVED),
                                                              @(GC_ADVANCED_DETAILS),
                                                              @(GC_ADVANCED_RELOAD),
                                                              @(GC_ADVANCED_CACHE)]];
    }
    return self;
}

-(void)dealloc{
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

-(void)notifyCallBack:(id)theParent{
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.remap.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.remap numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPathI
{
    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    static NSString *CellIdentifier = @"GridCell";
    GCCellGrid*cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GCCellGrid alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    if (indexPath.section == GC_SECTION_PROFILES) {
        // Configure the cell...
        BOOL current = [GCAppGlobal profile].currentProfile == indexPath.row;
        [cell setupForRows:2 andCols:2];
        NSDictionary * attr = current ? [GCViewConfig attributeBold16] : [GCViewConfig attribute16];

        NSAttributedString * title = [[[NSAttributedString alloc] initWithString:[[GCAppGlobal profile] profileNameForIdx:indexPath.row]
                                                                      attributes:attr] autorelease];
        NSAttributedString * summ = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d activities",
                                                                                 (int)[[GCAppGlobal profile] activitiesCountForIdx:indexPath.row]]
                                                                     attributes:[GCViewConfig attribute14Gray]] autorelease];
        NSAttributedString * curr = [[[NSAttributedString alloc] initWithString:current ? NSLocalizedString(@"Current Profile",@"Profiles") : NSLocalizedString(@"",@"Profiles")
                                                                     attributes:[GCViewConfig attribute16]]autorelease];
        [cell labelForRow:0 andCol:0].attributedText = title;
        [cell labelForRow:0 andCol:1].attributedText = curr;
        [cell labelForRow:1 andCol:1].attributedText = summ;
        if (current) {
            [GCViewConfig setupGradientForCellsEven:cell];
        }else{
            [GCViewConfig setupGradientForCellsOdd:cell];
        }
    }else if(indexPath.section == GC_SECTION_ADVANCED){
        if (indexPath.row == GC_ADVANCED_NEW){
            [cell setupForRows:1 andCols:1];
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"New Profile","Profiles")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];

            [cell labelForRow:0 andCol:0].attributedText = title;
            [GCViewConfig setupGradientForDetails:cell];
        }else if (indexPath.row == GC_ADVANCED_DELETE){
            [cell setupForRows:1 andCols:1];
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Delete Activities or Profile",@"Profiles")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];

            [cell labelForRow:0 andCol:0].attributedText = title;
            [GCViewConfig setupGradientForDetails:cell];
        }else if (indexPath.row==GC_ADVANCED_CACHE){
            [cell setupForRows:1 andCols:1];
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"View and Manage Cache",@"Profiles")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];

            [cell labelForRow:0 andCol:0].attributedText = title;
            [GCViewConfig setupGradientForDetails:cell];
        }else if (indexPath.row == GC_ADVANCED_DERIVED){
            [cell setupForRows:1 andCols:1];
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Compute Best for more old Activities",@"Profiles")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];

            [cell labelForRow:0 andCol:0].attributedText = title;
            [GCViewConfig setupGradientForDetails:cell];
        }else if (indexPath.row == GC_ADVANCED_DETAILS){
            [cell setupForRows:1 andCols:1];
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Force Download Details",@"Profiles")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];

            [cell labelForRow:0 andCol:0].attributedText = title;
            [GCViewConfig setupGradientForDetails:cell];
        }else if (indexPath.row == GC_ADVANCED_RELOAD){
            [cell setupForRows:1 andCols:1];
            NSAttributedString * title = [[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Force Reload Old Activities",@"Profiles")
                                                                          attributes:[GCViewConfig attributeBold16]] autorelease];

            [cell labelForRow:0 andCol:0].attributedText = title;
            [GCViewConfig setupGradientForDetails:cell];

        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPathI
{

    NSIndexPath * indexPath = [self.remap remap:indexPathI];

    if (indexPath.section == GC_SECTION_PROFILES) {
        if ([GCAppGlobal profile].currentProfile == indexPath.row) {
            [self showRenameProfileAlert:[GCAppGlobal profile].currentProfileName];
        }else{
            [GCAppGlobal addOrSelectProfile:[[GCAppGlobal profile] profileNameForIdx:indexPath.row]];
            [self.tableView reloadData];
        }
    }else if (indexPath.section == GC_SECTION_ADVANCED){
        if (indexPath.row == GC_ADVANCED_NEW) {
            [self showNewProfileAlert];
        }else if (indexPath.row == GC_ADVANCED_CACHE) {
            GCSettingsCacheManagementViewController * detail = [[GCSettingsCacheManagementViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:detail animated:YES];
            [detail release];

        }else if( indexPath.row == GC_ADVANCED_DELETE){

            [self presentActionSheet];
        }else if (indexPath.row == GC_ADVANCED_DERIVED){
            [[GCAppGlobal web] derivedComputations:16];
            [GCAppGlobal beginRefreshing];
        }else if (indexPath.row == GC_ADVANCED_RELOAD){
            [[GCAppGlobal profile] configSet:PROFILE_LAST_PAGE intVal:0];
            [[GCAppGlobal profile] configSet:PROFILE_FULL_DOWNLOAD_DONE boolVal:NO];
            [GCAppGlobal saveSettings];
            [[GCAppGlobal web] servicesSearchActivitiesFrom:0 reloadAll:true];
            [GCAppGlobal beginRefreshing];
        }else if (indexPath.row == GC_ADVANCED_DETAILS){
            [[GCAppGlobal web] downloadMissingActivityDetails:30];
        }
    }
}

#pragma mark - UIActionSheet Delegate

-(void)presentActionSheet{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", @"Profile Delete")
                                                                    message:NSLocalizedString(@"This will only remove activity on the phone", @"Profile Delete")
                                                             preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Profile Delete")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction*action){

                                            }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Profile", @"Profile Delete")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction*action){
                                                [self confirmDestructiveAction:NSLocalizedString(@"Are you sure you want to delete the whole profile?", nil)
                                                                         title:NSLocalizedString(@"Delete Profile", nil)
                                                                    completion:^(){
                                                    [[GCAppGlobal profile] deleteProfile:[[GCAppGlobal profile] currentProfileName]];
                                                    [GCAppGlobal saveSettings];

                                                }];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Some Activities", @"Profile Delete")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                NSString * msg = [NSString stringWithFormat:@"Are you sure you want to delete the %d most recent activities?",(int)[GCAppGlobal organizer].currentActivityIndex+1];
                                                [self confirmDestructiveAction:msg
                                                                         title:NSLocalizedString(@"Delete", @"Profile Delete")
                                                                    completion:^(){
                                                                        [[GCAppGlobal organizer] deleteActivityUpToIndex:[GCAppGlobal organizer].currentActivityIndex];

                                                                    }];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All Activities", @"Profile Delete")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                [self confirmDestructiveAction:NSLocalizedString(@"Are you sure you want to delete all the activities in this profile?", @"Profile Delete")
                                                                         title:NSLocalizedString(@"Delete", @"Profile Delete")
                                                                    completion:^(){
                                                                        [[GCAppGlobal organizer] deleteAllActivities];
                                                                    }];


                                                [[GCAppGlobal organizer] deleteAllActivities];
                                            }]];
    if (self.tabBarController) {
        [self.tabBarController presentViewController:alert animated:YES completion:nil];

    }else{
        // Position next to the delete cell on ipad
        NSIndexPath * deleteIndexPath = [self.remap inverseMap:[NSIndexPath indexPathForRow:GC_ADVANCED_DELETE inSection:GC_SECTION_ADVANCED ] ];
        CGRect rect = [self.tableView rectForRowAtIndexPath:deleteIndexPath];
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(rect.size.width, rect.origin.y + rect.size.height/2, 1, 1);

        [self presentViewController:alert animated:YES completion:nil];
    }

}

-(void)confirmDestructiveAction:(NSString*)message title:(NSString*)title completion:(void(^)(void))complete{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    [alert addCancelAction];
    [alert addAction:[UIAlertAction actionWithTitle:title
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction*action){
                                                complete();
                                                [self.remap reloadData];
                                                [self.tableView reloadData];
                                            }]];
    [self presentViewController:alert animated:YES completion:^(){}];
}

#pragma mark - UIAlertView Delegate

-(void)showRenameProfileAlert:(NSString*)previous{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Rename Profile", @"Profile")
                                                                    message:NSLocalizedString(@"Enter New Profile Name", @"Profile")
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * field){field.text = previous;}];
    [alert addCancelAction];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Rename", @"Profile")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                BOOL success= [[GCAppGlobal profile] setProfileName:alert.textFields[0].text];
                                                if (success) {
                                                    [GCAppGlobal saveSettings];
                                                    [self.remap reloadData];
                                                    [self.tableView reloadData];
                                                }else{
                                                    [self presentSimpleAlertWithTitle:NSLocalizedString(@"Error", @"Profile")
                                                                              message:NSLocalizedString(@"This profile name exists already",@"Profile")];
                                                }

                                            }]];

    [self presentViewController:alert animated:YES completion:^(){}];
}

-(void)showNewProfileAlert{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Profile", @"Profile")
                                                                    message:NSLocalizedString(@"Enter New Profile Name", @"Profile")
                                                             preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * field){}];
    [alert addCancelAction];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"Profile")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction*action){
                                                NSString * name = alert.textFields[0].text;
                                                [GCAppGlobal addOrSelectProfile:name];
                                                [self.remap reloadData];
                                                [self.tableView reloadData];
                                            }]];

    [self presentViewController:alert animated:YES completion:^(){}];
}
@end
