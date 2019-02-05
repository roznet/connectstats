//
//  RZUtilsSwift.h
//  RZUtilsSwift
//
//  Created by Brice Rosenzweig on 22/04/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for RZUtilsSwift.
FOUNDATION_EXPORT double RZUtilsSwiftVersionNumber;

//! Project version string for RZUtilsSwift.
FOUNDATION_EXPORT const unsigned char RZUtilsSwiftVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RZUtilsSwift/PublicHeader.h>


#import "RZUtilsSwift/RZSLogBridge.h"
