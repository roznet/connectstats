//  MIT Licence
//
//  Created on 28/02/2014.
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

#import "GCGarminLoginSimulatorRequest.h"
#import "GCWebUrl.h"
#import "GCAppGlobal.h"

@implementation GCGarminLoginSimulatorRequest

-(GCGarminLoginSimulatorRequest*)init{
    self = [super init];
    if(self){
        [self setPwd:nil];
        [self setUname:nil];
    }
    return self;
}

-(GCGarminLoginSimulatorRequest*)initWithName:(NSString*)aname andPwd:(NSString*)apwd{
    self = [super init];
    if(self){
        self.pwd = apwd;
        self.uname = aname;
    }
    return self;
}

-(void)dealloc{
    [_pwd release];
    [_uname release];

    [super dealloc];
}
-(gcWebService)service{
    return gcWebServiceGarmin;
}

-(NSString*)description{
    if (_uname) {
        return @"Signing in";
    }else{
        return @"Connecting";
    }
}

-(NSString*)url{
    return GCWebSimulatorSigninURL(self.uname, self.pwd);
}

-(void)process{
#if TARGET_IPHONE_SIMULATOR
    NSString * fn = _uname ? @"last_initial_signin.html" : @"last_signing.html";
    NSError * e = nil;
    [self.theString writeToFile:[RZFileOrganizer writeableFilePath:fn] atomically:true encoding:self.encoding error:&e];
#endif
    if (_uname) {
        NSRange res =[self.theString rangeOfString:GC_HTML_INVALID_LOGIN];
        if (res.location  != NSNotFound ) {
            self.status = GCWebStatusLoginFailed;
            [[GCAppGlobal profile] configSet:PROFILE_NAME_PWD_SUCCESS boolVal:false];
        }else{
            [[GCAppGlobal profile] configSet:PROFILE_NAME_PWD_SUCCESS boolVal:true];
            [GCAppGlobal saveSettings];
        }
    }
    [self setNextReq:nil];
    [self processDone];
}

@end
