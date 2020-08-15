//
//  GCNumberWithUnit+Scanner.h
//  RZUtils
//
//  Created by Brice Rosenzweig on 15/08/2020.
//  Copyright © 2020 Brice Rosenzweig. All rights reserved.
//

#import <RZUtils/RZUtils.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCNumberWithUnit (Scanner)

+(nullable GCNumberWithUnit*)numberWithUnitFromScanner:(NSScanner*)scanner;
@end

NS_ASSUME_NONNULL_END
