//  MIT Licence
//
//  Created on 12/10/2014.
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

#import "TSTennisShot.h"
#import "TSTennisFields.h"

@implementation TSTennisShot
+(TSTennisShot*)tennisShotWithEvent:(TSTennisEvent*)event{
    TSTennisShot * rv = [[TSTennisShot alloc] init];
    if (rv) {
        rv.time = event.time;
        rv.shotType = [event shotType];
        rv.shotArea = [event shotCourtArea];
        rv.shotLocation = event.location;
        rv.shotCourtSide = event.shotCourtSide;
        rv.shotIsLeftSide = event.isLeftSide;
        rv.ballIsIn = true; // by default assume in
        rv.shotStyle = event.shotStyle;
        rv.shotCategory = event.shotCategory;

    }
    return rv;
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<TSTennisShot %@ %@ %@>", [TSTennisFields shotTypeDescription:self.shotType],
            self.ballIsIn ? @"In" : @"Out",
            [TSTennisFields ballCourtAreaDescription:self.ballArea]];
}

-(BOOL)isSameShot:(TSTennisEvent*)event{
    return (event.playerCourtSide == self.shotCourtSide);
}
-(BOOL)isServeSameSide:(TSTennisShot*)shot{
    return self.shotCourtSide==shot.shotCourtSide&&shot.shotIsLeftSide==self.shotIsLeftSide&&shot.shotType==tsShotServe&&self.shotType==tsShotServe;
}
-(void)updateWithEvent:(TSTennisEvent *)event{
    if (event.type == tsEventBall && event.playerCourtSide == self.shotCourtSide) {
        self.ballArea = event.ballCourtArea;
        self.ballLocation = event.location;
        if (self.shotType == tsShotServe) {
            self.ballIsIn = [event ballIsInServe:self.shotLocation];
        }else{
            self.ballIsIn = [event ballIsIn:self.shotLocation];
        }
    }
}

-(tsShotDirection)shotDirection{
    if (self.ballArea != tsBallNoLocation && self.shotArea!= tsShotNoLocation) {
        switch (self.shotArea) {
            case tsShotDeepLeft:
            case tsShotNetLeft:
            case tsShotShortLeft:
                switch (self.ballArea) {
                    case tsBallLongLeft:
                    case tsBallDeepLeft:
                    case tsBallServiceLeftBoxCenter:
                    case tsBallServiceLeftBoxWide:
                    case tsBallSidelineLeft:
                    case tsBallWideLeft:
                        return tsShotDirectionDownTheLine;
                    case tsBallLongRight:
                    case tsBallDeepRight:
                    case tsBallServiceRightBoxCenter:
                    case tsBallServiceRightBoxWide:
                    case tsBallSidelineRight:
                    case tsBallWideRight:
                        return tsShotDirectionCrossCourt;
                    case tsBallNoLocation:
                    case tsBallCourtAreaEnd:
                    case tsBallNet:
                        return tsShotDirectionUnknown;
                    case tsBallLongCenter:
                    case tsBallDeepCenter:
                        return tsShotDirectionCenter;
                }
            case tsShotDeepRight:
            case tsShotNetRight:
            case tsShotShortRight:
                switch (self.ballArea) {
                    case tsBallLongLeft:
                    case tsBallDeepLeft:
                    case tsBallServiceLeftBoxCenter:
                    case tsBallServiceLeftBoxWide:
                    case tsBallSidelineLeft:
                    case tsBallWideLeft:
                        return tsShotDirectionCrossCourt;
                    case tsBallLongRight:
                    case tsBallDeepRight:
                    case tsBallServiceRightBoxCenter:
                    case tsBallServiceRightBoxWide:
                    case tsBallSidelineRight:
                    case tsBallWideRight:
                        return tsShotDirectionDownTheLine;
                    case tsBallNoLocation:
                    case tsBallCourtAreaEnd:
                    case tsBallNet:
                        return tsShotDirectionUnknown;
                    case tsBallLongCenter:
                    case tsBallDeepCenter:
                        return tsShotDirectionCenter;

                }
            case tsShotNoLocation:
            case tsShotCourtAreaEnd:
                return tsShotDirectionUnknown;
        }
    }

    return tsShotDirectionUnknown;
}

-(NSString*)shotDescription{
    NSMutableArray * rv = [NSMutableArray array];
    NSString * style = [TSTennisFields shotStyleDescription:self.shotStyle];
    if ([style length]>0) {
        [rv addObject:style];
    }
    if (self.shotType != tsShotNone) {
        [rv addObject:[NSString stringWithFormat:@"%@", [TSTennisFields shotTypeDescription:self.shotType]]];
    }
    if (self.ballArea != tsBallNoLocation) {
        NSString * direction = [TSTennisFields shotDirectionDescription:self.shotDirection];
        if (direction.length>0) {
            [rv addObject:direction];
        }
        [rv addObject:self.ballIsIn ? @"In" : @"Out"];
    }
    return [rv componentsJoinedByString:@" "];
}

-(tsAnalysis)shotAnalysis{
    tsAnalysis rv = tsAnalysisNone;

    if (self.shotCategory == tsCategoryReactive) {
        if (self.shotDirection==tsShotDirectionDownTheLine) {
            rv = tsAnalysisReactiveBuilding;
        }else{
            rv = tsAnalysisReactiveRally;
        }
    }else{
        rv = (tsAnalysis)self.shotCategory;
    }
    return rv;
}
-(BOOL)ballLocationKnown{
    return _ballArea != tsBallNoLocation;
}

-(TSDataRow*)dataRow{
    NSDictionary * dict = @{
                            kfShotTime:      self.time,
                            kfShotType:      [TSTennisFields shotTypeDescription:self.shotType],
                            kfShotCourtArea: [TSTennisFields shotCourtAreaDescription:self.shotArea],
                            kfBallCourtArea: [TSTennisFields ballCourtAreaDescription:self.ballArea],
                            kfShotAnalysis:  [TSTennisFields analysisDescription:self.shotAnalysis],
                            kfShotDirection: [TSTennisFields shotDirectionDescription:self.shotDirection],
                            kfShotStyle:     [TSTennisFields shotStyleDescription:self.shotStyle]
                            };
    return [TSDataRow rowWithObj:dict andColumns:[TSTennisShot dataColumns]];
}
+(NSArray*)dataColumns{
    return @[ kfShotType, kfShotCourtArea, kfBallCourtArea, kfShotAnalysis, kfShotDirection, kfShotStyle, kfShotTime];
}

@end
