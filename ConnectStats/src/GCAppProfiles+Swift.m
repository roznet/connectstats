//  MIT Licence
//
//  Created on 28/05/2017.
//
//  Copyright (c) 2017 Brice Rosenzweig.
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

#import "GCAppProfiles+Swift.h"
#import "ConnectStats-Swift.h"

@implementation GCAppProfiles (Swift)

-(GCAppPasswordManager*)passwordManagerForService:(gcService)service{
    NSString * serviceName = [[GCService service:service] displayName];
    NSString * username = [self currentLoginNameForService:service];
    GCAppPasswordManager * mgr = [[[GCAppPasswordManager alloc] initForService:serviceName andUsername:username] autorelease];

    return mgr;
}

-(BOOL)savePassword:(NSString*)pwd forService:(gcService)service{
    return [[self passwordManagerForService:service] savePassword:pwd];
}
-(NSString*)retrievePasswordForService:(gcService)service{
    return [[self passwordManagerForService:service] retrievePassword];
}

-(void)clearPasswordForService:(gcService)service{
    [[self passwordManagerForService:service] clearPassword];
}
@end
