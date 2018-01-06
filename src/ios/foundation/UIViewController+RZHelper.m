//  MIT Licence
//
//  Created on 10/08/2013.
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

#import "UIViewController+RZHelper.h"
#import "UIAlertController+RZHelper.h"

typedef NS_ENUM(NSUInteger, IOSLayoutVersion) {
    iosLayoutUndefined,
    iosLayoutIOS7,
    iosLayoutIOS6
};

static IOSLayoutVersion _iosLayout = iosLayoutUndefined;

BOOL isIOS7Layout(){
    NSString * version = [UIDevice currentDevice].systemVersion;
    NSArray  * comp    = [version componentsSeparatedByString:@"."];
    BOOL has7 = false;
#ifdef __IPHONE_7_0
    has7=true;
#endif
    if ([comp[0] intValue] >= 7 && has7) {
        _iosLayout = iosLayoutIOS7;
    }else{
        _iosLayout = iosLayoutIOS6;
    }
    return _iosLayout == iosLayoutIOS7;
}

@implementation UIViewController (RZHelper)

+(BOOL)useIOS7Layout{
    return isIOS7Layout();
}

+(void)setupEdgeExtendedLayout:(UIViewController*)controller{
#ifdef __IPHONE_7_0
    if ([UIViewController useIOS7Layout]) {
        controller.edgesForExtendedLayout = UIRectEdgeNone;
    }
#endif
}


+(CGRect)adjustedVisibleFrame:(CGRect)input forController:(UIViewController*)controller{
    CGRect rv = input;
    if (isIOS7Layout()) {
        if (controller.navigationController) {
            CGRect nav = controller.navigationController.navigationBar.frame;
            rv.origin.y = nav.origin.y+nav.size.height;
            rv.size.height -= (nav.origin.y+nav.size.height);
        }
        if (controller.tabBarController) {
            CGRect tabbar = controller.tabBarController.tabBar.frame;
            rv.size.height -= tabbar.size.height;
        }
    }
    return rv;
}

-(BOOL)isVisible{
    return self.isViewLoaded && self.view.window ;
}

-(void)presentSimpleAlertWithTitle:(NSString*)title message:(NSString*)msg{
    UIAlertController * action = [UIAlertController simpleAlertWithTitle:title andMessage:msg];

    [self presentViewController:action animated:YES completion:^(){}];

}
@end
