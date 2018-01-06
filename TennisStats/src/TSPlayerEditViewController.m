//  MIT Licence
//
//  Created on 21/12/2014.
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

#import "TSPlayerEditViewController.h"
#import "TSAppGlobal.h"
#import "TSPlayerManager.h"

@interface TSPlayerEditViewController ()
@property (nonatomic,retain) TSPlayer * selectedPlayer;
@end

@implementation TSPlayerEditViewController

-(TSPlayerEditViewController*)initWithPlayer:(TSPlayer*)player{
    self = [super initWithNibName:@"TSPlayerEditViewController" bundle:nil];
    self.selectedPlayer = player;
    return self;
}

/// Update information from UI into player
-(TSPlayer*)updatePlayer:(TSPlayer*)player{
    if (self.selectedPlayer) {
        return self.selectedPlayer;
    }
    TSPlayer * rv = player;
    rv = [TSPlayer playerWithFirstName:self.firstName.text andLastName:self.lastName.text];
    return rv;

}
-(void)savePlayer:(id)sender{
    [self.playerEditDelegate playerEditSave:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];


    if (self.selectedPlayer) {
        self.firstName.text = self.selectedPlayer.firstName;
        self.lastName.text = self.selectedPlayer.lastName;
        self.firstName.enabled = false;
        self.lastName.enabled = false;
    }else{
        UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePlayer:)];
        self.navigationItem.rightBarButtonItem = button;
        self.selectedPlayer = nil;
    }

    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[TSAppGlobal players] count]+1;
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCCellGrid * rv = [GCCellGrid gridCell:tableView];
    [rv setupForRows:1 andCols:1];
    if (indexPath.row==0) {
        [rv labelForRow:0 andCol:0].text = NSLocalizedString(@"New Player", @"Edit Player");
    }else{
        TSPlayer * player = [[TSAppGlobal players] playerAtIndex:indexPath.row-1];
        [rv labelForRow:0 andCol:0].text = [player displayName];
    }
    return rv;
}


#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row>0) {
        self.selectedPlayer = [[TSAppGlobal players] playerAtIndex:indexPath.row-1];
        [self.playerEditDelegate playerEditSave:self];
    }else{
        self.firstName.enabled = true;
        self.lastName.enabled = true;

        self.firstName.text = @"";
        self.lastName.text = @"";

        self.selectedPlayer = nil;

        UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(savePlayer:)];
        self.navigationItem.rightBarButtonItem = button;

    }
}
#pragma mark - textField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.firstName) {
        [self.lastName becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
@end
