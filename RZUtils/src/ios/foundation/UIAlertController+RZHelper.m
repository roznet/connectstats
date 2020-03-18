//  MIT Licence
//
//  Created on 10/10/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "UIAlertController+RZHelper.h"

@implementation UIAlertController (RZHelper)

+(UIAlertController*)simpleConfirmWithTitle:(NSString*)title message:(NSString*)msg action:(void (^)(void))handlerIfConfirmed{
    UIAlertController * rv = [UIAlertController alertControllerWithTitle:title
                                                                     message:msg
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [rv addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Alert Acknowledge")
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action){ handlerIfConfirmed(); }]];
    [rv addCancelAction];

    return rv;
}

+(UIAlertController*)simpleAlertWithTitle:(NSString*)title andMessage:(NSString*)msg{
    UIAlertController * rv = [UIAlertController alertControllerWithTitle:title
                                                                     message:msg
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [rv addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", @"Alert Acknowledge")
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action){}]];
    return rv;
}

-(void)addCancelAction{
    [self addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Alert Acknowledge")
                                             style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction*action){}]];
}

-(void)show
{
    [self presentAnimated:YES completion:nil];
}

-(void)presentAnimated:(BOOL)animated
            completion:(void (^)(void))completion
{
    UIViewController *rootVC = nil;
    
    for (UIWindow * window in [UIApplication sharedApplication].windows) {
        if( window.isKeyWindow ){
            rootVC = window.rootViewController;
        }
    }
    
    if (rootVC != nil) {
        [self presentFromController:rootVC animated:animated completion:completion];
    }
}

-(void)presentFromController:(UIViewController *)viewController
                    animated:(BOOL)animated
                  completion:(void (^)(void))completion
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visibleVC = ((UINavigationController *)viewController).visibleViewController;
        [self presentFromController:visibleVC animated:animated completion:completion];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = ((UITabBarController *)viewController).selectedViewController;
        [self presentFromController:selectedVC animated:animated completion:completion];
    } else {
        [viewController presentViewController:self animated:animated completion:completion];
    }
}

@end
