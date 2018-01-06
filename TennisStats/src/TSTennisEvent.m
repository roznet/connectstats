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

#import "TSTennisEvent.h"
#import "TSTennisCourtGeometry.h"
#import "TSTennisFields.h"

static NSArray * _s_types = nil;
static NSDictionary * _s_typesMap = nil;

@interface TSTennisEvent ()

@end

@implementation TSTennisEvent



+(NSString*)descriptionForEvent:(tsEvent)type{
    if (_s_types == nil) {
        _s_types = @[
                     @"None",
                     @"Shot",
                     @"Ball",
                     @"BackPlayerWon",
                     @"BackPlayerLost",
                     @"FrontPlayerWon",
                     @"FrontPlayerLost",
                     @"PlayerSwitchSide",
                     @"RallyResult",
                     @"PlayerUpdateScore",
                     @"OpponentUpdateScore",
                     @"Tag"

                  ];
    }
    return type < _s_types.count ? _s_types[type] : [NSString stringWithFormat:@"Event%d", (int)type];
}

+(tsEvent)eventForDescription:(NSString*)desc{
    if (_s_typesMap == nil) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:tsEventEnd];
        for (tsEvent t = tsEventNone; t<tsEventEnd; t++) {
            dict[[TSTennisEvent descriptionForEvent:t]] = @(t);
        }
        _s_typesMap = dict;
    }
    return [_s_typesMap[desc] intValue];
}

+(TSTennisEvent*)event:(tsEvent)type{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [NSDate date];
        rv.type = type;
        rv.location = CGPointZero;
        rv.delta = CGPointZero;
        rv.gamma = CGPointZero;
    }
    return rv;
}
+(TSTennisEvent*)event:(tsEvent)type withValue:(CGFloat)value{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [NSDate date];
        rv.type = type;
        rv.location = CGPointMake(value, 0.);
        rv.delta = CGPointZero;
        rv.gamma = CGPointZero;
    }
    return rv;

}
+(TSTennisEvent*)event:(tsEvent)type withValue:(CGFloat)value second:(CGFloat)second{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [NSDate date];
        rv.type = type;
        rv.location = CGPointMake(value, second);
        rv.delta = CGPointZero;
        rv.gamma = CGPointZero;
    }
    return rv;

}
+(TSTennisEvent*)event:(tsEvent)type withValue:(CGFloat)value second:(CGFloat)second third:(CGFloat)third{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [NSDate date];
        rv.type = type;
        rv.location = CGPointMake(value, second);
        rv.delta    = CGPointMake(third, 0.);
        rv.gamma = CGPointZero;
    }
    return rv;

}


+(TSTennisEvent*)event:(tsEvent)type withLocation:(CGPoint)point{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [NSDate date];
        rv.type = type;
        rv.location = point;
        rv.delta = CGPointZero;
        rv.gamma = CGPointZero;
    }
    return rv;
}
+(TSTennisEvent*)event:(tsEvent)type withLocation:(CGPoint)point andDelta:(CGPoint)delta{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [NSDate date];
        rv.type = type;
        rv.location = point;
        rv.delta = delta;
        rv.gamma = CGPointZero;
    }
    return rv;
}
+(TSTennisEvent*)event:(tsEvent)type withLocation:(CGPoint)point andDelta:(CGPoint)delta andGamma:(CGPoint)gamma{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [NSDate date];
        rv.type = type;
        rv.location = point;
        rv.delta = delta;
        rv.gamma = gamma;
    }
    return rv;

}
+(TSTennisEvent*)eventWithResultSet:(FMResultSet*)res{
    TSTennisEvent * rv = [[TSTennisEvent alloc] init];
    if (rv) {
        rv.time = [res dateForColumn:@"time"];
        rv.type = [res intForColumn:@"type"];
        rv.location = CGPointMake([res doubleForColumn:@"x"],[res doubleForColumn:@"y"]);
        rv.delta = CGPointMake([res doubleForColumn:@"dx"],[res doubleForColumn:@"dy"]);;
        if ([res columnExists:@"d2x"]) {
            rv.gamma = CGPointMake([res doubleForColumn:@"d2x"], [res doubleForColumn:@"d2y"]);
        }else{
            rv.gamma = CGPointZero;
        }
    }
    return rv;
}

-(NSString*)description{
    NSMutableArray * elements = [NSMutableArray array];

    [elements addObject:[NSString stringWithFormat:@"%@:%@", NSStringFromClass([self class]),
                         [TSTennisEvent descriptionForEvent:self.type]] ];

    if (self.location.x != 0. && self.location.y != 0.) {
        [elements addObject:[NSString stringWithFormat:@"{%.2f,%.2f}",self.location.x,self.location.y]];
    }
    if (self.delta.x != 0. && self.delta.y != 0.) {
        [elements addObject:[NSString stringWithFormat:@"{%.2f,%.2f}",self.delta.x,self.delta.y]];
    }

    switch (self.type) {
        case tsEventShot:
            [elements addObject:[NSString stringWithFormat:@"P:%@", [TSTennisFields courtSideDescription:self.playerCourtSide]]];
            [elements addObject:[NSString stringWithFormat:@"S:%@", [TSTennisFields courtSideDescription:self.shotCourtSide]]];
            break;

        default:
            break;
    }
    return [NSString stringWithFormat:@"<%@>", [elements componentsJoinedByString:@","]];
}

