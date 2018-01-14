//
//  FITFitMessage.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 08/05/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import "FITFitMessage.h"
#import "FITFitMessageFields.h"
#import "FITFitFieldValue.h"

@interface FITFitMessage ()

@property (nonatomic,strong) NSMutableArray<FITFitMessageFields*> * fields;
@property (nonatomic,strong) NSString * messageType;
@property (nonatomic,strong) NSMutableDictionary<NSString*,FITFitFieldValue*> * samples;

@property (nonatomic,assign) fit::Mesg * originalMesg;

@end

@implementation FITFitMessage

-(void)dealloc{
    if (_originalMesg) {
        delete _originalMesg;
    }
#if !__has_feature(objc_arc)
    [_fields release];
    [_messageType release];
    [_samples release];
    
    [super dealloc];
#endif
}
-(NSString*)description{
    return [NSString stringWithFormat:@"<%@:%@[%lu keys, %lu values]>", NSStringFromClass([self class]),
            self.messageType,
            (unsigned long)self.samples.count,
            (unsigned long)self.fields.count];
}
-(void)setFromMesg:(fit::Mesg *)mesg{
    self.originalMesg = new fit::Mesg(*mesg);
}

-(fit::Mesg*)mesg{
    return self.originalMesg;
}

+(FITFitMessage*)messageWithType:(NSString*)type{
    FITFitMessage * rv = RZReturnAutorelease([[FITFitMessage alloc] init]);
    if (rv) {
        rv.messageType = type;
        rv.fields = [NSMutableArray array];
        rv.samples = [NSMutableDictionary dictionary];
        rv.originalMesg = nil;
    }
    return rv;
}

-(void)addMessageFields:(FITFitMessageFields *)fields{
    for (NSString * key in fields.allFieldNames) {
        self.samples[key] = fields[key];
    }

    [self.fields addObject:fields];
}
-(NSUInteger)count{
    return _fields.count;
}

#pragma mark - Keys

-(NSArray<NSString*>*)allLocationKeys{
    NSMutableArray * rv = [NSMutableArray array];
    
    for (NSString * key in self.samples) {
        FITFitFieldValue * value = self.samples[key];
        if (value.locationValue) {
            [rv addObject:key];
        }
    }
    return rv;
}

-(NSArray<NSString*>*)allNumberKeys{
    NSMutableArray * rv = [NSMutableArray array];
    
    for (NSString * key in self.samples) {
        FITFitFieldValue * value = self.samples[key];
        if (value.numberWithUnit) {
            [rv addObject:key];
        }
    }
    return rv;
}

-(NSArray<NSString*>*)allDateKeys{
    NSMutableArray * rv = [NSMutableArray array];
    
    for (NSString * key in self.samples) {
        FITFitFieldValue * value = self.samples[key];
        if (value.dateValue) {
            [rv addObject:key];
        }
    }
    return rv;
}

-(NSArray<NSString*>*)allAvailableFieldKeys{
    return self.samples.allKeys;
}

-(NSArray<NSString*>*)allSortedFieldKeys{
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    NSMutableDictionary * samples = [NSMutableDictionary dictionary];
    
    for (FITFitMessageFields*field in _fields) {
        for (NSString * key in field.allFieldNames) {
            samples[key] = field[key];
            NSNumber * sofar = rv[key];
            if (sofar == nil) {
                rv[key] = @(1);
            }else{
                rv[key] = @( sofar.integerValue+1);
            }
        }
    }
    return [rv.allKeys sortedArrayUsingComparator:^(NSString * s1, NSString *s2){
        NSNumber * i1 = rv[s1];
        NSNumber * i2 = rv[s2];
        
        FITFitFieldValue * f1 = samples[s1];
        FITFitFieldValue * f2 = samples[s2];
    
        NSUInteger c1 = [f1 sortCategory];
        NSUInteger c2 = [f2 sortCategory];
        
        if( c1 == c2){
            return [i2 compare:i1];
        }else if( c1 < c2){
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
}

-(BOOL)containsFieldKey:(NSString*)key{
    return _samples[key] != nil;
}
-(BOOL)containsNumberKey:(NSString*)key{
    return _samples[key].numberWithUnit != nil;
}
-(BOOL)containsDateKey:(NSString*)key{
    return _samples[key].dateValue != nil;
}

#pragma mark - Rows

-(FITFitMessageFields*)last{
    return _fields.lastObject;
}

-(FITFitMessageFields*)fieldForIndex:(NSUInteger)idx{
    return idx < _fields.count ? _fields[idx] : nil;
}

-(FITFitMessageFields*)objectAtIndexedSubscript:(NSUInteger)idx{
    return idx < _fields.count ? _fields[idx] : nil;
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len{
    return [_fields countByEnumeratingWithState:state objects:buffer count:len];
}


@end
