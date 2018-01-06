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

#import "RZUtils/RZLog.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "LCLLogFile.h"



const char * RZLog_components[RZLogLevelsEnd] = {
    "INFO",
    "WARN",
    "ERR ",
    "EXCP",
    "SEGV"
};

NSString * RZLogFileName(){
    return [LCLLogFile path];
}

NSString * RZLogFileContent(){
    NSString * filepath     = [LCLLogFile path];
    NSString * filepath0    = [LCLLogFile path0];

    NSMutableString * str = [NSMutableString string];

    NSFileManager*	fileManager			= [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:filepath0]) {
        NSString * str0 = [NSString stringWithContentsOfFile:filepath0 encoding:NSUTF8StringEncoding error:nil];
        [str appendString:str0];
    }

    if ([fileManager fileExistsAtPath:filepath]) {
        NSString * str1 = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        [str appendString:str1];
    }

    return str;
}

void RZLogReset(){
    [LCLLogFile reset];
}

RZLogStatus RZLogCheckStatus(){
    RZLogStatus rv = {false,0,0};
    NSString * str = RZLogFileContent();
    if (str && str.length > 0) {
        rv.exists = true;
        NSArray * lines = [str componentsSeparatedByString:@"\n"];
        for (NSString * line in lines) {
            if ([line rangeOfString:@"SEGV"].location != NSNotFound || [line rangeOfString:@"EXCP"].location != NSNotFound) {
                rv.crashes++;
            }
            if ([line rangeOfString:@"ERR"].location != NSNotFound) {
                rv.errors++;
            }
        }
    }
    return rv;
}



