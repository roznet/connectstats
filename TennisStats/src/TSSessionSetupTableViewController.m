//  MIT Licence
//
//  Created on 26/10/2014.
//
//  Copyright (c) 2014 Brice Rosenzweig.
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

#import "TSSessionSetupTableViewController.h"
#import "TSTennisSession+Cells.h"
#import "TSAppGlobal.h"
#import "TSTennisOrganizer.h"
#import "TSSessionEditTableViewController.h"
#import "TSCloudOrganizer.h"
#import "TSPlayerEditViewController.h"
#import "TSPlayer.h"
#import "TSPlayerManager.h"
#import "TSCloudSessionListTableViewController.h"
#import "TSResultEditViewController.h"
#import "tennisstats-Swift.h"

#define SECTION_CURRENT_SESSION 0
#define SECTION_CHOOSE_SESSION  1
#define SECTION_ICLOUD          2
#define SECTION_END             3

#define CURRENT_SUMMARY     0
#define CURRENT_PLAYER      1
#define CURRENT_OPPONENT    2
#define CURRENT_RULE        3
#define CURRENT_END         4

#define CHOOSE_NEW  0
#define CHOOSE_LOAD 1
#define CHOOSE_END  2

#define ICLOUD_STATUS   0
#define ICLOUD_SAVE     1
#define ICLOUD_LOAD     2
#define ICLOUD_END      3

@interface TSSessionSetupTableViewController ()

@end

@implementation TSSessionSetupTableViewController

