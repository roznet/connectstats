//  MIT License
//
//  Created on 22/03/2020 for ConnectStats
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



#import "GCCalculatedCachedTrackInfo.h"

@implementation GCCalculatedCachedTrackInfo

-(NSString*)description{
    return [NSString stringWithFormat:@"<%@: %@ %@>",NSStringFromClass([self class]),self.field,self.serie ? self.serie : @"empty"];
}

-(BOOL)requiresCalculation{
    return self.serie == nil ;
}

+(GCCalculatedCachedTrackInfo*)infoForField:(GCField*)afield andSerie:(GCStatsDataSerieWithUnit*)serie{
    GCCalculatedCachedTrackInfo * rv = [[[GCCalculatedCachedTrackInfo alloc] init] autorelease];
    if (rv) {
        rv.field = afield;
        rv.serie = serie;
        rv.processedPointsCount = 0;
    }
    return rv;
}
/**

 */
+(GCCalculatedCachedTrackInfo*)infoForField:(GCField*)afield{
    GCCalculatedCachedTrackInfo * rv = [[[GCCalculatedCachedTrackInfo alloc] init] autorelease];
    if (rv) {
        rv.field = afield;
        rv.serie = nil;
        rv.processedPointsCount = 0;
    }
    return rv;
}

-(gcFieldFlag)fieldFlag{
    return _field.fieldFlag;
}

-(GCField*)underlyingField{
    return [self.field correspondingUnderlyingField];
}

-(gcFieldFlag)underlyingFieldFlag{
    return self.underlyingField.fieldFlag;
}
-(void)dealloc{
    [_serie release];
    [_field release];

    [super dealloc];
}

-(void)startCalculation{
    
}


@end

