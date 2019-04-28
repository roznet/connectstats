//  MIT Licence
//
//  Created on 10/10/2016.
//
//  Copyright (c) 2016 Brice Rosenzweig.
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

#import "GCLapSwim.h"

@implementation GCLapSwim

-(GCLapSwim*)initWithResultSet:(FMResultSet*)res{
    self = [super init];
    if (self) {
        self.lapIndex = [res intForColumn:@"lap"];
        self.time = [res dateForColumn:@"Time"];
        self.elapsed = [res doubleForColumn:@"SumDuration"];
        self.directSwimStroke = [res intForColumn:@"DirectSwimStroke"];
    }
    return self;
}

-(void)dealloc{
    [_label release];
    [super dealloc];
}

-(void)saveToDb:(FMDatabase *)trackdb{
    [self saveLengthToDb:trackdb index:self.lapIndex];
}

-(void)saveLengthToDb:(FMDatabase *)trackdb index:(NSUInteger)idx{
    // Prepare to share the code with lap
    // Currently still can't share because of the difference of indexing with lap and index fields
    
    NSString * tableMidFix = @"pool_lap";
    
    NSString * sqlInfo = [NSString stringWithFormat:@"INSERT INTO gc_%@_info (lap,field,value,uom) VALUES (?,?,?,?)",
                          tableMidFix
                          ];
    
    NSString * sql = [NSString stringWithFormat:@"INSERT INTO gc_%@ (lap,Time,SumDuration,lap,DirectSwimStroke) VALUES (?,?,?,?,?)",
                      tableMidFix];
    
    for (GCField * field in self.extra) {
        GCNumberWithUnit * nb = self.extra[field];
        if (![trackdb executeUpdate:sqlInfo,
              @(idx),
              field.key,
              [nb number],
              (nb.unit).key]){
            RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
        }
    }
    
    NSArray<GCField*>*native = [GCFields availableFieldsIn:self.trackFlags forActivityType:GC_TYPE_SWIMMING];
    for (GCField * field in native) {
        if( field.fieldFlag != gcFieldFlagNone && self.extra[field] == nil){
            GCNumberWithUnit * nb = [self numberWithUnitForField:field.fieldFlag andActivityType:GC_TYPE_SWIMMING];
            if( nb ){
                // VERY SCARY... need to reorg, here nil activity works because gcFieldFlag != None
                // This is to account for cases like HR where on import it get saved into the class member double values
                // as opposed to extra.
                // We need to revamp the whole saving mecanism to be more consistent whether field
                // come from member double or extra dictionary. This is bad design and difference between swim points
                // and regular gps points.
                if (![trackdb executeUpdate:sqlInfo,
                      @(idx),
                      field.key,
                      [nb number],
                      (nb.unit).key]){
                    RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
                }
            }
        }
    }
    if( self.distanceMeters > 0){
        // special case as distance otherwise not covered for swim
        if (![trackdb executeUpdate:sqlInfo,
              @(idx),
              @"SumDistance",
              @(self.distanceMeters),
              @"meter"]){
            RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
        }
    }

    if (![trackdb executeUpdate:sql,
          @(idx),
          self.time,
          @(self.elapsed),
          @(self.lapIndex),
          @(self.directSwimStroke)
          ]){
        RZLog( RZLogError, @"Failed sql %@",[trackdb lastErrorMessage]);
    };
}


-(void)saveLapToDb:(FMDatabase*)trackdb index:(NSUInteger)idx{
    for (GCField * field in self.extra) {
        GCNumberWithUnit * nb = self.extra[field];
        [trackdb executeUpdate:@"INSERT INTO gc_pool_lap_info (lap,field,value,uom) VALUES (?,?,?,?)",
         @(idx),field.key,nb.number,(nb.unit).key];
    }
    BOOL distanceGreaterThanZero = (self.distanceMeters>0.);
    [trackdb executeUpdate:@"INSERT INTO gc_pool_lap (lap,Time,SumDuration,DirectSwimStroke,Active) VALUES (?,?,?,?,?)",
     @(idx),
     self.time,
     @(self.elapsed),
     @(self.directSwimStroke),
     @(distanceGreaterThanZero)
     ];
}
-(void)recordField:(GCField*)field withUnit:(GCUnit*)unit inActivity:(GCActivity*)act{
    // Override track point record, as for lap we will have more fields
    // and we don't want them to be recorded as trackfields
}

@end
