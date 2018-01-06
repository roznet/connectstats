//
//  UIImage+ImageWithUIView.m
//

#import "UIImage+ImageWithUIView.h"

@implementation UIImage (ImageWithUIView)
#pragma mark -
#pragma mark TakeScreenShot

+ (UIImage *)imageWithUIView:(UIView *)view
{
    CGSize screenShotSize = view.bounds.size;
    UIImage *img;
    UIGraphicsBeginImageContext(screenShotSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    //[view drawLayer:view.layer inContext:ctx];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

-(UIImage*)mergeWithImage:(UIImage*)second
{
    // get size of the first image
    
    CGImageRef firstImageRef = self.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef)/self.scale;
    CGFloat firstHeight = CGImageGetHeight(firstImageRef)/self.scale;
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef)/second.scale;
    CGFloat secondHeight = CGImageGetHeight(secondImageRef)/second.scale;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContextWithOptions(mergedSize,NO,self.scale);
    //UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [self drawInRect:CGRectMake( mergedSize.width/2.-firstWidth/2.,  mergedSize.height/2.-firstHeight/2.,  firstWidth,  firstHeight)];
    [second drawInRect:CGRectMake(mergedSize.width/2.-secondWidth/2., mergedSize.height/2.-secondHeight/2., secondWidth, secondHeight)];
    
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

@end
