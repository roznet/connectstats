//
//  GCTestsHelper.h
//  GarminConnect
//
//  Created by Brice Rosenzweig on 15/10/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCTestsHelper : NSObject

/**
 Helper that will reset and save config, 
 During dealloc will restore all
 */
+(GCTestsHelper*)helper;

-(void)setUp;
-(void)tearDown;

@end
