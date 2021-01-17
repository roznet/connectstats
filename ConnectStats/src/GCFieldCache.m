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

NS_INLINE NSString * cacheActivityTypeKey(NSString*activityType){
    return activityType ?:@"NIL";
}

@interface GCFieldCache ()
/**
 * Cache that was build dynamically during execution
 */
@property (nonatomic,retain) NSMutableDictionary<GCField*,GCFieldInfo*>*cache;
@property (nonatomic,retain) NSMutableDictionary<GCField*,GCFieldInfo*>*missing;
@property (nonatomic,retain) NSDictionary<GCField*,GCFieldInfo*>*predefinedFieldCache;
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
    [_missing release];

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

-(NSArray<GCField*>*)availableFields{
    NSMutableSet * rv = [NSMutableSet set];
    for (GCFieldInfo * key in self.predefinedFieldCache.allValues) {
        [rv addObject:key.field];
    }
    for(GCFieldInfo * key in self.cache.allValues){
        [rv addObject:key.field];
    }
    return rv.allObjects;
}

-(NSArray<NSString*>*)availableActivityTypes{
    NSMutableArray * rv = [NSMutableArray array];
    for (GCFieldInfo * info in self.predefinedActivityTypeCache) {
        [rv addObject:info.activityType];
    }
    return rv;
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
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
    [db open];

    NSMutableDictionary<NSString*,NSString*> * displays = [NSMutableDictionary dictionary];
    
    FMResultSet * res = [db executeQuery:@"SELECT * From gc_fields_display"];
    while( [res next]){
        NSString * field = [res stringForColumn:@"field"];
        NSString * display = [res stringForColumn:language] ?: [res stringForColumn:@"en"];
        if( display ){
            displays[field] = display;
        }
    }
    
    NSMutableDictionary<GCField*,GCFieldInfo*> * fieldCache  = [NSMutableDictionary dictionaryWithCapacity:100];
    res = [db executeQuery:@"SELECT field,activity_type,metric,statute From gc_fields_uom"];
    
    NSDictionary * columnToUnitSystem = @{
        @"statute" : @(gcUnitSystemImperial),
        @"metric"  : @(gcUnitSystemMetric)
    };
    
    while( [res next] ){
        NSString * fieldKey = [res stringForColumn:@"field"];
        NSString * type  = [res stringForColumn:@"activity_type"];
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

            GCFieldInfo * info = [GCFieldInfo fieldInfoFor:field
                                               displayName:display
                                                  andUnits:units];
            fieldCache[field] = info;
        }
    }
    
    NSMutableDictionary * activityTypeCache  = [NSMutableDictionary dictionaryWithCapacity:100];
    res = [db executeQuery:@"SELECT * FROM gc_activity_types"];
    while ([res next]) {
        NSString * aType = [res stringForColumn:@"activity_type"];
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
    self.missing = [NSMutableDictionary dictionary];
}
#pragma mark - Query Cache


-(GCFieldInfo*)infoForField:(GCField*)field{
    GCFieldInfo * rv = self.cache[field];
    if( rv != nil){
        return rv;
    }
    rv = self.cache[ field.correspondingFieldTypeAll ];
    if( rv != nil ){
        return rv;
    }
        
    rv = self.predefinedFieldCache[field];
    if (rv == nil) {
        rv = self.predefinedFieldCache[ field.correspondingFieldTypeAll ];
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
        if( self.missing[field] == nil){
            self.missing[field] = [GCFieldInfo fieldInfoFor:field displayName:field.key andUnits:@{@(gcUnitSystemMetric):[GCUnit dimensionless]}];
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
    for (GCField * field in _predefinedFieldCache) {
        GCFieldInfo * info = self.predefinedFieldCache[field];
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
    return [self infoForField:[GCField fieldForKey:field andActivityType:activityType]] != nil;
}

-(NSDictionary<GCField*,GCFieldInfo*>*)missingPredefinedField{
    return self.missing;
}

-(void)registerFields:(NSDictionary<GCField*,GCFieldInfo*>*)info{
    if(!self.predefinedFieldCache){
        [self buildPredefinedCacheForLanguage:nil];
    }

    NSMutableDictionary<GCField*,GCFieldInfo*> * newDict = [NSMutableDictionary dictionaryWithDictionary:self.predefinedFieldCache];
    for (GCField * field in info) {
        newDict[field] = info[field];
    }
    self.predefinedFieldCache = newDict;
}

-(void)registerMissingField:(GCField *)field displayName:(NSString *)aName andUnitName:(NSString *)uom{
    if( aName != nil && uom != nil){
        if(!self.predefinedFieldCache){
            [self buildPredefinedCacheForLanguage:nil];
        }
        
        BOOL existing = self.predefinedFieldCache[field] != nil || self.predefinedFieldCache[field.correspondingFieldTypeAll] != nil;
        
        if( !existing ) {
            NSString * displayName = aName;
            
            if( [aName isEqualToString:field.key] ){
                displayName = [GCField displayNameImpliedByFieldKey:field.key];
            }
            GCFieldInfo * newInfo = [GCFieldInfo fieldInfoFor:field displayName:displayName andUnits:@{@(gcUnitSystemDefault):[GCUnit unitForKey:uom]}];
            self.cache[field] = newInfo;
            self.missing[field] = newInfo;
        }
    }
}

-(void)registerField:(NSString*)field activityType:(NSString*)aType displayName:(NSString*)aName andUnitName:(NSString*)uom{
    [self registerMissingField:[GCField fieldForKey:field andActivityType:aType] displayName:aName andUnitName:uom];
}

@end
