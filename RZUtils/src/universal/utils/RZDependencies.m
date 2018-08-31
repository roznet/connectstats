//  MIT Licence
//
//  Created on 20/09/2010.
//
//  Copyright (c) None Brice Rosenzweig.
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

#import "RZDependencies.h"
#import "RZMacros.h"
#import "RZLog.h"

#define DEBUG_DEP
//#define DEBUG_TRACE



#pragma mark - RZDependencyInfo

@interface RZDependencyInfo ()
@property (nonatomic,assign) int intInfo;

@end

@implementation RZDependencyInfo

-(void)dealloc{
    RZRelease(_stringInfo);
    RZSuperDealloc;
}

-(BOOL)isEqualToInfo:(RZDependencyInfo*)other{
    BOOL sameString = self.stringInfo ? ( other.stringInfo && [self.stringInfo isEqualToString:other.stringInfo] ) : (self.stringInfo == nil);
    BOOL sameInt = self.intInfo == other.intInfo;
    return sameInt && sameString;
}

-(NSString*)describe{
	return( [NSString stringWithFormat:@"[%d,%@]", self.intInfo, self.stringInfo ]);
}

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@>", NSStringFromClass([self class]), self.stringInfo ?: @(self.intInfo)];
}

+(RZDependencyInfo*)rzDependencyInfoWithInt:(int)aInt{
	RZDependencyInfo * rv = RZReturnAutorelease([[RZDependencyInfo alloc] init]);
	rv.intInfo = aInt;
	[rv setStringInfo:nil];
	return( rv );
}

+(RZDependencyInfo*)rzDependencyInfoWithString:(NSString*)aStr{
	RZDependencyInfo * rv = RZReturnAutorelease([[RZDependencyInfo alloc] init]);
	rv.intInfo = 0;
	rv.stringInfo = aStr;
	return( rv );}

@end

#pragma mark - RZDependencyHolder

@interface RZDependencyHolder : NSObject
@property (nonatomic,retain) RZDependencyInfo * info;
@property (nonatomic,RZWEAK) id<RZChildObject> child;
@property (nonatomic,retain) NSString * debugInfo;

+(RZDependencyHolder*)dependencyHolderForChild:(id<RZChildObject>)aChild;
+(RZDependencyHolder*)dependencyHolderForChild:(id<RZChildObject>)aChild andString:(NSString*)aStr;
+(RZDependencyHolder*)dependencyHolderForChild:(id<RZChildObject>)aChild andInt:(int)aInt;
-(NSString*)describe;

@end

@implementation RZDependencyHolder

+(RZDependencyHolder*)dependencyHolderForChild:(id<RZChildObject>)aChild{
	RZDependencyHolder * rv = RZReturnAutorelease([[RZDependencyHolder alloc] init]);
	rv.child = aChild;
	[rv setInfo:nil];
#ifdef DEBUG_DEP
	rv.debugInfo = NSStringFromClass([(NSObject*)aChild class]);
#endif
	return( rv );
}
+(RZDependencyHolder*)dependencyHolderForChild:(id<RZChildObject>)aChild andString:(NSString*)aStr{
	RZDependencyHolder * rv = RZReturnAutorelease([[RZDependencyHolder alloc] init]);
	rv.child = aChild;
	rv.info = [RZDependencyInfo rzDependencyInfoWithString:aStr];
#ifdef DEBUG_DEP
	rv.debugInfo = NSStringFromClass([(NSObject*)aChild class]);
#endif
	return( rv );

}
+(RZDependencyHolder*)dependencyHolderForChild:(id<RZChildObject>)aChild andInt:(int)aInt{
	RZDependencyHolder * rv = RZReturnAutorelease([[RZDependencyHolder alloc] init] );
	rv.child = aChild;
	rv.info = [RZDependencyInfo rzDependencyInfoWithInt:aInt];
#ifdef DEBUG_DEP
	rv.debugInfo = NSStringFromClass([(NSObject*)aChild class]);
#endif
	return( rv );
}

-(NSString*)describe{
#ifdef DEBUG_DEP
	return( [NSString stringWithFormat:@"%p(%@)%@", _child, _debugInfo, [_info describe]] );
#else
	return( [NSString stringWithFormat:@"%X %@", child, [info describe] ] );
#endif

}
-(void)dealloc{
    RZRelease(_info);
    RZRelease(_debugInfo);
    RZSuperDealloc;
}

-(BOOL)isEqualToHolder:(RZDependencyHolder*)other{
    return [self.info isEqualToInfo:other.info];
}


@end

#pragma mark - RZParentObject

@interface RZParentObject ()
@property (nonatomic,retain) NSMutableArray * rzDependencies;

