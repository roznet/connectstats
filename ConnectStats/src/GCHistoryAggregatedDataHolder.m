//  MIT License
//
//  Created on 04/08/2020 for ConnectStats
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



#import "GCHistoryAggregatedDataHolder.h"
#import "GCActivity+Fields.h"

@interface GCHistoryAggregatedDataHolder ()
@property (nonatomic,assign) BOOL started;
@property (nonatomic,assign) double * stats;
@property (nonatomic,assign) BOOL * flags;

@property (nonatomic,retain) NSArray<GCField*>*fields;
@property (nonatomic,retain) NSMutableArray<GCUnit*>*units;
@property (nonatomic,assign) size_t indexForDurationField;
@property (nonatomic,assign) size_t indexForDistanceField;

@end

@implementation GCHistoryAggregatedDataHolder

-(GCHistoryAggregatedDataHolder*)init{
    return [self initForDate:[NSDate date] andFields:@[]];
}

-(GCHistoryAggregatedDataHolder*)initForDate:(NSDate*)adate andFields:(NSArray<GCField*>*)fields{
    self = [super init];
    if (self) {
        _stats = nil;
        _flags = nil;
        self.date = adate;
        [self setupForFields:fields];
    }
    return self;

}
-(gcAggregatedType)preferredAggregatedTypeForField:(GCField*)field{
    if( field.canSum){
        return gcAggregatedSum;
    }else{
        return gcAggregatedAvg;
    }
}

-(void)setupForFields:(NSArray<GCField*>*)fields{
    self.fields = fields;
    self.units = [NSMutableArray array];
    for (GCField * field in fields) {
        [self.units addObject:field.unit.referenceUnit ?: [GCUnit dimensionless]];
    }
    size_t n = gcAggregatedTypeEnd*fields.count;
    
    if( _stats ){
        free( _stats );
    }
    if( _flags ){
        free(_flags);
    }
    _stats = malloc(sizeof(double)*n);
    _flags = malloc(sizeof(BOOL)*fields.count);
    
    for (size_t i=0; i<n; i++) {
        _stats[i] = 0.;
    }
    self.indexForDurationField = fields.count;
    self.indexForDistanceField = fields.count;
    
    for (size_t i=0; i<fields.count; i++) {
        GCField * field = fields[i];
        if( field.fieldFlag == gcFieldFlagSumDuration){
            self.indexForDurationField = i;
        }
        if( field.fieldFlag == gcFieldFlagSumDistance){
            self.indexForDistanceField = i;
        }
        _flags[i]=false;
    }
    _started = false;
}

-(void)dealloc{
    [_activityType release];
    if( _stats){
        free(_stats);
    }
    if( _flags){
        free(_flags);
    }
    [_date release];
    [_fields release];
    [_units release];
    [super dealloc];
}

-(NSString*)description{
    NSMutableString * rv = [NSMutableString stringWithFormat:@"<GCHistoryAggregatedDataHolder:%@>",
            [self.date dateShortFormat]];
    size_t n = self.fields.count;
    for (size_t i=0; i<n; i++) {
        GCField * field = self.fields[i];
        if (_flags[i]) {
            [rv appendFormat:@"\n  %@: cnt=%.0f sum=%.1f avg=%.0f (%@)",
             field,
             _stats[i*gcAggregatedTypeEnd+gcAggregatedCnt],
             _stats[i*gcAggregatedTypeEnd+gcAggregatedSum],
             _stats[i*gcAggregatedTypeEnd+gcAggregatedAvg],
             self.units[i]
             ];
        }else{
            [rv appendFormat:@"\n  %@: N/A", field];
        }
    }
    return rv;
}

-(NSArray<GCField*>*)availableFields{
    NSMutableArray<GCField*>*rv = [NSMutableArray array];
    for (size_t i=0; i<self.fields.count; i++) {
        if( self.flags[i]){
            [rv addObject:self.fields[i]];
        }
    }
    return rv;
}

