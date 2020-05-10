//
//  GCSimpleGraphLegendInfo.m
//  RZUtilsTouch
//
//  Created by Brice Rosenzweig on 10/05/2020.
//  Copyright © 2020 Brice Rosenzweig. All rights reserved.
//

#import "GCSimpleGraphLegendInfo.h"

@implementation GCSimpleGraphLegendInfo

#if ! __has_feature(objc_arc)
-(void)dealloc{
    [_text release];
    [_color release];
    
    [super dealloc];
}
#endif

@end
