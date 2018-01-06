//  MIT Licence
//
//  Created on 05/08/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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



#import "RZSystemInfo.h"
#import "RZLog.h"
@import SystemConfiguration.CaptiveNetwork;

#if TARGET_OS_IPHONE
@import UIKit;
#endif

#import <SystemConfiguration/SCNetworkReachability.h>

@implementation RZSystemInfo


+(NSUInteger)xcodeVersion{
    static NSUInteger version = 0;
    if (version == 0) {
        BOOL has7 = false;
        BOOL has8 = false;
        BOOL has9 = false;
        BOOL has10 = false;
        BOOL has11 = false;

#ifdef __IPHONE_11_0
        has11 = true;
#endif

#ifdef __IPHONE_10_0
        has10 = true;
#endif
#ifdef __IPHONE_9_0
        has9 = true;
#endif
#ifdef __IPHONE_8_0
        has8=true;
#endif
#ifdef __IPHONE_7_0
        has7=true;
#endif
        if(has11){
            version = 9;
        }else if (has10){
            version = 8;
        }else if (has9){
            version = 7;
        }else if (has8) {
            version = 6;
        }else if (has7){
            version = 5;
        }else{
            version = 4;
        }
    }
    return version;
}

+(BOOL)is64Bits{
#ifdef __LP64__
    return true;
#else
    return false;
#endif
}

+(NSString*)systemName{
#if TARGET_OS_IPHONE
    return @"iOS";
#else
    return @"OSX";
#endif
}

+(NSString*)systemVersion{
    NSString * version = nil;

#if TARGET_OS_IPHONE
    version = [[UIDevice currentDevice] systemVersion];
#else
    NSOperatingSystemVersion osversion = [[NSProcessInfo processInfo] operatingSystemVersion];
    version = [NSString stringWithFormat:@"%ld.%ld.%ld", osversion.majorVersion, osversion.minorVersion, osversion.patchVersion];
#endif
    return version;
}
+(NSString*)systemDescription{
    return [NSString stringWithFormat:@"%@ %@ Xcode %lu %@", [self systemName], [self systemVersion], (unsigned long)[self xcodeVersion], [self is64Bits] ? @"x64" : @"x32"];

}

+(BOOL)wifiAvailable{
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithName( NULL, "www.apple.com" );
    SCNetworkReachabilityFlags flags;

    Boolean didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);

    if (!didRetrieveFlags)
    {
        RZLog(RZLogError, @"Error. Could not recover network reachability flags");
        return NO;
    }

    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    //BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
#if TARGET_OS_IPHONE
    BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsIsWWAN;
#else
    // MAC
    BOOL nonWiFi = false;
#endif

    return isReachable && ! nonWiFi;
}

+(BOOL)networkAvailable{
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithName( NULL, "www.apple.com" );
    SCNetworkReachabilityFlags flags;

    Boolean didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);

    if (!didRetrieveFlags)
    {
        RZLog(RZLogError,@"Error. Could not recover network reachability flags");
        return NO;
    }

    BOOL isReachable = flags & kSCNetworkFlagsReachable;

    return isReachable;
}

+(NSDictionary*)wifiNetworkInfo{
#if TARGET_OS_IPHONE
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());

    NSDictionary *SSIDInfo = nil;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));

        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    if( SSIDInfo ){
        NSMutableDictionary * corrected = [NSMutableDictionary dictionaryWithDictionary:SSIDInfo];
        NSString * bssid = corrected[@"BSSID"];
        if( bssid ){
            corrected[@"BSSID"] = [RZSystemInfo standardizeBSSID:bssid];
        }
        SSIDInfo = corrected;
    }

    return SSIDInfo;
#else
    return nil;
#endif
}

+(NSString*)standardizeBSSID:(NSString*)bssid{
    if(bssid ==nil){
        return nil;
    }
    NSArray * split = [[bssid uppercaseString] componentsSeparatedByString:@":"];
    NSMutableArray * fixed = [NSMutableArray array];
    for (NSString * one in split) {
        if( one.length == 1){
            [fixed addObject:[@"0" stringByAppendingString:one]];
        }else{
            [fixed addObject:one];
        }
    }
    return [fixed componentsJoinedByString:@":"];
}

+(NSString*)standardizeSSID:(NSString*)ssid{
    return [ssid uppercaseString];
}

@end