@end

@implementation RZParentObject

-(RZParentObject*)init{
	self = [super init];
    if (self) {
        self.rzDependencies = [NSMutableArray array];
    }
	return( self );
}

-(void)dealloc{
    RZRelease(_rzDependencies);
    RZSuperDealloc;
}

-(NSUInteger)indexForChild:(id<RZChildObject>)aChild{
	for( NSUInteger i = 0; i < _rzDependencies.count; i++){
		if ( [_rzDependencies[i] child] == aChild ) {
			return( i );
		}
	}
	return( NSNotFound );
}

-(NSString*)describeDependencies{
	NSMutableString * rv = [NSMutableString stringWithFormat:@"Dep For %p(%@) %lu\n", self, NSStringFromClass([self class]),
                            (unsigned long)_rzDependencies.count];
    int i = 0;
    for (RZDependencyHolder * holder in _rzDependencies) {
        [rv appendFormat:@"Dep%02d %@\n", i++, [holder describe]];
    }
	return( rv );
}

-(void)addDependency:(RZDependencyHolder*)aHolder{
	NSUInteger index = [self indexForChild:aHolder.child];
	if( index == NSNotFound ){
#ifdef DEBUG_TRACE
		RZLog( RZLogInfo, @"ATTACH %p(%@) <- %@", (void*)self, NSStringFromClass([self class]), [aHolder describe]);
#endif
        [self.rzDependencies addObject:aHolder];

	}else{
#ifdef DEBUG_TRACE
		RZLog( RZLogInfo,  @"ATTACH %p(%@)[%ld] <- %@", self, NSStringFromClass([self class]), (long)index, [aHolder describe]);
#endif
		self.rzDependencies[index] = aHolder;
	}
}

/**
 Attach with nil info
 A child can be attached only once
 */
-(void)attach:(id<RZChildObject>)aChild{
	[self addDependency:[RZDependencyHolder dependencyHolderForChild:aChild]];
}
/**
 Attach with a string
 */
-(void)attach:(id<RZChildObject>)aChild withString:(NSString*)aString{
	[self addDependency:[RZDependencyHolder dependencyHolderForChild:aChild andString:aString]];
}
/**
 Attach with an int
 */
-(void)attach:(id<RZChildObject>)aChild withInt:(int)aInt{
	[self addDependency:[RZDependencyHolder dependencyHolderForChild:aChild andInt:aInt]];
}
/**
 Detach child
 */
-(void)detach:(id<RZChildObject>)aChild{
	NSUInteger index = [self indexForChild:aChild];
	if( index != NSNotFound ){
#ifdef DEBUG_TRACE
		RZLog( RZLogInfo,  @"DETACH %p(%@)[%ld] <- %@", aChild, NSStringFromClass([(NSObject*)self class]), (long)index,
										[[_rzDependencies objectAtIndex:index] describe]);
#endif
		[_rzDependencies removeObjectAtIndex:index];
	}
}
/**
 Will notify all attached children with the info they attached with (or nil)
 */
-(void)notify{
    for (RZDependencyHolder * holder in _rzDependencies) {
#ifdef DEBUG_TRACE
		RZLog( RZLogInfo,  @"NOTIFY %p(%@) -> %p(%@)", self, NSStringFromClass([(NSObject*)self class]), [holder child], [holder debugInfo]);
#endif
		[holder.child notifyCallBack:self info:holder.info];
    }
}

/**
 Will notify all attached children such that:
    - info they attached with was nil
    - info they attached with is equal to aString
 */
-(void)notifyForString:(NSString *)aString{
    for (RZDependencyHolder * holder in _rzDependencies) {
        NSString * str = holder.info.stringInfo;
        if (!str || [aString caseInsensitiveCompare:str] == NSOrderedSame) {
#ifdef DEBUG_TRACE
            RZLog( RZLogInfo,  @"NOTIFY %p(%@) -> %p(%@)", self, NSStringFromClass([self class]), [holder child], [holder debugInfo]);
#endif
            [holder.child notifyCallBack:self info:[RZDependencyInfo rzDependencyInfoWithString:aString]];
        }
    }
}

-(void)notifyForString:(NSString *)aString safeTries:(NSUInteger)maxTries{
    NSUInteger tries = maxTries;
    while( tries > 0 ){
        @try {
            [self notifyForString:aString];
            break;
        }
        @catch( NSException * exception ){
            RZLog( RZLogWarning, @"NOTIFY @catch %lu for %@[%@] %@", (unsigned long) (maxTries-tries), self, aString, exception);
            tries--;
        }
    }
}

-(NSString*)parentCurrentDescription{
    return @"";
}

@end


