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

#import "TSTennisCourtGeometry.h"
#import "TSTennisEvent.h"

/*
            <  ------ AREA_WIDTH  --------->
                < ---  FULL_WIDTH ---- >
                   <- SINGLE_WIDTH ->
              (0,0)
                |--|----------------|--|
                |  |                |  |
                |  |                |  |
                |  |                |  |
                |  |                |  |
                |  |----------------|  |
                |  |        |       |  |
                |  |        |       |  |
                |  |        |       |  |
                |  |        |       |  |
                |==|================|==|
                |  |        |       |  |
                |  |        |       |  |
                |  |        |       |  |
                |  |        |       |  |
                |  |----------------|  |
                |  |                |  |
                |  |                |  |
                |  |                |  |
                |  |                |  |
                |--|----------------|--|


 */
// In meters
#define FULL_WIDTH   10.97
#define SINGLE_WIDTH  8.23
#define HALF_LENGTH  11.89
#define FULL_LENGTH  23.78
#define SERVICE_DIST  6.40
#define SIDE_WIDTH    1.37
#define AREA_LENGTH  30.00
#define AREA_WIDTH   15.00
#define NET_HEIGHT    1.50

// AREA_X = (FULL_WIDTH - AREA_WIDTH)/2 = -2.015
// AREA_Y = (FULL_LENGTH - AREA_LENGTH)/2 = -3.11
#define AREA_X -2.015
#define AREA_Y -3.11

#define COURT_X 2.015
#define COURT_Y 3.11

#define RESCALE(r,s) CGRectMake((r.origin.x*s.size.width)+s.origin.x,\
                                (r.origin.y*s.size.height)+s.origin.y,\
                                r.size.width*s.size.width,\
                                r.size.height*s.size.height)


static TSTennisCourtGeometry * _court;

@interface TSTennisCourtGeometry ()

@property (nonatomic,assign) CGRect drawRect;
@property (nonatomic,assign) CGRect drawScale;

@end

@implementation TSTennisCourtGeometry

+(TSTennisCourtGeometry*)court{
    if (_court == nil) {
        _court = [[TSTennisCourtGeometry alloc] init];
    }
    return _court;
}

-(TSTennisCourtGeometry*)init{
    self = [super init];
    if (self) {
        self.drawRect = CGRectMake(0., 0., 1., 1.);
        self.drawScale = CGRectMake(0., 0., 1., 1.);
    }
    return self;
}

-(void)calculateFor:(CGRect)rect{
    _drawRect = rect;

    CGFloat xFactor = _drawRect.size.width/AREA_WIDTH;
    CGFloat yFactor = _drawRect.size.height/AREA_LENGTH;
    CGFloat xOffset = xFactor * COURT_X;
    CGFloat yOffset = yFactor * COURT_Y;

    _drawScale = CGRectMake(xOffset, yOffset, xFactor, yFactor);

}
/*
 <  ------ AREA_WIDTH  --------->
     < ---  FULL_WIDTH ---- >
        <- SINGLE_WIDTH ->
   (0,0)
     |--|----------------|--|
     |  |                |  |
     |  |                |  |

  < ---- AREA_WIDTH  ------->
     < --  FULL_WIDTH -->
       < SINGLE_WIDTH >
(0,0)
    (x,y)
     |-|--------------|-|
     | |              | |

*/
-(CGPoint)courtLocation:(CGPoint)point{
    CGFloat x = (point.x-_drawRect.origin.x)/_drawScale.size.width-COURT_X;
    CGFloat y = (point.y-_drawRect.origin.y)/_drawScale.size.height-COURT_Y;

    CGPoint rv = CGPointMake(x,y);
    return rv;
}

-(CGPoint)drawLocation:(CGPoint)point{

    CGFloat x = (COURT_X + point.x) * _drawScale.size.width +_drawRect.origin.x;
    CGFloat y = (COURT_Y + point.y) * _drawScale.size.height+_drawRect.origin.y;

    CGPoint rv = CGPointMake( x,y);

    return rv;
}

