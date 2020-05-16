//  MIT License
//
//  Created on 15/05/2020 for ConnectStats
//
//  Copyright (c) 2020 Brice Rosenzweig
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



#import "GCDerivedQueueElement.h"
#import "GCActivity.h"

@implementation GCDerivedQueueElement

+(GCDerivedQueueElement*)elementRebuildFor:(GCActivity*)act{
    GCDerivedQueueElement * rv = [[[GCDerivedQueueElement alloc] init] autorelease];
    if (rv) {
        rv.activities = @[ act ];
        rv.fields = nil;
        rv.elementType = gcQueueElementTypeRebuild;
    }
    return rv;

}

+(GCDerivedQueueElement*)elementAdd:(GCActivity*)act fields:(NSArray<GCField*>*)fields andType:(gcQueueElementType)type{
    GCDerivedQueueElement * rv = [[[GCDerivedQueueElement alloc] init] autorelease];
    if (rv) {
        rv.activities = @[act];
        rv.fields = fields;
        rv.elementType = type;
    }
    return rv;
}

-(void)dealloc{
    [_fields release];
    [_activities release];
    [super dealloc];
}

-(NSString*)description{
    NSMutableArray * infos = [NSMutableArray array];
    switch(self.elementType){
        case gcQueueElementTypeRebuild:
            [infos addObject:@"rebuild"];
            break;
        case gcQueueElementTypeBestRolling:
            [infos addObject:@"add"];
            break;
    }
    if( self.activities.count == 1){
        [infos addObject:self.activities[0].description];
    }else{
        [infos addObject:[NSString stringWithFormat:@"[%@ activities]", @(self.activities.count)]];
    }
    
    [infos addObject:[NSString stringWithFormat:@"[%@ fields]", @(self.fields.count)]];
    
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), [infos componentsJoinedByString:@" "]];
}
@end
