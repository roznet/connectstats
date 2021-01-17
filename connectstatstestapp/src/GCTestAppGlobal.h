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


@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface GCTestAppGlobal : NSObject

+(void)setupEmptyState:(NSString*)name;
+(void)setupEmptyState:(NSString*)name withSettingsName:(NSString*)settingName;
+(void)setupEmptyStateWithDerivedForPrefix:(NSString*)name;
+(void)setupSampleState:(NSString*)name config:(NSDictionary*)config;
+(void)setupSampleState:(NSString*)name;
+(void)reinitFromSampleState:(NSString*)name;
+(void)cleanWritableFiles;
+(void)handle:(NSURL*)url;
@end

NS_ASSUME_NONNULL_END