-(CGRect)frontNet{
    return RESCALE(CGRectMake(0., HALF_LENGTH-NET_HEIGHT, FULL_WIDTH, NET_HEIGHT), _drawScale);

}
-(CGRect)backNet{
    return RESCALE(CGRectMake(0., HALF_LENGTH, FULL_WIDTH, NET_HEIGHT), _drawScale);
}

-(CGRect)fullCourt{
    return RESCALE(CGRectMake(0., 0., FULL_WIDTH, FULL_LENGTH), _drawScale);
}

-(CGRect)frontHalfCourt{
    return RESCALE(CGRectMake(0., HALF_LENGTH, FULL_WIDTH, HALF_LENGTH), _drawScale);
}
-(CGRect)backHalfCourt{
    return RESCALE(CGRectMake(0., 0., FULL_WIDTH, HALF_LENGTH), _drawScale);
}
-(CGRect)backHalfArea{
    return RESCALE(CGRectMake(AREA_X, AREA_Y, AREA_WIDTH, AREA_LENGTH/2.), _drawScale);
}


-(CGRect)singleFullCourt{
    return RESCALE(CGRectMake(SIDE_WIDTH, 0., SINGLE_WIDTH, FULL_LENGTH), _drawScale);
}

-(CGRect)backServiceBoxLeft{
    return RESCALE(CGRectMake(SIDE_WIDTH, HALF_LENGTH-SERVICE_DIST, SINGLE_WIDTH/2., SERVICE_DIST),_drawScale);
}

-(CGRect)backServiceBoxRight{
    return RESCALE(CGRectMake(SIDE_WIDTH+SINGLE_WIDTH/2., HALF_LENGTH-SERVICE_DIST, SINGLE_WIDTH/2., SERVICE_DIST), _drawScale);
}

-(CGRect)frontServiceBoxLeft{
    return RESCALE(CGRectMake(SIDE_WIDTH, HALF_LENGTH, SINGLE_WIDTH/2., SERVICE_DIST),_drawScale);
}

-(CGRect)frontServiceBoxRight{
    return RESCALE(CGRectMake(SIDE_WIDTH+SINGLE_WIDTH/2., HALF_LENGTH, SINGLE_WIDTH/2., SERVICE_DIST), _drawScale);
}
/*
#define FULL_WIDTH   10.97
#define SINGLE_WIDTH  8.23
#define HALF_LENGTH  11.89
#define FULL_LENGTH  23.78
#define SERVICE_DIST  6.40
#define SIDE_WIDTH    1.37
#define AREA_LENGTH  30.00
#define AREA_WIDTH   15.00
#define NET_HEIGHT    1.50


*/

+(CGRect*)shotCourtAreaRects:(tsCourtSide)side{
    static CGRect * areas_back = nil;
    static CGRect * areas_front = nil;
    if (areas_back==nil) {
        areas_back = calloc(tsShotCourtAreaEnd, sizeof(CGRect));
        areas_back[tsShotDeepLeft]  = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, HALF_LENGTH-(AREA_LENGTH)/2, AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);
        areas_back[tsShotDeepRight] = CGRectMake(FULL_WIDTH/2, HALF_LENGTH-(AREA_LENGTH)/2, AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);
        areas_back[tsShotShortLeft] = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, 0., AREA_WIDTH/2., HALF_LENGTH-SERVICE_DIST);
        areas_back[tsShotShortRight] = CGRectMake(FULL_WIDTH/2, 0., AREA_WIDTH/2., HALF_LENGTH-SERVICE_DIST);
        areas_back[tsShotNetLeft]   = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, HALF_LENGTH-SERVICE_DIST, AREA_WIDTH/2., SERVICE_DIST);
        areas_back[tsShotNetRight]  = CGRectMake(FULL_WIDTH/2, HALF_LENGTH-SERVICE_DIST, AREA_WIDTH/2., SERVICE_DIST);

    }
    if (areas_front==nil) {
        areas_front = calloc(tsShotCourtAreaEnd, sizeof(CGRect));
        areas_front[tsShotDeepLeft]  = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, FULL_LENGTH, AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);
        areas_front[tsShotDeepRight] = CGRectMake(FULL_WIDTH/2, FULL_LENGTH, AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);
        areas_front[tsShotShortLeft] = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, FULL_LENGTH-(HALF_LENGTH-SERVICE_DIST), AREA_WIDTH/2., HALF_LENGTH-SERVICE_DIST);
        areas_front[tsShotShortRight] = CGRectMake(FULL_WIDTH/2, FULL_LENGTH-(HALF_LENGTH-SERVICE_DIST), AREA_WIDTH/2., HALF_LENGTH-SERVICE_DIST);
        areas_front[tsShotNetLeft]   = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, HALF_LENGTH, AREA_WIDTH/2., SERVICE_DIST);
        areas_front[tsShotNetRight]  = CGRectMake(FULL_WIDTH/2, HALF_LENGTH, AREA_WIDTH/2., SERVICE_DIST);
    }

    return side == tsCourtFront ? areas_front : areas_back;
}