-(void)aggregateActivity:(GCActivity*)act{
    size_t fieldEnd = self.fields.count;
    // don't bother if no fields
    if( fieldEnd == 0 ){
        return;
    }
    double data[fieldEnd];
    
    BOOL hasField[fieldEnd];;
    for( size_t i=0;i<fieldEnd;i++){
        GCNumberWithUnit * nu = [act numberWithUnitForField:self.fields[i]];
        if( nu.value == 0. && (!self.fields[i].isZeroValid) ){
            // power of zero means didn't record
            nu = nil;
        }

        if( self.fields[i].fieldFlag != gcFieldFlagNone && ( ( self.fields[i].fieldFlag & act.flags ) == 0) ){
            if( nu != nil){
                RZLog(RZLogInfo, @"counting missing %@ %@ %@", act, self.fields[i], nu);
            }
        }
        
        if( nu ){
            GCUnit * unit = self.units[i];
            data[i] = [unit convertDouble:nu.value fromUnit:nu.unit];
            if( isnan(data[i])){
                RZLog(RZLogInfo, @"%@ %@ %@ %@", act, self.fields[i], nu, @([unit convertDouble:nu.value fromUnit:nu.unit]));
            }
            hasField[i] = true;
        }else{
            hasField[i] = false;
        }
    }
    
    if (_activityType==nil) {
        self.activityType = act.activityType;
    }else if (![_activityType isEqualToString:act.activityType]){
        // mixed activity become all
        self.activityType = GC_TYPE_ALL;
    }

    if (!_started) {
        // first round set everything to current data
        _started = true;
        for (size_t f = 0; f<fieldEnd; f++) {
            for (size_t s = 0; s<gcAggregatedTypeEnd; s++) {
                if (hasField[f]) {
                    self.flags[f] = true;
                    if (s == gcAggregatedCnt) {
                        _stats[f*gcAggregatedTypeEnd+s] = 1.;
                    }else if (s == gcAggregatedSsq){
                        _stats[f*gcAggregatedTypeEnd+s] = data[f]*data[f];
                    }else{
                        _stats[f*gcAggregatedTypeEnd+s] = data[f];
                    }
                }else{
                    if (s == gcAggregatedCnt) {
                        _stats[f*gcAggregatedTypeEnd+s] = 0.;
                    }else{
                        _stats[f*gcAggregatedTypeEnd+s] = 0.;
                    }
                }
            }
        }
    }else{
        double dur_w0 = 0.;
        double dur_w1 = 1.;
        if( self.indexForDurationField < self.fields.count){
            dur_w0  = _stats[self.indexForDurationField*gcAggregatedTypeEnd+gcAggregatedSum];
            dur_w1  = data[self.indexForDurationField];
        }
        double dur_tot = dur_w0+dur_w1;

        for (size_t f =0; f<fieldEnd; f++) {
            if (hasField[f]) {
                _flags[f]=true;
                _stats[f*gcAggregatedTypeEnd+gcAggregatedSsq] += data[f]*data[f];
                _stats[f*gcAggregatedTypeEnd+gcAggregatedSum] += data[f];
                _stats[f*gcAggregatedTypeEnd+gcAggregatedAvg] += data[f];
                _stats[f*gcAggregatedTypeEnd+gcAggregatedCnt] += 1.;
                _stats[f*gcAggregatedTypeEnd+gcAggregatedMax] = MAX(data[f], _stats[f*gcAggregatedTypeEnd+gcAggregatedMax]);
                _stats[f*gcAggregatedTypeEnd+gcAggregatedMin] = MIN(data[f], _stats[f*gcAggregatedTypeEnd+gcAggregatedMin]);
                _stats[f*gcAggregatedTypeEnd+gcAggregatedWvg] = (_stats[f*gcAggregatedTypeEnd+gcAggregatedWvg]*dur_w0+data[f]*dur_w1)/dur_tot;
            }
        }
    }
}

-(void)aggregateEnd:(NSDate*)adate{
    size_t fieldEnd = self.fields.count;
    int dummy = 0;
    for (size_t f =0;f<fieldEnd; f++) {
        
        if( self.fields[f].fieldFlag == gcFieldFlagPower ){
            dummy++;
        }

        double cnt = _stats[f*gcAggregatedTypeEnd+gcAggregatedCnt];
        double sum = _stats[f*gcAggregatedTypeEnd+gcAggregatedSum];
        double ssq = _stats[f*gcAggregatedTypeEnd+gcAggregatedSsq];

        if (cnt>0) {
            _stats[f*gcAggregatedTypeEnd+gcAggregatedAvg] /= cnt;
            _stats[f*gcAggregatedTypeEnd+gcAggregatedStd] = STDDEV(cnt, sum, ssq);
        }
    }
    if (adate) {
        self.date = adate;
    }
}

-(nullable GCNumberWithUnit*)preferredNumberWithUnit:(GCField*)field{
    gcAggregatedType type = [self preferredAggregatedTypeForField:field];
    
    if( [field.unit.referenceUnitKey isEqualToString:@"mps"] ){
        // Special case for speed, override
        GCNumberWithUnit * durationN = [self numberWithUnit:[GCField fieldForFlag:gcFieldFlagSumDuration andActivityType:field.activityType] statType:gcAggregatedSum];
        GCNumberWithUnit * distanceN = [self numberWithUnit:[GCField fieldForFlag:gcFieldFlagSumDistance andActivityType:field.activityType] statType:gcAggregatedSum];
        GCNumberWithUnit * rv = [GCNumberWithUnit numberWithUnitName:@"mps" andValue:[distanceN convertToUnitName:@"meter"].value/durationN.value];
        rv = [rv convertToUnit:field.unit];
        return rv;
    }else{
        return [self numberWithUnit:field statType:type];
    }
}

-(GCNumberWithUnit*)numberWithUnit:(GCField*)field statType:(gcAggregatedType)s{

    double val = 0.;
    GCUnit * displayUnit = field.unit;
    displayUnit = [displayUnit unitForGlobalSystem];
    GCUnit * unit = nil;
    size_t f = 0;
    
    for( ; f < self.fields.count; f++){
        if( [field matchesField:self.fields[f]] ){
            break;
        }
    }
    if(f*gcAggregatedTypeEnd+s<gcAggregatedTypeEnd*self.fields.count){
        val = _stats[f*gcAggregatedTypeEnd+s];
        switch (s) {
            case gcAggregatedCnt:
                return [GCNumberWithUnit numberWithUnit:[GCUnit dimensionless] andValue:val];
            default:
            {
                unit = self.units[f];
                if (![displayUnit isEqualToUnit:unit]) {
                    val = [displayUnit convertDouble:val fromUnit:unit];
                }
                return [GCNumberWithUnit numberWithUnit:displayUnit andValue:val];

            }
        }
    }else{
        return nil;
    }

}

-(BOOL)hasField:(GCField *)field{
    for (GCField * one in self.fields) {
        if( [field matchesField:one] ){
            return true;
        }
    }
    return false;
}

-(BOOL)isAfter:(NSDate*)after{
    return [after compare:self.date] != NSOrderedAscending;
}
@end
