//  MIT Licence
//
//  Created on 26/03/2016.
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

#import "GCFieldCache.h"
#import "GCFieldInfo.h"
#import "GCFieldsDefs.h"
#import "GCField.h"
#import "GCHealthMeasure.h"
#import "GCActivityType.h"
// Only if iPhone/ConnectStats on mac, no calculated fields
#if TARGET_OS_IPHONE
#import "GCFieldsCalculated.h"
#endif

NS_INLINE NSString * cacheFieldKey(NSString*field,NSString*activityType){
    return [field stringByAppendingString:activityType ?:@"NIL"] ?: @"NIL";
}

NS_INLINE NSString * cacheActivityTypeKey(NSString*activityType){
    return activityType ?:@"NIL";
}

static NSMutableDictionary * _missingFieldCache = nil;

@interface GCFieldCache ()
@property (nonatomic,retain) NSMutableDictionary<GCField*,GCFieldInfo*>*cache;

@property (nonatomic,retain) NSDictionary<NSString*,GCFieldInfo*>*predefinedFieldCache;
@property (nonatomic,retain) NSDictionary<NSString*,GCFieldInfo*>*predefinedActivityTypeCache;
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) dispatch_queue_t worker;
@end

@implementation GCFieldCache
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_db release];
    [_cache release];
    [_predefinedFieldCache release];
    [_predefinedActivityTypeCache release];
    [_worker release];

    [super dealloc];
}
#endif

+(NSArray*)availableLanguagesCodes{
    return @[ @"en", @"fr", @"ja", @"de", @"it", @"es", @"pt", @"zh"];
}

+(NSArray*)availableLanguagesNames{
    NSArray * arr = [GCFieldCache availableLanguagesCodes];
    NSMutableArray * names = [NSMutableArray arrayWithCapacity:arr.count];
    for (NSString *lan in arr) {
        [names addObject:[RZReturnAutorelease([[NSLocale alloc] initWithLocaleIdentifier:lan]) displayNameForKey:NSLocaleIdentifier value:lan]];
    }
    return names;
}

+(GCFieldCache*)cacheWithDb:(FMDatabase*)db andLanguage:(NSString*)language{
    GCFieldCache * rv = RZReturnAutorelease([[GCFieldCache alloc] init]);
    if (rv) {
        if(db){
            [GCFieldCache ensureDbStructure:db];
        }
        rv.db = db;
        [rv buildPredefinedCacheForLanguage:language];
    }
    return rv;
}


#pragma mark - Build Cache

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_fields"]) {
        [db executeUpdate:@"CREATE TABLE gc_fields (field TEXT, activityType TEXT, fieldDisplayName TEXT, uom TEXT)"];
    }
}

