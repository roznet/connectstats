//  MIT License
//
//  Created on 28/05/2019 for ConnectStats
//
//  Copyright (c) 2019 Brice Rosenzweig
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



#import "GCConnectStatsRequest.h"
@class GCActivitiesOrganizer;

NS_ASSUME_NONNULL_BEGIN

@interface GCConnectStatsRequestSearch : GCConnectStatsRequest

/**
 Search for new activities from garmin
 
 @param aStart page to start from
 @param aMode true is reload all, false stop when reached last
 @param nav navigation controller to use if need to login
 @return new request
 */
+(GCConnectStatsRequestSearch*)requestWithStart:(NSUInteger)aStart mode:(BOOL)aMode andNavigationController:(nullable UINavigationController*)nav;

+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
