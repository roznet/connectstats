//  MIT License
//
//  Created on 12/11/2018 for FitFileExplorer
//
//  Copyright (c) 2018 Brice Rosenzweig
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



#import "FITGarminDownloadManager.h"
#import "FITAppGlobal.h"
#import "GCWebConnect.h"
#import "GCGarminLoginSSORequest.h"
#import "FITGarminRequestActivityList.h"

@interface FITGarminDownloadManager ()

@property (nonatomic,strong) NSArray<NSDictionary*>*list;

@end

@implementation FITGarminDownloadManager
+(FITGarminDownloadManager*)manager{
    FITGarminDownloadManager * rv = [[FITGarminDownloadManager alloc] init];
    [[FITAppGlobal web] attach:rv];
    return rv;
}

-(void)dealloc{
    [[FITAppGlobal web] detach:self];
    
}

-(void)startDownload{
    
    [[FITAppGlobal web] addRequest:[GCGarminLoginSSORequest requestWithUser:[FITAppGlobal currentLoginName] andPwd:[FITAppGlobal currentPassword]]];
    [[FITAppGlobal web] addRequest:[[FITGarminRequestActivityList alloc] initWithStart:0 andMode:false]];
    
}

-(void)notifyCallBack:(id)theParent info:(RZDependencyInfo *)theInfo{
    
}
-(void)loadRawFiles{
    NSArray * files = [RZFileOrganizer writeableFilesMatching:^(NSString*n){
        
        return [n hasPrefix:@"last_modern_search"];
    }];
    
    
    NSMutableArray * ar = [NSMutableArray array];
    for (NSString * fn in files) {
        NSData * jsonData = [NSData dataWithContentsOfFile:[RZFileOrganizer
                                                            writeableFilePath:fn]];
        NSDictionary * json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        if( json ){
            NSArray * list = json[@"activityList"];
            if( list ){
                [ar addObjectsFromArray:list];
            }
        }
    }
    self.list = ar;
}
@end