-(void)dealloc{
    [[TSAppGlobal cloud] detach:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[TSAppGlobal cloud] attach:self];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return SECTION_END;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section==SECTION_CURRENT_SESSION) {
        return CURRENT_END;
    }else if (section==SECTION_CHOOSE_SESSION){
        return CHOOSE_END;
    }else if (section==SECTION_ICLOUD){
        if ([[TSAppGlobal cloud] enabled]) {
            return ICLOUD_END;
        }else{
            return 1;
        }
    }
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellGrid * rv = [GCCellGrid gridCell:tableView];
    if ([indexPath matchSection:SECTION_CURRENT_SESSION row:CURRENT_SUMMARY]) {
        [[[TSAppGlobal organizer] currentSession] setupSummary:rv];
    }else if ([indexPath matchSection:SECTION_CHOOSE_SESSION row:CHOOSE_LOAD]){
        [rv setupForRows:1 andCols:1];
        [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:NSLocalizedString(@"Load Session", @"Session")
                                                                          attribute:@selector(attribute16)];
    }else if ([indexPath matchSection:SECTION_CHOOSE_SESSION row:CHOOSE_NEW]){
        [rv setupForRows:2 andCols:1];
        [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:NSLocalizedString(@"New Session", @"Session")
                                                                          attribute:@selector(attribute16)];
        NSString * next = [NSString stringWithFormat:NSLocalizedString(@"Rule: %@", @"Sesssion"), [[TSAppGlobal defaultScoreRule] asString]];
        if (next) {
            [rv labelForRow:1 andCol:0].attributedText = [RZViewConfig attributedString:next attribute:@selector(attribute14Gray)];
        }

    }else if ([indexPath matchSection:SECTION_ICLOUD row:ICLOUD_SAVE]){
        [rv setupForRows:1 andCols:1];
        [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:NSLocalizedString(@"Save To Cloud", @"Cloud") attribute:@selector(attribute16)];
    }else if ([indexPath matchSection:SECTION_ICLOUD row:ICLOUD_STATUS]){
        [rv setupForRows:1 andCols:1];
        if([[TSAppGlobal cloud] enabled]){
            [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:NSLocalizedString(@"iCloud Enabled", @"Cloud") attribute:@selector(attribute16)];
        }else{
            [rv setupForRows:2 andCols:1];
            [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:NSLocalizedString(@"iCloud Disabled", @"Cloud") attribute:@selector(attribute16Gray)];
            [rv labelForRow:1 andCol:0].attributedText = [RZViewConfig attributedString:[[TSAppGlobal cloud] statusDescription] attribute:@selector(attribute14Gray)];
        }

    }else if([indexPath matchSection:SECTION_ICLOUD row:ICLOUD_LOAD]){
        [rv setupForRows:2 andCols:1];
        [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:NSLocalizedString(@"Load From Cloud", @"Cloud") attribute:@selector(attribute16)];
        NSUInteger count = [[TSAppGlobal cloud] countOfDiscoveredUsers];
        NSString * userMessage;
        if (count == 0) {
            userMessage = NSLocalizedString(@"No users found", @"");
        }else{
            userMessage = [NSString stringWithFormat:NSLocalizedString(@"%lu users found", @"Cloud"), count];
        }
        [rv labelForRow:1 andCol:0].attributedText = [RZViewConfig attributedString:userMessage attribute:@selector(attribute14Gray)];
    }else if ([indexPath matchSection:SECTION_CURRENT_SESSION row:CURRENT_RULE]){
        [rv setupForRows:2 andCols:1];
        NSString * rule = [[[[TSAppGlobal organizer] currentSession] scoreRule] asString];
        if(rule){
            [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:rule attribute:@selector(attribute16)];
        };
        NSString * next = [NSString stringWithFormat:NSLocalizedString(@"Next Session: %@", @"Sesssion"), [[TSAppGlobal defaultScoreRule] asString]];
        if (next) {
            [rv labelForRow:1 andCol:0].attributedText = [RZViewConfig attributedString:next attribute:@selector(attribute14Gray)];
        }

    }else if ([indexPath matchSection:SECTION_CURRENT_SESSION row:CURRENT_PLAYER]){
        [rv setupForRows:1 andCols:1];
        NSString * player = [[[TSAppGlobal organizer] currentSession] displayPlayerName];
        if (player == nil) { // if no session, session = nil
            player = @"Player";
        }
        [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:player attribute:@selector(attribute16)];
    }else if ([indexPath matchSection:SECTION_CURRENT_SESSION row:CURRENT_OPPONENT]){
        [rv setupForRows:1 andCols:1];
        NSString * player = [[[TSAppGlobal organizer] currentSession] displayOpponentName];
        if (player == nil) {
            player = @"Opponent";
        }
        [rv labelForRow:0 andCol:0].attributedText = [RZViewConfig attributedString:player attribute:@selector(attribute16)];
    }
    return rv;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath matchSection:SECTION_CHOOSE_SESSION row:CHOOSE_LOAD]){
        TSSessionListViewController * list = [[TSSessionListViewController alloc] initWithStyle:UITableViewStylePlain];
        list.sessionListDelegate = self;
        [self.navigationController pushViewController:list animated:YES];
    }else if ([indexPath matchSection:SECTION_CHOOSE_SESSION row:CHOOSE_NEW]){
        // FIXME: change to latest default rule
        [[TSAppGlobal organizer] startNewSession:[TSAppGlobal defaultScoreRule]];
        [self.tableView reloadData];
    }else if (indexPath.section == SECTION_CURRENT_SESSION) {
        TSTennisSession * session = [[TSAppGlobal organizer] currentSession];

        if (indexPath.row == CURRENT_SUMMARY) {
            TSResultEditViewController * resview = [[TSResultEditViewController alloc] initWithSession:session];
            [self.navigationController pushViewController:resview animated:YES];
        }else if (indexPath.row == CURRENT_PLAYER) {
            TSPlayerEditViewController * vc = [[TSPlayerEditViewController alloc] initWithPlayer:session.player];
            vc.playerEditDelegate =self;
            vc.playerIdentifier = CURRENT_PLAYER;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row==CURRENT_OPPONENT){
            TSPlayerEditViewController * vc = [[TSPlayerEditViewController alloc] initWithPlayer:session.opponent];
            vc.playerEditDelegate =self;
            vc.playerIdentifier = CURRENT_OPPONENT;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == CURRENT_RULE){
            TSScoreRuleEditorViewController * vc = [[TSScoreRuleEditorViewController alloc] initWithNibName:@"TSScoreRuleEditorViewController" bundle:nil];
            vc.scoreRule = [[[TSAppGlobal organizer] currentSession] scoreRule];
            [self.navigationController pushViewController:vc animated:YES];

        }else{
            TSSessionEditTableViewController * edit = [TSSessionEditTableViewController editTableViewControllerFor:[[TSAppGlobal organizer] currentSession]];
            [self.navigationController pushViewController:edit animated:YES];
        }

    }else if ([indexPath matchSection:SECTION_ICLOUD row:ICLOUD_SAVE]){
        [[TSAppGlobal cloud] saveSession:[[TSAppGlobal organizer] currentSession]];
    }else if ([indexPath matchSection:SECTION_ICLOUD row:ICLOUD_LOAD]){
        TSCloudSessionListTableViewController * list = [[TSCloudSessionListTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:list animated:YES];
    }
}

-(void)playerEditSave:(TSPlayerEditViewController *)vc{
    TSTennisSession * session = [[TSAppGlobal organizer] currentSession];
    TSPlayer* player = vc.playerIdentifier == CURRENT_PLAYER ? [session player] :[session opponent];
    TSPlayer* edited =  [vc updatePlayer:player];
    [[TSAppGlobal players] registerPlayer:edited];
    if(vc.playerIdentifier== CURRENT_PLAYER){
        [session registerPlayer:edited];
    }else{
        [session registerOpponent:edited];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)sessionList:(TSSessionListViewController *)vc didSelect:(TSTennisSession *)summary{
    [self.tableView reloadData];
    [[TSAppGlobal organizer] selectSessionForId:summary.sessionId];

    [self.navigationController popToViewController:self animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath matchSection:SECTION_CURRENT_SESSION row:CURRENT_SUMMARY]) {
        return [[[TSAppGlobal organizer] currentSession] summaryCellHeight];
    }else{
        return 44.;
    }
}

@end
