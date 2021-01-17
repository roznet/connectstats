//  MIT Licence
//
//  Created on 04/10/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

@class GCActivity;
@class GCActivitiesOrganizer;
@class GCService;

NS_ASSUME_NONNULL_BEGIN

@interface GCActivitiesOrganizerListRegister : NSObject

@property (nonatomic,readonly) NSUInteger reachedExisting;
@property (nonatomic,readonly,nullable) NSArray<NSString*>*childIds;
/**
 Create object to register list of activities
 isFirst should be true if first list provided, when multiple list to update the behavior to
 delete existing is different:
 */
-(instancetype)initFor:(NSArray<GCActivity*>*)activities from:(GCService*)service isFirst:(BOOL)isFirst;

+(instancetype)activitiesOrganizerListRegister:(NSArray<GCActivity*>*)activities from:(GCService*)service isFirst:(BOOL)isFirst;

-(void)addToOrganizer:(GCActivitiesOrganizer*)organizer;

-(BOOL)shouldSearchForMoreWith:(NSUInteger)requestCount reloadAll:(BOOL)mode;

@end

NS_ASSUME_NONNULL_END
