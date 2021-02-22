//  MIT License
//
//  Created on 22/10/2020 for ConnectStatsTestApp
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCTestAppGlobal.h"
#import "GCAppDelegate.h"
#import "ConnectStats-Swift.h"

static GCAppDelegate * _cacheApplicationDelegate = nil;

NS_INLINE GCAppDelegate * _sharedApplicationDelegate(void){
    if( _cacheApplicationDelegate == nil){
        _cacheApplicationDelegate = (GCAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return _cacheApplicationDelegate;
}

@implementation GCTestAppGlobal 

+(void)prepareForTestOnMainThread{
    [GCAppGlobal organizer];
    _sharedApplicationDelegate();
}
+(void)setupEmptyState:(NSString*)name withSettingsName:(NSString*)settingName{
    [_sharedApplicationDelegate() setupEmptyState:(NSString*)name withSettingsName:settingName];
}
+(void)setupEmptyState:(NSString*)name{
    [_sharedApplicationDelegate() setupEmptyState:(NSString*)name];

}
+(void)setupEmptyStateWithDerivedForPrefix:(NSString*)name{
    [_sharedApplicationDelegate() setupEmptyStateWithDerivedForPrefix:name];
}

+(void)setupSampleState:(NSString*)name{
    [_sharedApplicationDelegate() setupSampleState:(NSString*)name];
}
+(void)setupSampleState:(NSString*)name config:(NSDictionary *)config{
    [_sharedApplicationDelegate() setupSampleState:(NSString*)name config:config];
}

+(void)reinitFromSampleState:(NSString*)name{
    [_sharedApplicationDelegate() reinitFromSampleState:name];
}
+(void)cleanWritableFiles{
    [_sharedApplicationDelegate() cleanWritableFiles];
}

+(void)handle:(NSURL*)url{
    [self handleWithUrl:url];
}
@end
