//
//  RZUtilsUniversal.h
//  RZUtilsUniversal
//
//  Created by Brice Rosenzweig on 12/11/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for RZUtilsUniversal.
FOUNDATION_EXPORT double RZUtilsUniversalVersionNumber;

//! Project version string for RZUtilsUniversal.
FOUNDATION_EXPORT const unsigned char RZUtilsUniversalVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RZUtilsUniversal/PublicHeader.h>

#import "RZUtilsUniversal/UIColor+HexString.h"
#import "RZUtilsUniversal/RZViewConfig.h"
#import "RZUtilsUniversal/GCSimpleGraphView.h"
#import "RZUtilsUniversal/GCSimpleGraphProtocol.h"
#import "RZUtilsUniversal/GCSimpleGraphGeometry.h"
#import "RZUtilsUniversal/GCSimpleGraphCachedDataSource.h"
#import "RZUtilsUniversal/GCViewGradientColors.h"
#import "RZUtilsUniversal/NSBezierPath+QuartzHelper.h"

