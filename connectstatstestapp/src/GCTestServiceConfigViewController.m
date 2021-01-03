//  MIT License
//
//  Created on 13/01/2018 for ConnectStatsTestApp
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "GCTestServiceConfigViewController.h"
#import "GCTestServicesViewController.h"
#import "GCConnectStatsRequest.h"
#import "ConnectStats-Swift.h"
#import "GCTestServicesViewController.h"

@interface GCTestServiceConfigViewController ()
@property (retain, nonatomic) GCAppProfiles * profile;
@property (retain, nonatomic) IBOutlet UITextField *garminUserName;
@property (retain, nonatomic) IBOutlet UITextField *garminPassword;
@property (weak, nonatomic) GCTestServicesViewController *serviceViewController;

@end

@implementation GCTestServiceConfigViewController

+(GCTestServiceConfigViewController*)configForProfile:(GCAppProfiles*)profile controller:(GCTestServicesViewController *)vc{
    GCTestServiceConfigViewController * rv = RZReturnAutorelease([[GCTestServiceConfigViewController alloc]  initWithNibName:@"GCTestServiceConfig" bundle:nil]);
    rv.profile = profile;
    rv.serviceViewController = vc;
    
    return rv;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.garminUserName.text = [self.profile currentLoginNameForService:gcServiceGarmin];
    self.garminPassword.text = [self.profile currentPasswordForService:gcServiceGarmin];
    
    [super viewWillAppear:animated];
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

- (IBAction)saveButton:(id)sender {
    [self.serviceViewController syncSettings];
}

- (IBAction)logoutButton:(id)sender {
    [GCConnectStatsRequest signout];
    [GCStravaRequestBase signout];
    
    [self.serviceViewController syncSettings];
}

-(IBAction)clearButton:(id)sender{
    [self.serviceViewController resetSettings];

}

-(void)recordChange:(UITextField*)textField{
    if( textField == self.garminUserName){
        [self.profile setLoginName:textField.text forService:gcServiceGarmin];
    }else if ( textField == self.garminPassword ){
        [self.profile setPassword:textField.text forService:gcServiceGarmin];
    }
    [self.serviceViewController saveSettings];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self recordChange:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self recordChange:textField];
    [textField resignFirstResponder];
    return true;
}

- (void)dealloc {
    [_profile release];
    [_garminUserName release];
    [_garminPassword release];
    [super dealloc];
}
@end
