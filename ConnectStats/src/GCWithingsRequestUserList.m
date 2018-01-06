//  MIT Licence
//
//  Created on 22/09/2013.
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

#import "GCWithingsRequestUserList.h"
#import "GCAppGlobal.h"
#include <CommonCrypto/CommonDigest.h>  // For MD5 hash
#import "GCWithingsRequestMeasures.h"
#import "GCWebUrl.h"


// return a static pointer. Make a copy if you want to keep the result after other calls to this function.
// Not thread safe.
char *md5_hash_to_hex (char *Bin )
{
    unsigned short i;
    unsigned char j;
    static char Hex[33];

    for (i = 0; i < 16; i++)
    {
        j = (Bin[i] >> 4) & 0xf;
        if (j <= 9)
            Hex[i * 2] = (j + '0');
        else
            Hex[i * 2] = (j + 'a' - 10);
        j = Bin[i] & 0xf;
        if (j <= 9)
            Hex[i * 2 + 1] = (j + '0');
        else
            Hex[i * 2 + 1] = (j + 'a' - 10);
    };
    Hex[32] = '\0';
    return(Hex);
}


@implementation GCWithingsRequestUserList
-(gcWebService)service{
    return gcWebServiceWithings;
}
-(void)dealloc{
    [_once release];
    [_users release];

    [super dealloc];
}

+(GCWithingsRequestUserList*)withingsRequestUserListWith:(NSString*)aonce{
    GCWithingsRequestUserList * rv = [[[GCWithingsRequestUserList alloc] init] autorelease];
    if (rv) {
        rv.once = aonce;
    }
    return rv;
}

-(void)saveError:(NSString*)theString{
    NSError * e;
    NSString * fname = @"error_withings_userlist.json";
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:fname] atomically:true encoding:NSUTF8StringEncoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", fname, e.localizedDescription);
    }
}

-(NSString*)url{
    NSString * name = [[GCAppGlobal profile] currentLoginNameForService:gcServiceWithings];
    NSString * pwd  = [[GCAppGlobal profile] currentPasswordForService:gcServiceWithings];
    return [self getUsersListFromAccountURL:name andPwd:pwd];

}
-(NSString*)description{
    return NSLocalizedString( @"Checking withings user list", @"Request Description");
}
-(NSDictionary*)postData{
    return nil;
}
-(NSDictionary*)deleteData{
    return nil;
}
-(NSData*)fileData{
    return nil;
}
-(NSString*)fileName{
    return nil;
}

-(void)process:(NSString*)theString encoding:(NSStringEncoding)encoding andDelegate:(id<GCWebRequestDelegate>) delegate{
    NSError * err = nil;
#if TARGET_IPHONE_SIMULATOR
    NSError * e = nil;
    NSString * sfn = [NSString stringWithFormat:@"withings_userlist.json"];
    if(![theString writeToFile:[RZFileOrganizer writeableFilePath:sfn] atomically:true encoding:encoding error:&e]){
        RZLog(RZLogError, @"Failed to save %@. %@", sfn, e.localizedDescription);
    }
#endif

    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:[theString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err ];
    if (json==nil) {
        RZLog(RZLogError, @"json parsing failed %@", err);
        [self saveError:theString];
        _status = GCWebStatusConnectionError;
    }else {
        self.users = json[@"body"][@"users"];
        if (self.users==nil) {
            RZLog(RZLogError, @"WithingsStageUserList missing body:users key");
            [self saveError:theString];
            _status = GCWebStatusParsingFailed;
        }else{
            NSMutableArray * save = [NSMutableArray arrayWithCapacity:(self.users).count];
            for (NSDictionary * one in self.users) {
                NSString * fn = one[@"firstname"];
                NSString * ln = one[@"lastname"];
                NSString * sn = one[@"shortname"];

                if (fn&&ln&&sn) {
                    [save addObject:@{@"firstname":fn,@"shortname":sn,@"lastname":ln}];
                }
            }
            [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_USERSLIST arrayVal:save];
        }
    }
    [delegate processDone:self];
}
-(id<GCWebRequest>)nextReq{
    if (self.users==nil||(self.users).count==0) {
        RZLog(RZLogError, @"no users found");
        return nil;
    }
    NSString * shortname = [[GCAppGlobal profile] configGetString:CONFIG_WITHINGS_USER defaultValue:@""];

    NSDictionary * user = nil;
    if ([shortname isEqualToString:@""] && (self.users).count) {
        user = self.users[0];
        shortname =user[@"shortname"];
        [[GCAppGlobal profile] configSet:CONFIG_WITHINGS_USER stringVal:shortname];
        [GCAppGlobal saveSettings];
    }
    if (user==nil) {
        for (NSDictionary * one in self.users) {
            if ([one[@"shortname"] isEqualToString:shortname]) {
                user = one;
                break;
            }
        }
    }
    if (user) {
        return [GCWithingsRequestMeasures withingsRequestMeasuresForUser:user];
    }else{
        RZLog(RZLogError, @"User %@ not found",shortname);
    }
    return nil;
}

-(NSString *)getUsersListFromAccountURL:(NSString*)account_email andPwd:(NSString*)account_password
{

	NSString *request;

	char  hashResult[33];

	char *hashed_pwd;

	if (account_email == nil || account_password == nil) {
		RZLog(RZLogError, @"account_email or account_password missing");
		return nil;
	}

	const char *pwd_c = account_password.UTF8String;
	if (pwd_c == NULL) {
		RZLog(RZLogError, @"missing password");
		return nil;
	}


    CC_MD5((unsigned char*)pwd_c, (CC_LONG)strlen(pwd_c), (unsigned char*)hashResult);
    hashed_pwd = md5_hash_to_hex(hashResult);


	NSString *challenge_to_hash = [NSString stringWithFormat:@"%@:%s:%@", account_email, hashed_pwd, self.once];
	const char *challenge_c = challenge_to_hash.UTF8String;

	CC_MD5(challenge_c, (CC_LONG)strlen(challenge_c), (unsigned char*)hashResult);

    //[NSString stringWithCString:md5_hash_to_hex(hashResult) encoding:NSUTF8StringEncoding];
    NSString *hashed_challenge =  @(md5_hash_to_hex(hashResult));
    request = GCWebWithingsUserList(account_email, hashed_challenge);
    return request;
}


@end