+(CGRect*)ballCourtAreaRects:(tsCourtSide)side{
    static CGRect * areas_front = nil;
    static CGRect * areas_back = nil;
    if (areas_front==nil) {
        areas_front = calloc(tsBallCourtAreaEnd, sizeof(CGRect));

        areas_front[tsBallWideLeft] = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2., FULL_LENGTH/2., (AREA_WIDTH-FULL_WIDTH)/2., FULL_LENGTH/2.);
        areas_front[tsBallWideRight] = CGRectMake(FULL_WIDTH, FULL_LENGTH/2., (AREA_WIDTH-FULL_WIDTH)/2., FULL_LENGTH/2.);

        areas_front[tsBallSidelineLeft] = CGRectMake(0, FULL_LENGTH/2.+NET_HEIGHT, SIDE_WIDTH, FULL_LENGTH/2.-NET_HEIGHT);
        areas_front[tsBallSidelineRight] = CGRectMake(FULL_WIDTH-SIDE_WIDTH, FULL_LENGTH/2.+NET_HEIGHT, SIDE_WIDTH, FULL_LENGTH/2.-NET_HEIGHT);

        areas_front[tsBallLongLeft]  = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, FULL_LENGTH, AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);
        areas_front[tsBallLongRight] = CGRectMake(FULL_WIDTH/2, FULL_LENGTH, AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);

        areas_front[tsBallDeepLeft] = CGRectMake((FULL_WIDTH-SINGLE_WIDTH)/2., HALF_LENGTH+SERVICE_DIST, SINGLE_WIDTH/3., HALF_LENGTH-SERVICE_DIST);
        areas_front[tsBallDeepCenter] = CGRectMake((FULL_WIDTH-SINGLE_WIDTH)/2. + SINGLE_WIDTH/3., HALF_LENGTH+SERVICE_DIST, SINGLE_WIDTH/3., HALF_LENGTH-SERVICE_DIST);
        areas_front[tsBallDeepRight] = CGRectMake((FULL_WIDTH-SINGLE_WIDTH)/2. + SINGLE_WIDTH/3.*2., HALF_LENGTH+SERVICE_DIST, SINGLE_WIDTH/3., HALF_LENGTH-SERVICE_DIST);

        areas_front[tsBallServiceLeftBoxCenter] = CGRectMake(SIDE_WIDTH, HALF_LENGTH+NET_HEIGHT, SINGLE_WIDTH/2., SERVICE_DIST-NET_HEIGHT);
        areas_front[tsBallServiceRightBoxCenter] = CGRectMake(SIDE_WIDTH+SINGLE_WIDTH/2., HALF_LENGTH+NET_HEIGHT, SINGLE_WIDTH/2., SERVICE_DIST-NET_HEIGHT);

        areas_front[tsBallNet] = CGRectMake(0., HALF_LENGTH-NET_HEIGHT, FULL_WIDTH, NET_HEIGHT);
    }
    if (areas_back==nil) {
        areas_back = calloc(tsBallCourtAreaEnd, sizeof(CGRect));

        areas_back[tsBallWideLeft] = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2., 0, (AREA_WIDTH-FULL_WIDTH)/2., FULL_LENGTH/2.);
        areas_back[tsBallWideRight] = CGRectMake(FULL_WIDTH, 0., (AREA_WIDTH-FULL_WIDTH)/2., FULL_LENGTH/2.);

        areas_back[tsBallSidelineLeft] = CGRectMake(0., 0., SIDE_WIDTH, FULL_LENGTH/2.-NET_HEIGHT);
        areas_back[tsBallSidelineRight] = CGRectMake(FULL_WIDTH-SIDE_WIDTH, 0., SIDE_WIDTH, FULL_LENGTH/2.-NET_HEIGHT);

        areas_back[tsBallLongLeft]  = CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, (FULL_LENGTH-AREA_LENGTH)/2., AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);
        areas_back[tsBallLongRight] = CGRectMake(FULL_WIDTH/2, (FULL_LENGTH-AREA_LENGTH)/2., AREA_WIDTH/2., (AREA_LENGTH)/2-HALF_LENGTH);

        areas_back[tsBallDeepLeft] = CGRectMake((FULL_WIDTH-SINGLE_WIDTH)/2., 0., SINGLE_WIDTH/3., HALF_LENGTH-SERVICE_DIST);
        areas_back[tsBallDeepCenter] = CGRectMake((FULL_WIDTH-SINGLE_WIDTH)/2. + SINGLE_WIDTH/3., 0., SINGLE_WIDTH/3., HALF_LENGTH-SERVICE_DIST);
        areas_back[tsBallDeepRight] = CGRectMake((FULL_WIDTH-SINGLE_WIDTH)/2. + SINGLE_WIDTH/3.*2., 0., SINGLE_WIDTH/3., HALF_LENGTH-SERVICE_DIST);

        areas_back[tsBallServiceLeftBoxCenter] = CGRectMake(SIDE_WIDTH, HALF_LENGTH-SERVICE_DIST, SINGLE_WIDTH/2., SERVICE_DIST-NET_HEIGHT);
        areas_back[tsBallServiceRightBoxCenter] = CGRectMake(SIDE_WIDTH+SINGLE_WIDTH/2., HALF_LENGTH-SERVICE_DIST, SINGLE_WIDTH/2., SERVICE_DIST-NET_HEIGHT);

        areas_back[tsBallNet] = CGRectMake(0., HALF_LENGTH, FULL_WIDTH, NET_HEIGHT);
    }

    return side == tsCourtFront ? areas_front : areas_back;
}

