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

#import <Foundation/Foundation.h>
#import "TSTennis.h"

@interface TSTennisCourtGeometry : NSObject

+(TSTennisCourtGeometry*)court;

//Convert
-(void)calculateFor:(CGRect)rect;
-(CGPoint)courtLocation:(CGPoint)point;
-(CGPoint)drawLocation:(CGPoint)point;

//Drawing
-(CGRect)fullCourt;
-(CGRect)frontHalfCourt;
-(CGRect)backHalfCourt;
-(CGRect)singleFullCourt;

-(CGRect)backServiceBoxLeft;
-(CGRect)backServiceBoxRight;
-(CGRect)frontServiceBoxLeft;
-(CGRect)frontServiceBoxRight;
-(CGRect)frontNet;
-(CGRect)backNet;


//Areas
-(CGRect)rectForShotCourtArea:(tsShotCourtArea)area side:(tsCourtSide)side;
-(CGRect)rectForBallCourtArea:(tsBallCourtArea)area side:(tsCourtSide)side;
-(tsShotCourtArea)shotCourtAreaForShotLocation:(CGPoint)point;
-(tsBallCourtArea)ballCourtAreaForShotLocation:(CGPoint)point;
-(tsCourtSide)shotSideForLocation:(CGPoint)point;
-(tsCourtSide)ballSideForLocation:(CGPoint)point;
-(BOOL)ballIsIn:(CGPoint)point shotFrom:(tsCourtSide)side;
-(BOOL)ballIsIn:(CGPoint)point serveFrom:(tsCourtSide)side left:(BOOL)left;
-(BOOL)isLeftSide:(CGPoint)point;
-(BOOL)isRightSide:(CGPoint)point;

-(CGPoint)equivalentPointFront:(CGPoint)point;
-(CGPoint)equivalentPointBack:(CGPoint)point;
-(CGRect)equivalentRectFront:(CGRect)point;
-(CGRect)equivalentRectBack:(CGRect)point;

@end
