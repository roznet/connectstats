//  MIT Licence
//
//  Created on 10/07/2015.
//
//  Copyright (c) 2015 Brice Rosenzweig.
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

#import "TSAnalysis.h"
#import "TSTennisFields.h"

@interface TSAnalysis ()
@property (nonatomic,retain) TSTennisSession * session;
@property (nonatomic,retain) TSDataTable * analysisResults;
@end
@implementation TSAnalysis

+(TSAnalysis*)analysisForSession:(TSTennisSession*)session{
    TSAnalysis * rv = [[TSAnalysis alloc] init];
    if (rv) {
        rv.session = session;
    }
    return rv;
}
/*

 Defence:    Count(Def, One more hit or win), Count(Def no more hit and lose)
 Proactive:  Count(ProActive & Won), Count( ProActive & Lost)
 Reactive:   Count( Reactive ), Count(Reactive Building)


 */

-(TSDataTable*)analyse{

    NSArray * cols = @[ kfPlayerName, kfAnalysisName, kfAnalysisSituation, kfAnalysisCount];

    TSDataTable * rv = [TSDataTable tableWithColumnNames:cols];

    NSUInteger rallyIdx = 0;
    for (TSTennisRally * rally in self.session.state) {
        TSDataRow * rallyRow = [rally dataRow];
        for (NSUInteger shotNumber = 0; shotNumber < rally.count; shotNumber++) {
            TSTennisShot * shot = rally[shotNumber];
            tsContestant shotContestant = shot.shotCourtSide == rally.playerCourtSide ? tsContestantPlayer : tsContestantOpponent;
            NSString * name = shotContestant == tsContestantPlayer ? self.session.displayPlayerName : self.session.displayOpponentName;
            BOOL willHitMore = false;
            for (NSUInteger nextIdx = shotNumber+1; nextIdx<rally.count; nextIdx++) {
                if (rally[nextIdx].shotCourtSide == shot.shotCourtSide) {
                    willHitMore = true;
                    break;
                }
                // Defence
                if (shot.shotAnalysis == tsAnalysisDefence) {
                    BOOL defenceEffective = willHitMore || rally.winningContestant == shotContestant;
                    TSDataRow * row = [TSDataRow rowWithObj:@[ name, kaAnalysisDefence, defenceEffective ? kaEffective : kaIneffective, @(1)]
                                          andColumns:cols];
                    [rv addRow:[rallyRow mergedWithRow:row]];
                }
            }
        }
        rallyIdx++;
    }
    self.analysisResults = rv;
    return rv;
}

@end