-(BOOL)isLeftSide:(CGPoint)point{
    CGRect valid = RESCALE(CGRectMake((FULL_WIDTH-AREA_WIDTH)/2, (FULL_LENGTH-AREA_LENGTH)/2., AREA_WIDTH/2., AREA_LENGTH), _drawScale);
    return CGRectContainsPoint(valid, point);
}
-(BOOL)isRightSide:(CGPoint)point{
    return ![self isLeftSide:point];
}

-(BOOL)ballIsIn:(CGPoint)point shotFrom:(tsCourtSide)side{
    if (side == tsCourtBack) {
        CGRect valid = RESCALE(CGRectMake( SIDE_WIDTH, HALF_LENGTH+NET_HEIGHT, SINGLE_WIDTH, HALF_LENGTH-NET_HEIGHT), _drawScale);
        return CGRectContainsPoint(valid, point);
    }else{
        CGRect valid = RESCALE(CGRectMake( SIDE_WIDTH, 0, SINGLE_WIDTH, HALF_LENGTH-NET_HEIGHT), _drawScale);
        return CGRectContainsPoint(valid, point);
    }
}
-(BOOL)ballIsIn:(CGPoint)point serveFrom:(tsCourtSide)side left:(BOOL)left{
    CGRect * areas = [TSTennisCourtGeometry ballCourtAreaRects:side == tsCourtBack ? tsCourtFront : tsCourtBack];
    tsBallCourtArea area = left ? tsBallServiceRightBoxCenter : tsBallServiceLeftBoxCenter;
    //tsBallCourtArea was = [self ballCourtAreaForShotLocation:point];
    return CGRectContainsPoint(RESCALE(areas[area], _drawScale), point);
}


