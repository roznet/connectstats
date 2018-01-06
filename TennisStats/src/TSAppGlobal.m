//  MIT Licence
//
//  Created on 12/10/2014.
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

#import "TSAppGlobal.h"
#import "TSTennisScoreRule.h"

#if TARGET_OS_IPHONE
#import "TSAppDelegate.h"
#define TSAPPDELEGATE (TSAppDelegate*)[[UIApplication sharedApplication] delegate]
#else
#import "AppDelegate.h"
#define TSAPPDELEGATE (AppDelegate*)[[NSApplication sharedApplication] delegate]
#endif
@implementation TSAppGlobal

+(NSUserDefaults*)settings{
    return [NSUserDefaults standardUserDefaults];
}
+(NSThread*)worker{
    return [TSAPPDELEGATE worker];
}
+(TSReportOrganizer*)reports{
    return [TSAPPDELEGATE reports];
}
+(void)tabBarToStats{
    [TSAPPDELEGATE tabBarToStats];
}

+(FMDatabase*)db{
    return [TSAPPDELEGATE db];
}
+(TSTennisOrganizer*)organizer{
    return [TSAPPDELEGATE organizer];
}

+(TSCloudOrganizer*)cloud{
    return [TSAPPDELEGATE cloud];
}
+(TSPlayerManager*)players{
    return [TSAPPDELEGATE players];
}

+(void)setDefaultScoreRule:(TSTennisScoreRule*)rule{
    [[NSUserDefaults standardUserDefaults] setInteger:[rule pack] forKey:CONFIG_DEFAULT_SCORE_RULE];
}
+(TSTennisScoreRule*)defaultScoreRule{
    TSScoreRulePacked packed = [[NSUserDefaults standardUserDefaults] integerForKey:CONFIG_DEFAULT_SCORE_RULE];

    return [[[TSTennisScoreRule alloc] init] unpack:packed];
}

@end