-(void)saveToDb:(FMDatabase*)db{
    [db executeUpdate:@"INSERT INTO events (time,type,x,y,dx,dy,d2x,d2y) VALUES (?,?,?,?,?,?,?,?)",
     self.time,
     @(self.type),
     @(self.location.x),
     @(self.location.y),
     @(self.delta.x),
     @(self.delta.y),
     @(self.gamma.x),
     @(self.gamma.y)];
}

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"events"]) {
        [db executeUpdate:@"CREATE TABLE events (time REAL, type REAL, x REAL,y REAL, dx REAL, dy REAL, d2x REAL, d2y REAL)"];
    }
    if (![db columnExists:@"d2x" inTableWithName:@"events"]) {
        [db executeUpdate:@"ALTER TABLE events ADD COLUMN d2y REAL DEFAULT 0"];
        [db executeUpdate:@"ALTER TABLE events ADD COLUMN d2x REAL DEFAULT 0"];
    }
}

#pragma mark - interpretation

-(tsShotCourtArea)shotCourtArea{
    tsShotCourtArea rv = tsShotNoLocation;
    if (self.type==tsEventShot) {
        rv = [[TSTennisCourtGeometry court] shotCourtAreaForShotLocation:self.location];
    }
    return rv;
}

-(tsBallCourtArea)ballCourtArea{
    tsBallCourtArea rv = tsBallNoLocation;
    if (self.type==tsEventBall) {
        rv = [[TSTennisCourtGeometry court] ballCourtAreaForShotLocation:self.location];
    }
    return rv;
}

-(tsShotType)shotType{
    if (self.type != tsEventShot) {
        return tsShotNone;
    }
    tsShotType rv = tsShotForehand;
    tsCourtSide side = [self shotCourtSide];

    if (fabs(_delta.x)<fabs(_delta.y) * 0.3) {
        rv = tsShotServe;
    }else{

        if (side == tsCourtFront) {
            if (_delta.x > 0) {
                rv = tsShotForehand;
            }else{
                rv = tsShotBackhand;
            }
        }else{
            if (_delta.x < 0) {
                rv = tsShotForehand;
            }else{
                rv = tsShotBackhand;
            }
        }
    }
    return rv;
}
-(tsShotStyle)shotStyle{
    tsShotStyle rv = tsNeutralShot;

    if (self.gamma.x != 0. || self.gamma.y != 0.) {
        tsCourtSide side = [self shotCourtSide];
        if (side == tsCourtFront) {
            if (_gamma.y < 0) {
                rv = tsAggressiveShot;
            }else{
                rv = tsDefensiveShot;
            }
        }else{
            if (_gamma.y > 0) {
                rv = tsAggressiveShot;
            }else{
                rv = tsDefensiveShot;
            }
        }
    }
    return rv;
}

-(tsShotCategory)shotCategory{
    tsShotCourtArea area = [self shotCourtArea];
    tsShotStyle style = [self shotStyle];
    tsShotType type = [self shotType];
    if (type == tsShotServe) {
        return tsCategoryServe;
    }
    if (style == tsDefensiveShot) {
        return tsCategoryDefence;
    }
    switch (area) {
        case tsShotDeepLeft:
        case tsShotDeepRight:
            return tsCategoryReactive;
        case tsShotShortLeft:
        case tsShotShortRight:
            return tsCategoryProactive;
        case tsShotNetLeft:
        case tsShotNetRight:
            return tsCategoryNet;
        case tsShotCourtAreaEnd:
        case tsShotNoLocation:
            return tsCategoryNone;
    }
    return tsCategoryNone;
}

-(tsCourtSide)shotCourtSide{
    tsCourtSide rv = tsCourtBack;
    TSTennisCourtGeometry * geometry = [TSTennisCourtGeometry court];
    switch (self.type) {
        case tsEventBackPlayerLost:
        case tsEventBackPlayerWon:
            rv = tsCourtBack;
            break;
        case tsEventFrontPlayerLost:
        case tsEventFrontPlayerWon:
            rv = tsCourtFront;
            break;
        case tsEventBall:
        case tsEventShot:
        {
            rv = [geometry shotSideForLocation:self.location];
            break;
        }
        case tsEventEnd:
        case tsEventNone:
        case tsEventPlayerSwithSide:
        case tsEventRallyResult:
        case tsEventOpponentUpdateScore:
        case tsEventPlayerUpdateScore:
        case tsEventTag:
            rv = tsCourtUnknownSide;
            break;
    }
    return rv;
}
-(tsCourtSide)playerCourtSide{
    tsCourtSide side = [self shotCourtSide];
    if (self.type == tsEventBall) {
        if (side == tsCourtFront) {
            return tsCourtBack;
        }else if (side == tsCourtBack){
            return tsCourtFront;
        }else{
            return tsCourtUnknownSide;
        }
    }else{
        if (side == tsCourtFront) {
            return tsCourtFront;
        }else if (side == tsCourtBack){
            return tsCourtBack;
        }else{
            return tsCourtUnknownSide;
        }

    }
}

-(BOOL)isLeftSide{
    return [[TSTennisCourtGeometry court] isLeftSide:self.location];
}
-(BOOL)ballIsIn:(CGPoint)shotLocation{
    BOOL rv = false;
    TSTennisCourtGeometry * geometry = [TSTennisCourtGeometry court];

    rv = [geometry ballIsIn:self.location shotFrom:[geometry shotSideForLocation:shotLocation]];
    return rv;
}
-(BOOL)ballIsInServe:(CGPoint)shotLocation{
    BOOL rv = false;
    TSTennisCourtGeometry * geometry = [TSTennisCourtGeometry court];
    rv = [geometry ballIsIn:self.location serveFrom:[geometry shotSideForLocation:shotLocation] left:[geometry isLeftSide:shotLocation]];
    return rv;
}


@end
