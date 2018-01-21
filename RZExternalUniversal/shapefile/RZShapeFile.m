//  MIT Licence
//
//  Created on 17/03/2015.
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

#import "RZShapeFile.h"
#import "shapefil.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

static RZShapeFile * currentFile = nil;

void RZHErrFunc(const char * message){
    if (currentFile) {
        [currentFile setLastErrorMessage:[NSString stringWithCString:message encoding:NSUTF8StringEncoding]];
    }
}


@interface RZShapeFileAnnotation : NSObject<MKAnnotation>
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString * savedTitle;
@property (nonatomic,retain) NSString * savedSubTitle;
@end

@implementation RZShapeFileAnnotation

-(NSString*)title{
    return self.savedTitle;
}
-(NSString*)subtitle{
    return self.savedSubTitle;
}
@end


@interface RZShapeFile ()
@property (nonatomic,retain) NSString * base;
@property (nonatomic,retain) NSArray * values;
@property (nonatomic,retain) NSString * lastErrorMessage;
@end

@implementation RZShapeFile

+(RZShapeFile*)shapeFileWithBase:(NSString*)base{
    RZShapeFile * rv = [[RZShapeFile alloc] init];
    if (rv) {
        SAErrorFuncSet(&RZHErrFunc);
        rv.base = base;
        [rv parseDbf];
    }
    return rv;
}

-(void)parseDbf{
    self.lastErrorMessage = nil;
    NSString * dbf = [self.base stringByAppendingPathExtension:@"dbf"];
    DBFHandle handle = DBFOpen( [dbf cStringUsingEncoding:NSUTF8StringEncoding] , "rb");
    NSMutableArray * vals = [NSMutableArray array];

    if( handle){
        int nf = DBFGetFieldCount(handle);

        char pszFieldName[15];
        int pnWidth;
        int pnDecimals;

        NSMutableArray * fields= [NSMutableArray array];

        for (int i =0; i< nf; i++) {
            DBFFieldType ft = DBFGetFieldInfo( handle, i, pszFieldName,
                                              &pnWidth, &pnDecimals );
            [fields addObject:@[ [NSString stringWithCString:pszFieldName encoding:NSUTF8StringEncoding], @(ft) ]];
        }

        int nr = DBFGetRecordCount( handle );
        for (int r = 0; r < nr; r++) {
            NSMutableDictionary * one = [NSMutableDictionary dictionary];
            for (int i =0 ; i<nf; i++) {
                NSString * name = fields[i][0];
                DBFFieldType ft = (DBFFieldType)[fields[i][1] intValue];
                switch (ft) {
                    case FTString:{
                        NSString * val = [NSString stringWithCString: DBFReadStringAttribute(handle, r, i)  encoding:NSUTF8StringEncoding];
                        if (val) {
                            one[ name ] =val;
                        }
                        break;

                    }
                    case FTInteger:
                        one[ name ] = @( DBFReadIntegerAttribute(handle, r, i));
                        break;
                    case FTDouble:
                        one[ name ] =@( DBFReadDoubleAttribute(handle, r, i));
                        break;
                    default:
                        break;
                }

            }
            [vals addObject:one];
        }
        DBFClose(handle);
    }else{
        NSString * shf = [self.base stringByAppendingPathExtension:@"shp"];

        self.lastErrorMessage = nil;

        SHPHandle hSHP = SHPOpen( [shf cStringUsingEncoding:NSUTF8StringEncoding], "rb" );
        if (hSHP) {
            int pnEntities;
            int pnShapeType;

            SHPGetInfo( hSHP, &pnEntities, &pnShapeType, NULL, NULL );
            for (NSUInteger i=0; i<pnEntities; i++) {
                [vals addObject:@{@"SHAPE": [NSString stringWithFormat:@"SHAPE%d", (int)i]}];
            }
            SHPClose(hSHP);
        }
    }
    self.values = vals;
}
-(NSArray*)allShapes{
    return self.values;
}

-(NSString*)fileBaseName{
    return [self.base lastPathComponent];
}

-(MKPolygon*)mapPointsForShapeIn:(SHPObject*)shapeObject index:(int)idx part:(int)p{
    MKPolygon * rv = nil;
    if (shapeObject->nSHPType==SHPT_POLYGON) {
        int from = p < shapeObject->nParts ? shapeObject->panPartStart[p] : 0;
        int to = p+1 < shapeObject->nParts ? shapeObject->panPartStart[p+1]: shapeObject->nVertices;

        CLLocationCoordinate2D * coordinates = malloc(sizeof(CLLocationCoordinate2D)*(to-from));

        CLLocationCoordinate2D * one = coordinates;
        for (int i =from; i<to; i++) {
            (*one).longitude = shapeObject->padfX[i];
            (*one).latitude = shapeObject->padfY[i];
            one++;
        }
        rv = [MKPolygon polygonWithCoordinates:coordinates count:(to-from)];
        free(coordinates);
    }
    return rv;
}

-(RZShapeFileAnnotation*)annotationForShapeIn:(SHPObject*)shapeObject index:(int)idx part:(int)p{
    RZShapeFileAnnotation * rv = nil;
    if (shapeObject->nSHPType==SHPT_POINT && p == 0) {
        rv =  [[RZShapeFileAnnotation alloc] init];
        rv.coordinate = CLLocationCoordinate2DMake(shapeObject->padfY[0], shapeObject->padfX[0]);
        rv.savedTitle = @"Title";
        rv.savedSubTitle = @"SubTitle";

    }
    return rv;
}

-(NSIndexSet*)indexSetForShapeMatching:(shapeMatchingFunc)match{
    NSUInteger i = 0;
    NSMutableIndexSet * rv = [NSMutableIndexSet indexSet];
    for (NSDictionary * one in self.values) {
        if (match(one)) {
            [rv addIndex:i];
        }
        i++;
    }
    return rv;
}

-(NSArray*)polygonsForIndexSet:(NSIndexSet*)idxset{
    NSString * shf = [self.base stringByAppendingPathExtension:@"shp"];

    self.lastErrorMessage = nil;

    SHPHandle hSHP = SHPOpen( [shf cStringUsingEncoding:NSUTF8StringEncoding], "rb" );

    if (!hSHP) {
        return @[];
    }
    int pnEntities;
    int pnShapeType;

    SHPGetInfo( hSHP, &pnEntities, &pnShapeType, NULL, NULL );

    NSMutableArray * rv = [NSMutableArray array];

    [idxset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * stop){
        int i = (int)idx;
        if (i < pnEntities) {
            SHPObject *sh = SHPReadObject(  hSHP, i );
            if (sh->nParts==0) {
                id obj = [self mapPointsForShapeIn:sh index:i part:0];
                if (obj) {
                    [rv addObject:obj];
                }
                obj = [self annotationForShapeIn:sh  index:i part:0];
                if (obj) {
                    [rv addObject:obj];
                }
            }else{
                for (int p=0; p<sh->nParts; p++) {
                    [rv addObject:[self mapPointsForShapeIn:sh index:i part:p]];
                }
            }
            SHPDestroyObject(sh);
        }
    }];
    SHPClose(hSHP);
    return rv;

}
@end
