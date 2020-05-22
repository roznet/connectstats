//
//  GCSimpleGraphLegendInfo.h
//  RZUtilsTouch
//
//  Created by Brice Rosenzweig on 10/05/2020.
//  Copyright © 2020 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCSimpleGraphLegendInfo : NSObject
@property (nonatomic,retain) NSString * text;
@property (nonatomic,retain) UIColor * color;
@property (nonatomic,assign) CGFloat lineWidth;

@end

NS_ASSUME_NONNULL_END
