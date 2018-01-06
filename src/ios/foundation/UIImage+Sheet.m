//  MIT Licence
//
//  Created on 28/10/2014.
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

#import "UIImage+Sheet.h"

@implementation UIImage (Sheet)

-(NSArray*)imagesFromSpriteSheet:(CGSize)size{

    NSMutableArray * rv = [NSMutableArray array];

    CGSize sheetSize = self.size;

    CGImageRef sheetRef = self.CGImage;
    CGFloat currentX = 0.;
    CGFloat currentY = 0.;

    while (currentY+size.height <= sheetSize.height) {
        while (currentX+size.width <= sheetSize.width) {
            CGRect rect =CGRectMake(currentX*self.scale,
                                    currentY*self.scale,
                                    size.width*self.scale,
                                    size.height*self.scale);
            CGImageRef sprite = CGImageCreateWithImageInRect(sheetRef,rect);
            UIImage * img = [UIImage imageWithCGImage:sprite scale:self.scale orientation:self.imageOrientation];
            CGImageRelease(sprite);
            [rv addObject:img];
            currentX += size.width;
        }
        currentY+= size.height;
        currentX=0.;
    }
    return rv;

}

+(NSArray*)imagesFromNumberedFiles:(NSString*)fmt andRange:(NSRange)range{
    NSMutableArray * rv = [NSMutableArray array];

    for (NSUInteger i=range.location; i<range.length+range.location; i++) {
        NSString * fn =[NSString stringWithFormat:fmt, (int)i];
        UIImage * img=[UIImage imageNamed:fn];
        if (img) {
            [rv addObject:img];
        }
    }

    return rv;
}

@end
