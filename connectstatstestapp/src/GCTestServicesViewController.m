//  MIT Licence
//
//  Created on 13/05/2017.
//
//  Copyright (c) 2017 Brice Rosenzweig.
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

#import "GCTestServicesViewController.h"
#import "GCTestServiceConfigViewController.h"
#import "GCAppProfiles.h"
#import "GCAppGlobal.h"

#import "GCTestServiceGarmin.h"
#import "GCTestServiceStrava.h"
#import "GCTestServiceBugReport.h"
#import "GCTestServiceConnectStats.h"
#import "GCTestServiceCompare.h"

NSString * kNotificationProfileChanged = @"kNotificationProfileChanged";


@interface GCTestServicesViewController ()
@property (nonatomic,retain) NSMutableDictionary * settings;
@property (nonatomic,retain) GCAppProfiles * profile;
@end

@implementation GCTestServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // We maintain our own profile here, the key is the saved file. the unit test will setup empty state and reload from the file
    self.settings = [NSMutableDictionary dictionaryWithDictionary:[RZFileOrganizer loadDictionary:kPreservedSettingsName]];
    self.profile = [GCAppProfiles profilesFromSettings:_settings];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationProfileChanged
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification*n){
        [self saveSettings];
    }];
    // Do any additional setup after loading the view.
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_settings release];
    [_profile release];
    
    [super dealloc];
}
-(void)saveSettings{
    [self.profile saveToSettings:self.settings];
    [RZFileOrganizer saveDictionary:self.settings withName:kPreservedSettingsName];
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
-(NSArray*)allTestClassNames{
    return @[
        NSStringFromClass([GCTestServiceGarmin class]),
        NSStringFromClass([GCTestServiceConnectStats class]),
        NSStringFromClass([GCTestServiceStrava class]),
        NSStringFromClass([GCTestServiceBugReport class]),
        NSStringFromClass([GCTestServiceCompare class]),
    ];
}

-(NSArray*)additionalLeftNavigationButton{
    return @[
             RZReturnAutorelease([[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Config",nil)
                                                                                         style:UIBarButtonItemStylePlain
                                                                                        target:self
                                                                                        action:@selector(showConfig:)])
             ];
}

-(void)showConfig:(id)button{
    [self.navigationController pushViewController:[GCTestServiceConfigViewController configForProfile:self.profile] animated:YES];
}

@end
