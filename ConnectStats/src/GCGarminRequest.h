//  MIT Licence
//
//  Created on 12/11/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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
#import "GCWebRequestStandard.h"

// message received by garmin connect when failed to login
#define GC_HTML_INVALID_LOGIN       @"Invalid username/password combination."
#define GC_HTML_LOGIN_SUCCESSFUL    @"You are signed in as"
#define GC_HTML_ACCESS_DENIED       @"HTTP Status 403 - "
#define GC_HTML_DELETED_ACTIVITY    @"HTTP Status 404 - "
#define GC_HTML_TEMP_UNAVAILABLE    @"Garmin Connect is temporarily unavailable"
#define GC_HTML_TEMP_MAINTENANCE    @"id=\"error\">Error 500"
#define GC_HTML_INTERNAL_ERROR      @"HTTP Status 500 - "
#define GC_HTML_WEBAPPEXCEPTION     @"\"error\":\"WebApplicationException\""

#pragma mark -


#pragma mark -
@interface GCGarminReqBase : GCWebRequestStandard

//-(instancetype)init NS_DESIGNATED_INITIALIZER;

@end



#pragma mark -

@interface GCGarminLogout : GCGarminReqBase

-(NSString*)url;
-(void)process;

@end

#pragma mark -