-(void)buildPredefinedCacheForLanguage:(nullable NSString*)languageInput{
    NSString * language = languageInput ?: [[NSLocale preferredLanguages][0] substringToIndex:2];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields_new.db"]];
    [db open];

    NSMutableDictionary * displays = [NSMutableDictionary dictionary];
    
    FMResultSet * res = [db executeQuery:@"SELECT * From gc_fields_display"];
    while( [res next]){
        NSString * field = [res stringForColumn:@"field"];
        NSString * display = [res stringForColumn:language] ?: [res stringForColumn:@"en"];
        if( display ){
            displays[field] = display;
        }
    }
    
    NSMutableDictionary * fieldCache  = [NSMutableDictionary dictionaryWithCapacity:100];
    res = [db executeQuery:@"SELECT field,activityType,metric,statute From gc_fields_uom"];
    
    NSDictionary * columnToUnitSystem = @{
        @"statute" : @(GCUnitSystemImperial),
        @"metric"  : @(GCUnitSystemMetric)
    };
    
    while( [res next] ){
        NSString * fieldKey = [res stringForColumn:@"field"];
        NSString * type  = [res stringForColumn:@"activityType"];
        GCField * field = [GCField fieldForKey:fieldKey andActivityType:type];
        
        NSMutableDictionary * units = [NSMutableDictionary dictionary];
        
        for (NSString * column in columnToUnitSystem) {
            NSNumber * unitSystem = columnToUnitSystem[column];
            NSString * uom = [res stringForColumn:column];
            if( uom ){
                GCUnit * unit = [GCUnit unitForKey:uom];
                if( unit ){
                    units[ unitSystem ] = unit;
                }
            }
        }
        
        if( field ){
            NSString * display = displays[fieldKey] ?: [GCField displayNameImpliedByFieldKey:fieldKey];

            NSString * key = cacheFieldKey(fieldKey, type);
            GCFieldInfo * info = [GCFieldInfo fieldInfoFor:field
                                               displayName:display
                                                  andUnits:units];
            fieldCache[key] = info;
        }
    }
    
    NSMutableDictionary * activityTypeCache  = [NSMutableDictionary dictionaryWithCapacity:100];
    res = [db executeQuery:@"SELECT * FROM gc_activityTypes"];
    while ([res next]) {
        NSString * aType = [res stringForColumn:@"activityType"];
        NSString * display = [res stringForColumn:language] ?: [res stringForColumn:@"en"];
        if( display && aType ){
            GCFieldInfo * info = [GCFieldInfo fieldInfoForActivityType:aType displayName:display];
            NSString * key = cacheActivityTypeKey(aType);
            activityTypeCache[key] = info;
        }
    }

    [db close];
    self.predefinedFieldCache = [NSDictionary dictionaryWithDictionary:fieldCache];
    self.predefinedActivityTypeCache = [NSDictionary dictionaryWithDictionary:activityTypeCache];
    self.cache = [NSMutableDictionary dictionary];
}
#pragma mark - Query Cache


-(GCFieldInfo*)infoForField:(GCField*)field{
    GCFieldInfo * rv = self.cache[field];
    if( rv != nil){
        return rv;
    }
    
    NSString * key = cacheFieldKey(field.key, field.activityType);
    rv = self.predefinedFieldCache[key];
    if (rv == nil) {
        NSString * keyall = cacheFieldKey(field.key, GC_TYPE_ALL);
        rv = self.predefinedFieldCache[ keyall ];
        if( rv ){
            self.cache[field] = rv;
        }
    }
    if( rv == nil && [field isHealthField]){
        rv = [GCHealthMeasure fieldInfoFromField:field];
        if (rv) {
            self.cache[ field ] = rv;
        }
    }
// Only if iPhone/ConnectStats on mac, no calculated fields
#if TARGET_OS_IPHONE
    if( rv == nil && [field isCalculatedField]){
        rv = [GCFieldsCalculated fieldInfoForCalculatedField:field];
        if (rv) {
            self.cache[field] = rv;
        }
    }
#endif
    if( rv == nil){
        if( _missingFieldCache == nil){
            _missingFieldCache = RZReturnRetain([NSMutableDictionary dictionary]);
        }
        if( ! _missingFieldCache[field]){
            _missingFieldCache[field] = @1;
            RZLog(RZLogInfo,@"Predefined Field Cache Missing %@", field);
        }
    }
    return rv;
}

-(GCFieldInfo*)infoForActivityType:(NSString*)activityType{
    NSString * key = cacheActivityTypeKey(activityType);
    GCFieldInfo * rv = self.predefinedActivityTypeCache[key];
    return rv;
}