-(CGRect)rectForShotCourtArea:(tsShotCourtArea)area side:(tsCourtSide)side{
    CGRect * areas = [TSTennisCourtGeometry shotCourtAreaRects:side];
    return RESCALE(areas[area],_drawScale);
}
-(tsShotCourtArea)shotCourtAreaForShotLocation:(CGPoint)point{
    CGRect * areas = [TSTennisCourtGeometry shotCourtAreaRects:[self shotSideForLocation:point]];
    for (NSUInteger i=0; i<tsShotCourtAreaEnd; i++) {
        CGRect check = RESCALE(areas[i], _drawScale);
        if (CGRectContainsPoint(check,point)) {
            return i;
        }
    }
    return tsShotNoLocation;
}
-(tsCourtSide)shotSideForLocation:(CGPoint)point{
    BOOL inBack    = CGRectContainsPoint([self backHalfArea],point);
    /*NSLog(@"shot: %@ %@ back: %@", NSStringFromCGPoint(point),
          inBack ? @"In" : @"Not In",
          NSStringFromCGRect([self backHalfArea]));*/

    if (inBack) {
        return tsCourtBack;
    }else{
        return tsCourtFront;
    }

}

-(tsCourtSide)ballSideForLocation:(CGPoint)point{
    BOOL inBack    = CGRectContainsPoint([self backHalfArea],point);
    BOOL inBackNet = CGRectContainsPoint([self backNet], point);
    BOOL inFrontNet= CGRectContainsPoint([self frontNet], point);

    if ((inBack && !inFrontNet)||inBackNet) {
        return tsCourtBack;
    }else{
        return tsCourtFront;
    }
}

-(CGRect)rectForBallCourtArea:(tsBallCourtArea)area side:(tsCourtSide)side{
    CGRect * areas = [TSTennisCourtGeometry ballCourtAreaRects:side];
    return RESCALE(areas[area],_drawScale);

}
-(tsBallCourtArea)ballCourtAreaForShotLocation:(CGPoint)point{
    CGRect * areas =  [TSTennisCourtGeometry ballCourtAreaRects:[self ballSideForLocation:point]];
    for (NSUInteger i=0; i<tsBallCourtAreaEnd; i++) {
        CGRect check = RESCALE(areas[i], _drawScale);
        if (CGRectContainsPoint(check,point)) {
            return i;
        }
    }
    return tsBallNoLocation;

}

-(CGPoint)equivalentPointFront:(CGPoint)point{
    CGPoint rv = point;
    if (CGRectContainsPoint([self backHalfArea], point)) {
        CGPoint courtLocation = [self courtLocation:point];

        CGFloat middle_x = FULL_WIDTH/2.;
        CGFloat middle_y = FULL_LENGTH/2.;

        rv = CGPointMake( middle_x - (courtLocation.x-middle_x), middle_y - (courtLocation.y - middle_y) );
        rv = [self drawLocation:rv];
    }
    return rv;
}

-(CGPoint)equivalentPointBack:(CGPoint)point{
    CGPoint rv = point;
    if (!CGRectContainsPoint([self backHalfArea], point)) {
        CGPoint courtLocation = [self courtLocation:point];

        CGFloat middle_x = FULL_WIDTH/2.;
        CGFloat middle_y = FULL_LENGTH/2.;

        rv = CGPointMake( middle_x - (courtLocation.x-middle_x), middle_y - (courtLocation.y - middle_y) );
        rv = [self drawLocation:rv];
    }
    return rv;

}
-(CGRect)equivalentRectFront:(CGRect)rect{
    CGRect rv = rect;
    return rv;

}
-(CGRect)equivalentRectBack:(CGRect)rect{
    CGRect rv = rect;
    return rv;
}

@end
