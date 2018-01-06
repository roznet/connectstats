//  MIT Licence
//
//  Created on 27/10/2014.
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

#import "TSTennisFields.h"

NSString * kfWinner            = @"winner";
NSString * kfNumberOfShots     = @"numberOfShots";
NSString * kfScoreDifferential = @"scoreDifferential";
NSString * kfLastShotType      = @"lastShotType";
NSString * kfLastShotArea      = @"lastShotArea";
NSString * kfRallyResult       = @"rallyResult";
NSString * kfRallyLength       = @"rallyLength";
NSString * kfScoreCriticality  = @"scoreCriticality";
NSString * kfSetNumber         = @"setNumber";
NSString * kfRallyTime         = @"rallyTime";
NSString * kfRallyNumber       = @"rallyNumber";

NSString * kfShotType           = @"shotType";
NSString * kfShotCourtArea      = @"shotCourtArea";
NSString * kfBallCourtArea      = @"ballCourtArea";
NSString * kfShotStyle          = @"shotStyle";
NSString * kfShotAnalysis       = @"shotAnalysis";
NSString * kfShotDirection      = @"shotDirection";
NSString * kfShotPlayer         = @"shotPlayer";
NSString * kfShotNumber         = @"shotNumber";
NSString * kfShotTime           = @"shotTime";
NSString * kfShotIsRallyEnd     = @"shotIsRallyEnd";

NSString * kfPlayerName = @"playerName";
NSString * kfAnalysisName = @"analysisName";
NSString * kfAnalysisSituation = @"analysisSituation";
NSString * kfAnalysisCount = @"analysisCount";

NSString * kaAnalysisDefence = @"defence";
NSString * kaAnalysisProactive = @"proactive";
NSString * kaAnalysisReactive = @"reactive";

NSString * kaEffective = @"effective";
NSString * kaIneffective = @"ineffective";

@implementation TSTennisFields
+(NSString*)contestantDescription:(tsContestant)contestant{
    switch (contestant) {
        case tsContestantOpponent:
            return @"Opponent";
        case tsContestantPlayer:
            return @"Player";
        case tsContestantUnknown:
            return @"Unkown";
    }
}

