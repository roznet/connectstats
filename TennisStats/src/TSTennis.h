//  MIT Licence
//
//  Created on 14/10/2014.
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

#ifndef tennisstats_TSTennis_h
#define tennisstats_TSTennis_h

typedef NSInteger TSScore;

/*typedef NS_ENUM(NSUInteger, tsPlayerSide) {
    tsPlayerUnknown,
    tsPlayerBack,
    tsPlayerFront
};*/

typedef NS_ENUM(NSUInteger, tsCourtSide){
    tsCourtUnknownSide,
    tsCourtBack,
    tsCourtFront
};

typedef NS_ENUM(NSUInteger, tsContestant) {
    tsContestantUnknown,
    tsContestantPlayer,
    tsContestantOpponent
};

typedef NS_ENUM(NSUInteger, tsShotType) {
    tsShotNone,
    tsShotForehand,
    tsShotBackhand,
    tsShotServe
};

typedef NS_ENUM(NSUInteger, tsShotCourtArea) {
    tsShotNoLocation,

    tsShotDeepLeft,
    tsShotDeepRight,

    tsShotShortLeft,
    tsShotShortRight,

    tsShotNetLeft,
    tsShotNetRight,

    tsShotCourtAreaEnd
};


typedef NS_ENUM(NSUInteger, tsBallCourtArea) {
    tsBallNoLocation,

    tsBallDeepLeft,
    tsBallDeepCenter,
    tsBallDeepRight,

    tsBallServiceLeftBoxCenter,
    tsBallServiceLeftBoxWide,
    tsBallServiceRightBoxCenter,
    tsBallServiceRightBoxWide,

    tsBallSidelineLeft,
    tsBallSidelineRight,

    tsBallLongLeft,
    tsBallLongCenter,
    tsBallLongRight,

    tsBallWideLeft,
    tsBallWideRight,

    tsBallNet,
    tsBallCourtAreaEnd
};

typedef NS_ENUM(NSUInteger, tsShotStyle) {
    tsUnknownStyle,
    tsAggressiveShot,
    tsDefensiveShot,
    tsNeutralShot,
    tsServeOrSmash
};

typedef NS_ENUM(NSUInteger, tsRallyResult) {
    tsResultNone,
    tsResultForcedError,
    tsResultUnforcedError,
    tsResultWinner,
    tsResultDoubleFault,
    tsResultAce
};

typedef NS_ENUM(NSInteger, tsDifferential) {
    tsDifferentialBehind = -1,
    tsDifferentialEven   = 0,
    tsDifferentialAhead  = 1
};

typedef NS_ENUM(NSUInteger, tsRallyLength) {
    tsRallyShort,
    tsRallyMedium,
    tsRallyLong
};

typedef NS_ENUM(NSUInteger, tsScoreCriticality) {
    tsScoreEarlyPoint,
    tsScoreDeucePoint,
    tsScorePlayerGamePoint,
    tsScoreOpponentGamePoint,
};

typedef NS_ENUM(NSUInteger, tsCourtLocation) {
    tsCourtIndoor,
    tsCourtOutdoor
};

typedef NS_ENUM(NSUInteger, tsCourtType) {
    tsCourtHard,
    tsCourtClay,
    tsCourtGrass
};

typedef NS_ENUM(NSUInteger, tsTag) {
    tsTagStar,
    tsTagReview,
    tsTagUpset,
    //tsTagNote
    tsTagEnd
};

/**
 @discussion Reactive Rally: Cross Court or center,
              Reactive Building: Down the line
         Proactive: Player in the court, Short ball
 */
typedef NS_ENUM(NSUInteger, tsShotCategory) {
    tsCategoryNone,
    tsCategoryReactive,
    tsCategoryProactive,
    tsCategoryDefence,
    tsCategoryNet,
    tsCategoryServe
};

typedef NS_ENUM(NSUInteger, tsAnalysis) {
    tsAnalysisNone,
    tsAnalysisReactiveRally,
    tsAnalysisProactive,
    tsAnalysisDefence,
    tsAnalysisNet,
    tsAnalysisServe,
    tsAnalysisReactiveBuilding
};

typedef NS_ENUM(NSUInteger, tsShotDirection) {
    tsShotDirectionUnknown,
    tsShotDirectionCrossCourt,
    tsShotDirectionDownTheLine,
    tsShotDirectionCenter
};

#endif