-(NSArray<NSString*>*)knownFieldsMatching:(NSString*)str{
    NSMutableDictionary<NSString*,GCFieldInfo*> * rv = [NSMutableDictionary dictionary];
    NSString * exact = nil;
    for (GCField * field in _cache) {
        GCFieldInfo * info = _cache[field];
        if ([info match:str]) {
            rv[info.field.key] = info;
            if ([str compare:info.displayName options:NSCaseInsensitiveSearch] == NSOrderedSame ){
                exact = info.displayName;
            }else if([str compare:info.field.key options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                exact = info.field.key;
            }
        }
    }
    for (NSString * key in _predefinedFieldCache) {
        GCFieldInfo * info = _predefinedFieldCache[key];
        if ([info match:str] && !rv[info.field.key]) {
            rv[info.field.key] = info;
            if ([str compare:info.displayName options:NSCaseInsensitiveSearch] == NSOrderedSame ){
                exact = info.displayName;
            }else if([str compare:info.field.key options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                exact = info.field.key;
            }
        }
    }

    return rv.count ? [rv.allKeys sortedArrayUsingComparator:^(id obj1,id obj2){
        int l1 = (int)[obj1 length];
        int l2 = (int)[obj2 length];
        int t  = (int)exact.length;

        int v1 = abs(l1-t);
        int v2 = abs(l2-t);

        NSComparisonResult lrv = v1 > v2 ? NSOrderedAscending : v1 < v2 ? NSOrderedDescending : NSOrderedSame;
        return lrv;
    }]: nil;
}

#pragma mark - Legacy

-(GCFieldInfo*)infoForField:(NSString*)field andActivityType:(NSString*)aType{
    return [self infoForField:[GCField fieldForKey:field andActivityType:aType]];
}

-(BOOL)knownField:(NSString*)field activityType:(NSString*)activityType{
    if (!activityType) {
        RZLog(RZLogWarning, @"nil activityType, field %@",field);
        return false;
    }
    NSString * key = cacheFieldKey(field, activityType);

    return _cache[ [GCField fieldForKey:field andActivityType:activityType] ] != nil || _predefinedFieldCache[ key ] != nil;
}



-(NSDictionary<GCField*,GCFieldInfo*>*)missingPredefinedField{
    NSMutableDictionary<GCField*,GCFieldInfo*> * rv = [NSMutableDictionary dictionary];
        
    return rv;
}


-(NSDictionary<GCField*,GCFieldInfo*>*)buildLegacyCache{
    if(!self.db){
        return nil;
    }

    NSMutableDictionary<GCField*,GCFieldInfo*> * newCache = [NSMutableDictionary dictionary];

    FMDatabase * db = self.db;
    FMResultSet * res = [db executeQuery:@"select * from gc_fields"];
    while ([res next]) {
        NSString * fieldKey = [res stringForColumn:@"field"];
        if (!fieldKey ){
            RZLog(RZLogWarning, @"Null field");
            continue;
        }

        NSString * aType = [res stringForColumn:@"activityType"];
        if( aType ){
            GCField * field = [GCField fieldForKey:fieldKey andActivityType:aType];
            GCUnit * unit = [GCUnit unitForKey:[res stringForColumn:@"uom"]];
            
            GCFieldInfo * info=[GCFieldInfo fieldInfoFor:field displayName:[res stringForColumn:@"fieldDisplayName"] andUnits:@{@(GCUnitSystemDefault):unit}];
            newCache[field] = info;
        }else{
            RZLog(RZLogError, @"nil activityType field=%@", fieldKey);
        }
    }
    return [NSDictionary dictionaryWithDictionary:newCache];
}


-(void)registerField:(GCField *)field displayName:(NSString *)aName andUnitName:(NSString *)uom{
    if(!self.predefinedFieldCache){
        [self buildPredefinedCacheForLanguage:nil];
    }

    if( self.cache[field] == nil && aName != nil && uom != nil) {
        // If we got a name that is different from the field... If same, not useful.
        if( ![[aName lowercaseString] isEqualToString:[field.key lowercaseString]] ){
            GCFieldInfo * newInfo = [GCFieldInfo fieldInfoFor:field displayName:aName andUnits:@{@(GCUnitSystemDefault):[GCUnit unitForKey:uom]}];
            self.cache[field] = newInfo;
        }
    }
}

-(void)registerField:(NSString*)field activityType:(NSString*)aType displayName:(NSString*)aName andUnitName:(NSString*)uom{
    [self registerField:[GCField fieldForKey:field andActivityType:aType] displayName:aName andUnitName:uom];
}

@end
