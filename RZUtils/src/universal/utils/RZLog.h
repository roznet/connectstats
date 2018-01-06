//  MIT Licence
//
//  Created on 21/09/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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


#import <Foundation/Foundation.h>
#import "RZUtils/LCLLogFile.h"

typedef NS_ENUM(NSUInteger, RZlogLevels)  {
    RZLogInfo       = 0,
    RZLogWarning    = 1,
    RZLogError      = 2,
    RZLogException  = 3,
    RZLogSegv       = 4,
    RZLogLevelsEnd  = 5
};

typedef struct {
    BOOL exists;
    NSUInteger errors;
    NSUInteger crashes;
} RZLogStatus;

extern const char * RZLog_components[];

NSString * RZLogFileName(void);

#if TARGET_IPHONE_SIMULATOR
#define RZLOG_CONSOLE_OUTPUT 1
#else
#if TARGET_OS_IPHONE
#else
#if DEBUG
#define RZLOG_CONSOLE_OUTPUT 1
#endif
#endif
#endif


#if RZLOG_CONSOLE_OUTPUT
#define RZLog(_level, _format, ...) { \
    _lcl_logger_autoreleasepool_begin                                          \
    if (true || _level > RZLogWarning){ \
        NSLog( _format, ## __VA_ARGS__); \
    } \
    [LCLLogFile logWithIdentifier:RZLog_components[_level]                     \
                            level:_level                                       \
                             path:__FILE__                                     \
                             line:__LINE__                                     \
                         function:__PRETTY_FUNCTION__                          \
                           format:_format,                                     \
                        ## __VA_ARGS__];                                \
    _lcl_logger_autoreleasepool_end                                            \
}
#else
#define RZLog(_level, _format, ...) {                        \
    _lcl_logger_autoreleasepool_begin                                          \
    [LCLLogFile logWithIdentifier:RZLog_components[_level]                     \
                            level:_level                                       \
                             path:__FILE__                                     \
                             line:__LINE__                                     \
                         function:__PRETTY_FUNCTION__                          \
                            format:_format,                                     \
                        ## __VA_ARGS__];                                \
    _lcl_logger_autoreleasepool_end                                            \
}
#endif

//#define RZLOG_TRACE_ON 1
#ifdef RZLOG_TRACE_ON
#ifdef RZLOG_CONSOLE_OUTPUT
#define RZLogTrace(_format, ...) { \
    _lcl_logger_autoreleasepool_begin                                          \
    NSLog(@"%s", __PRETTY_FUNCTION__);                                         \
    [LCLLogFile logWithIdentifier:RZLog_components[0]                     \
                            level:0                                    \
                             path:__FILE__                                     \
                             line:__LINE__                                     \
                         function:__PRETTY_FUNCTION__                          \
                           format:_format,                                     \
                               ## __VA_ARGS__];                                \
    _lcl_logger_autoreleasepool_end                                            \
}
#else //COnsoleoutput
#define RZLogTrace(_format, ...) { \
         _lcl_logger_autoreleasepool_begin                                          \
        [LCLLogFile logWithIdentifier:RZLog_components[0]                     \
            level:0                                    \
            path:__FILE__                                     \
            line:__LINE__                                     \
            function:__PRETTY_FUNCTION__                          \
            format:_format,                                     \
            ## __VA_ARGS__];                                \
            _lcl_logger_autoreleasepool_end                                            \
}
#endif
#else // RZLOG_TRACE_ON
#define RZLogTrace(_format, ...)
#endif

RZLogStatus RZLogCheckStatus(void);
NSString * RZLogFileContent(void);
void RZLogReset(void);