+(NSString*)shotCourtAreaDescription:(tsShotCourtArea)area{
    switch (area) {
        case tsShotCourtAreaEnd:
        case tsShotNoLocation:
            return @"";
        case tsShotDeepRight:
            return @"Deep Right";
        case tsShotDeepLeft:
            return @"Deep Left";
        case tsShotNetLeft:
            return @"Net Left";
        case tsShotNetRight:
            return @"Net Right";
        case tsShotShortLeft:
            return @"Short Left";
        case tsShotShortRight:
            return @"Short Right";
    }
}
+(NSString*)ballCourtAreaDescription:(tsBallCourtArea)area{
    switch (area) {
        case tsBallNet:
            return @"Net";
        case tsBallWideLeft:
            return @"Wide Left";
        case tsBallSidelineLeft:
            return @"Sideline Left";
        case tsBallDeepCenter:
            return @"Deep Center";
        case tsBallDeepLeft:
            return @"Deep Left";
        case tsBallDeepRight:
            return @"Deep Right";
        case tsBallLongCenter:
            return @"Long Center";
        case tsBallLongLeft:
            return @"Long Left";
        case tsBallLongRight:
            return @"Long Right";
        case tsBallServiceLeftBoxCenter:
            return @"Left Serve";
        case tsBallServiceLeftBoxWide:
            return @"Left Serve Wide";
        case tsBallServiceRightBoxCenter:
            return @"Right Serve";
        case tsBallServiceRightBoxWide:
            return @"Right Serve Wide";
        case tsBallSidelineRight:
            return @"Sideline Right";
        case tsBallWideRight:
            return @"Wide Right";
        case tsBallCourtAreaEnd:
            return @"";
        case tsBallNoLocation:
            return @"";
    }
}
+(NSString*)shotTypeDescription:(tsShotType)type{
    switch (type) {
        case tsShotServe:
            return @"Serve";
        case tsShotBackhand:
            return @"Backhand";
        case tsShotForehand:
            return @"Forehand";
        case tsShotNone:
            return @"None";

    }
    return @"Unknown";

}
+(NSString*)courtSideDescription:(tsCourtSide)sides{
    switch (sides) {
        case tsCourtUnknownSide:
            return @"";
        case tsCourtFront:
            return @"Front";
        case tsCourtBack:
            return @"Back";
    }
    return @"Back";
}
+(NSString*)scoreDifferentialDescription:(tsDifferential)diff{
    switch (diff) {
        case tsDifferentialAhead:
            return @"Ahead";
        case tsDifferentialBehind:
            return @"Behind";
        case tsDifferentialEven:
            return @"Even";
    }
    return nil;
}
+(NSString*)scoreCriticalityDescription:(tsScoreCriticality)criticality{
    switch (criticality) {
        case tsScoreDeucePoint:
            return @"Deuce Point";
        case tsScoreEarlyPoint:
            return @"Early Point";
        case tsScoreOpponentGamePoint:
            return @"Opponent Game Point";
        case tsScorePlayerGamePoint:
            return @"Player Game Point";
    }
    return nil;
}
+(NSString*)rallyLengthDescription:(tsRallyLength)length{
    switch (length) {
        case tsRallyShort:
            return @"Short Rally";
        case tsRallyMedium:
            return @"Medium Rally";
        case tsRallyLong:
            return @"Long Rally";
    }
    return nil;
}
+(NSString*)resultDescription:(tsRallyResult)result{
    switch (result) {
        case tsResultUnforcedError:
            return @"Unforced Error";
        case tsResultWinner:
            return  @"Winner";
        case tsResultDoubleFault:
            return @"Double Fault";
        case tsResultAce:
            return @"Ace";
        case tsResultNone:
            return @"Unknown";
        case tsResultForcedError:
            return @"Forced Error";

    }
    return nil;
}
+(NSString*)tagDescription:(tsTag)tag{
    switch (tag) {
        case tsTagReview:
            return NSLocalizedString(@"Review", @"Tag");
        case tsTagStar:
            return NSLocalizedString(@"Great", @"Tag");
        case tsTagUpset:
            return NSLocalizedString(@"Upset", @"Tag");
        case tsTagEnd:
            return NSLocalizedString(@"END", @"Tag");
    }
}
+(NSString*)shotStyleDescription:(tsShotStyle)style{
    switch (style) {
        case tsAggressiveShot:
            return NSLocalizedString(@"Aggressive", @"Style");
        case tsDefensiveShot:
            return NSLocalizedString(@"Defensive", @"Style");
        case tsNeutralShot:
        case tsServeOrSmash:
        case tsUnknownStyle:
            return @"";
    }
    return @"";
}
+(NSString*)shotDirectionDescription:(tsShotDirection)direction{
    switch (direction) {
        case tsShotDirectionUnknown:
            return NSLocalizedString(@"", @"Direction");
        case tsShotDirectionDownTheLine:
            return NSLocalizedString(@"Down the Line", @"Direction");
        case tsShotDirectionCrossCourt:
            return NSLocalizedString(@"Cross Court", @"Direction");
        case tsShotDirectionCenter:
            return NSLocalizedString(@"Center", @"Direction");
    }
    return @"";
}
+(NSString*)shotCategoryDescription:(tsShotCategory)category{
    switch (category) {
        case tsCategoryDefence:
            return NSLocalizedString(@"Defence", @"Category");
        case tsCategoryNet:
            return NSLocalizedString(@"Net", @"Category");
        case tsCategoryNone:
            return @"";
        case tsCategoryProactive:
            return NSLocalizedString(@"ProActive", @"Category");
        case tsCategoryReactive:
            return NSLocalizedString(@"Reactive", @"Category");
        case tsCategoryServe:
            return NSLocalizedString(@"Serve", @"Category");
    }
    return @"";
}

+(NSString*)analysisDescription:(tsAnalysis)analysis{
    switch (analysis) {
        case tsAnalysisDefence:
            return NSLocalizedString(@"Defence", @"Analysis");
        case tsAnalysisNet:
            return NSLocalizedString(@"Net", @"Analysis");
        case tsAnalysisNone:
            return @"";
        case tsAnalysisProactive:
            return NSLocalizedString(@"ProActive", @"Analysis");
        case tsAnalysisReactiveBuilding:
            return NSLocalizedString(@"Reactive Building", @"Analysis");
        case tsAnalysisReactiveRally:
            return NSLocalizedString(@"Reactive Rally", @"Analysis");
        case tsAnalysisServe:
            return NSLocalizedString(@"Serve", @"Analysis");
    }
    return @"";

}
@end
