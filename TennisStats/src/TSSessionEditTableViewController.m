//  MIT Licence
//
//  Created on 07/12/2014.
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

#import "TSSessionEditTableViewController.h"
#import "TSPlayer+Cells.h"
#import "TSAppGlobal.h"
#import "TSTennisOrganizer.h"


#define SECTION_PLAYERS 0
#define SECTION_RULE    1
#define SECTION_RESULT  2
#define SECTION_END     3

#define PLAYERS_PLAYER    2
#define PLAYERS_OPPONENT  3
#define PLAYERS_WINNER    0
#define PLAYERS_END       1

#define RULE_CURRENT 0
#define RULE_END     1


@interface TSSessionEditTableViewController ()
@property (nonatomic,retain) TSTennisSession * session;
@end

@implementation TSSessionEditTableViewController

+(TSSessionEditTableViewController*)editTableViewControllerFor:(TSTennisSession *)summary{
    TSSessionEditTableViewController * vc = [[TSSessionEditTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.session = summary;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return SECTION_END;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (SECTION_RULE==section) {
        return RULE_END;
    }else if (section==SECTION_PLAYERS){
        return PLAYERS_END;
    }else{
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView playerCellForRow:(NSInteger)row{
    UITableViewCell * rv = nil;
    GCCellGrid * grid = nil;

    switch (row) {
        case PLAYERS_OPPONENT:{
            grid = [GCCellGrid gridCell:tableView];
            [[self.session opponent] setupSummary:grid];
            rv  =grid;
            break;
        };
        case PLAYERS_PLAYER:{
            grid = [GCCellGrid gridCell:tableView];
            [[self.session player] setupSummary:grid];
            rv  = grid;
            break;
        };
        case PLAYERS_WINNER:{
            grid = [GCCellGrid gridCell:tableView];
            [grid setupForRows:1 andCols:2];
            [grid labelForRow:0 andCol:0].text = @"Winner";
            switch (self.session.contestantWinner) {
                case tsContestantOpponent:
                    [grid labelForRow:0 andCol:1].text = [self.session displayOpponentName];
                    break;
                case tsContestantPlayer:
                    [grid labelForRow:0 andCol:1].text = [self.session displayPlayerName];
                    break;

                default:
                    [grid labelForRow:0 andCol:1].text = NSLocalizedString(@"Unknown", @"Winner");
                    break;
            }
            rv = grid;
            break;
        }
        default:
            break;
    }
    return rv;
}

-(UITableViewCell*)tableView:(UITableView *)tableView resultCellForRow:(NSInteger)row{
    return nil;
}

-(UITableViewCell*)tableView:(UITableView *)tableView ruleCellForRow:(NSInteger)row{
    GCCellGrid * grid = [GCCellGrid gridCell:tableView];
    NSString * rule = [[[[TSAppGlobal organizer] currentSession] scoreRule] asString];
    [grid setupForRows:1 andCols:2];
    [grid labelForRow:0 andCol:0].text = @"Rule";
    [grid labelForRow:0 andCol:1].text = rule;
    return grid;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == SECTION_PLAYERS) {
        return [self tableView:tableView playerCellForRow:indexPath.row];
    }else if (indexPath.section == SECTION_RESULT){
        return [self tableView:tableView resultCellForRow:indexPath.row];
    }else if (indexPath.section == SECTION_RULE){
        return [self tableView:tableView ruleCellForRow:indexPath.row];
    }
    return nil;
}
-(void)cellWasChanged:(id<GCEntryFieldProtocol>)cell{
    [self.session registerContestantWinner:[cell selected]];
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath matchSection:SECTION_PLAYERS row:PLAYERS_WINNER]) {
        NSArray * choices = @[ NSLocalizedString(@"Unknown", @"Winner"),
                               self.session.displayPlayerName,
                               self.session.displayOpponentName

                               ];
        GCCellEntryListViewController * vc = [GCCellEntryListViewController entryListViewController:choices selected:self.session.contestantWinner];
        vc.entryFieldDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(UINavigationController*)baseNavigationController{
    return self.navigationController;
}
-(UINavigationItem*)baseNavigationItem{
    return self.navigationItem;
}
@end
