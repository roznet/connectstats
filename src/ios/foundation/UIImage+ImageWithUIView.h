//
//  UIImage+ImageWithUIView.h
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (ImageWithUIView)
+ (UIImage *)imageWithUIView:(UIView *)view;
-(UIImage*)mergeWithImage:(UIImage*)second;


@end
