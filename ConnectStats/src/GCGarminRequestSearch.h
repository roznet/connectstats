//  MIT Licence
//
//  Created on 20/12/2012.
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

#import "GCGarminRequest.h"
@class GCActivitiesOrganizer;

@interface GCGarminSearch : GCGarminReqBase

@property (nonatomic,assign) NSUInteger start;
@property (nonatomic,assign) BOOL reloadAll;
@property (nonatomic,retain) NSArray * activities;

-(GCGarminSearch*)init NS_DESIGNATED_INITIALIZER DEPRECATED_MSG_ATTRIBUTE("Use Modern Search");
-(GCGarminSearch*)initWithStart:(NSUInteger)aStart percent:(double)pct andMode:(BOOL)aMode NS_DESIGNATED_INITIALIZER DEPRECATED_MSG_ATTRIBUTE("Use Modern Search");
-(GCGarminSearch*)initNextWith:(GCGarminSearch*)current NS_DESIGNATED_INITIALIZER DEPRECATED_MSG_ATTRIBUTE("Use Modern Search");
-(NSString*)url;
-(void)process;

+(GCActivitiesOrganizer*)testForOrganizer:(GCActivitiesOrganizer*)organizer withFilesInPath:(NSString*)path;
@end
