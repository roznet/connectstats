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
// Only if iPhone/ConnectStats on mac, no calculated fields
#if TARGET_OS_IPHONE
#import "GCFieldsCalculated.h"
#endif

NS_INLINE NSString * cacheKey(NSString*field,NSString*activityType){
    return [field stringByAppendingString:activityType ?:@"NIL"] ?: @"NIL";
}

@interface GCFieldCache ()
@property (nonatomic,retain) NSDictionary<NSString*,GCFieldInfo*>*cache;
@property (nonatomic,retain) NSDictionary<NSString*,GCFieldInfo*>*predefinedCache;
@property (nonatomic,retain) FMDatabase * db;
@property (nonatomic,retain) dispatch_queue_t worker;
@end

@implementation GCFieldCache
#if !__has_feature(objc_arc)
-(void)dealloc{
    [_db release];
    [_cache release];
    [_predefinedCache release];
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
        rv.preferPredefined = false;
        [rv buildPredefinedCacheForLanguage:language];
        [rv buildCache];
    }
    return rv;
}


#pragma mark - Build Cache

+(void)ensureDbStructure:(FMDatabase*)db{
    if (![db tableExists:@"gc_fields"]) {
        [db executeUpdate:@"CREATE TABLE gc_fields (field TEXT, activityType TEXT, fieldDisplayName TEXT, uom TEXT)"];
    }
}

-(void)buildCache{
    if(!self.db){
        return;
    }

    NSMutableDictionary * newCache = [NSMutableDictionary dictionary];

    FMDatabase * db = self.db;
    FMResultSet * res = [db executeQuery:@"select * from gc_fields"];
    while ([res next]) {
        NSString * field = [res stringForColumn:@"field"];
        NSString * aType = [res stringForColumn:@"activityType"];

        GCFieldInfo * info= [GCFieldInfo fieldInfoFor:field
                                                 type:aType
                                          displayName:[res stringForColumn:@"fieldDisplayName"]
                                          andUnitName:[res stringForColumn:@"uom"]];
        if (!field ){
            RZLog(RZLogWarning, @"Null field");
            continue;
        }

        if (aType) {
            if ([field isEqualToString:@"SumIntensityFactor"]) {
                info.uom = @"if";
            }
            NSString * key = cacheKey(field, aType);
            NSString * allkey = cacheKey(field, GC_TYPE_ALL);

            BOOL storeInCache = true;
            // If it was stored with field == displayName and predefined has different name, use that
            if ([info.displayName isEqualToString:field]) {
                GCFieldInfo * pre = self.predefinedCache[key];
                if (pre && ![pre.displayName isEqualToString:field]) {
                    storeInCache =false;
                }
            }
            if (storeInCache) {
                newCache[ key ] = info;
            }
            storeInCache = true;
            GCFieldInfo * infoall = _cache[allkey];
            if (infoall) {
                if (![infoall.uom isEqualToString:info.uom]) {
                    infoall.uom = [[GCUnit unitForKey:infoall.uom] commonUnit:[GCUnit unitForKey:info.uom]].key;
                }
            }else{
                infoall= [GCFieldInfo fieldInfoFor:field
                                              type:GC_TYPE_ALL
                                       displayName:[res stringForColumn:@"fieldDisplayName"]
                                       andUnitName:[res stringForColumn:@"uom"]];

                if( [infoall.displayName isEqualToString:field]){
                    GCFieldInfo * preall = self.predefinedCache[allkey];
                    if (preall && ![preall.displayName isEqualToString:field]) {
                        storeInCache = false;
                    }
                }
                if (storeInCache) {
                    newCache[allkey] = infoall;
                }
            }
        }else{
            RZLog(RZLogError, @"nil activityType field=%@", field);
        }
    }
    self.cache = [NSDictionary dictionaryWithDictionary:newCache];
}

-(void)buildPredefinedCacheForLanguage:(nullable NSString*)languageInput{

    NSString * language = languageInput ?: [[NSLocale preferredLanguages][0] substringToIndex:2];
    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer bundleFilePath:@"fields.db"]];
    [db open];

    NSMutableDictionary * uoms  = [NSMutableDictionary dictionaryWithCapacity:100];
    NSString * uomtable = [GCUnit getGlobalSystem]==GCUnitSystemImperial ? @"gc_fields_uom_statute" : @"gc_fields_uom_metric";
    FMResultSet * res = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", uomtable]];
    while ([res next]) {
        NSString * field = [res stringForColumn:@"field"];
        NSString * type  = [res stringForColumn:@"activityType"];
        uoms[cacheKey(field, type)] = [res stringForColumn:@"uom"];
    }

    NSString * table = [NSString stringWithFormat:@"gc_fields_%@", language];
    if (![db tableExists:table]) {
        table = @"gc_fields_en";
    }
    res = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", table]];
    NSMutableDictionary * rv  = [NSMutableDictionary dictionaryWithCapacity:100];
    while ([res next]) {
        NSString * field = [res stringForColumn:@"field"];
        NSString * type  = [res stringForColumn:@"activityType"];
        NSString * key = cacheKey(field, type);
        GCFieldInfo * info = [GCFieldInfo fieldInfoFor:field
                                                  type:type
                                           displayName:[res stringForColumn:@"fieldDisplayName"]
                                           andUnitName:uoms[key]];
        rv[key] = info;
    }

    NSString * activityTypeTable = [NSString stringWithFormat:@"gc_activityType_%@", language];
    if (![db tableExists:activityTypeTable]) {
        activityTypeTable = @"gc_activityType_en";
    }
    res = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", activityTypeTable]];
    while ([res next]) {
        NSString * aType = [res stringForColumn:@"activityTypeDetail"];
        NSString * display = [res stringForColumn:@"display"];

        GCFieldInfo * info = [GCFieldInfo fieldInfoFor:aType
                                                  type:aType
                                           displayName:display
                                           andUnitName:@"dimensionless"];
        NSString * key = cacheKey(aType, aType);
        rv[key] = info;
    }

    [db close];
    self.predefinedCache = [NSDictionary dictionaryWithDictionary:rv];
}

-(void)logNullRegister:(NSString*)field activityType:(NSString*)aType displayName:(NSString*)aName  andUnitName:(NSString*)uom{
    static NSMutableDictionary * _logCache = nil;
    if( _logCache == nil){
        _logCache = [NSMutableDictionary dictionary];
        RZRetain(_logCache);
    }
    // To Fix: add to one of the fields/*.db and rerun fields.py
    BOOL show = true;
    if(field){
        NSString * key = [field stringByAppendingString:aType?:@"<NoType>"];
        if( _logCache[key]){
            show = false;
        }
        if( [aType isEqualToString:@"all"]){
            show = false;
        }else{
            _logCache[key] = @1;
        }
    }
    if( show ){
        // To Fix: add to one of the fields/*.db and rerun fields.py
        RZLog(RZLogWarning,@"Attempt to register invalid field %@ %@ %@ %@",field?:@"<NoField>",aType?:@"<NoType>",aName?:@"<NoName>",uom?:@"<NoUnit>");
    }
}


-(void)registerField:(NSString*)field activityType:(NSString*)aType displayName:(NSString*)aName  andUnitName:(NSString*)uom{
    if(!_cache){
        [self buildPredefinedCacheForLanguage:nil];
        [self buildCache];
    }
    if (!aType||!field) {
        // To Fix: add to one of the fields/*.db and rerun fields.py
        [self logNullRegister:field activityType:aType displayName:aName andUnitName:uom];
        
        return;
    }
    NSString * key = cacheKey(field, aType);
    if (!_cache[key]) {
        NSString * useName = aName;
        NSString * useUom  = uom;
        // If name == key and predefined has better name use that
        if ([aName isEqualToString:field]) {
            GCFieldInfo * pre = self.predefinedCache[key];
            if (pre) {
                useName = pre.displayName;
                //useUom  = pre.uom;
            }
        }

        NSMutableDictionary * newFields = [NSMutableDictionary dictionary];
        if(self.db){
            FMDatabase * db = self.db;
            if (!field||!aType||!useName||!useUom) {
                // To Fix: add to one of the fields/*.db and rerun fields.py
                [self logNullRegister:field activityType:aType displayName:aName andUnitName:uom];
                return;
            }
            if (![db executeUpdate:@"INSERT INTO gc_fields (field,activityType,fieldDisplayName,uom) VALUES (?,?,?,?)",field,aType,useName,useUom]) {
                RZLog(RZLogError,@"Db error in registerField: %@",[db lastErrorMessage]);
            };
        }
        GCFieldInfo * info =[GCFieldInfo fieldInfoFor:field type:aType displayName:useName andUnitName:useUom];
        newFields[key] = info;

        NSString * allkey = cacheKey(field, GC_TYPE_ALL);
        GCFieldInfo * allpre = _cache[allkey];
        if (allpre) {
            if (![allpre.uom isEqualToString:info.uom]) {
                allpre.uom = [[GCUnit unitForKey:allpre.uom] commonUnit:[GCUnit unitForKey:info.uom]].key;
            }
        }else{
            newFields[allkey] = info;
        }
        self.cache = [self.cache dictionaryByAddingEntriesFromDictionary:newFields];
    }
}

-(void)saveToDb:(FMDatabase*)db{
    if(self.db){
        for (NSString * key in self.cache) {
            GCFieldInfo * info = _cache[key];
            if (![db executeUpdate:@"INSERT INTO gc_fields (field,activityType,fieldDisplayName,uom) VALUES (?,?,?,?)",info.field,info.activityType,info.displayName,info.uom]) {
                RZLog(RZLogError,@"Db error in registerField: %@",[db lastErrorMessage]);
            };
        }
    }
}

#pragma mark - Query Cache

-(NSArray<NSString*>*)knownFieldsMatching:(NSString*)str{
    NSMutableDictionary * rv = [NSMutableDictionary dictionaryWithCapacity:1];
    NSString * exact = nil;
    for (NSString * key in _cache) {
        GCFieldInfo * info = _cache[key];
        if ([info match:str]) {
            rv[info.field] = info;
            if ([str compare:info.displayName options:NSCaseInsensitiveSearch] == NSOrderedSame ){
                exact = info.displayName;
            }else if([str compare:info.field options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                exact = info.field;
            }
        }
    }
    for (NSString * key in _predefinedCache) {
        GCFieldInfo * info = _predefinedCache[key];
        if ([info match:str] && !rv[info.field]) {
            rv[info.field] = info;
            if ([str compare:info.displayName options:NSCaseInsensitiveSearch] == NSOrderedSame ){
                exact = info.displayName;
            }else if([str compare:info.field options:NSCaseInsensitiveSearch]==NSOrderedSame) {
                exact = info.field;
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

-(BOOL)knownField:(NSString*)field activityType:(NSString*)activityType{
    if (!activityType) {
        RZLog(RZLogWarning, @"nil activityType, field %@",field);
        return false;
    }
    NSString * key = cacheKey(field, activityType);

    return _cache[ key ] != nil || _predefinedCache[ key ] != nil;
}


-(NSArray*)missingPredefinedField{
    NSMutableArray * rv = [NSMutableArray array];
    for (NSString * key in self.cache) {
        if (!self.predefinedCache[key]) {
            GCFieldInfo * info = self.cache[key];
            [rv addObject:@[ info.field ?: @"missing", info.activityType ?: @"missing", info.uom ?: @"missing", info.displayName ?: @"missing"]];
        }
    }
    return [rv sortedArrayUsingComparator:^(NSArray*a1,NSArray*a2){
        return [a1[1] isEqualToString:a2[1]] ? [a1[0] compare:a2[0]] : [a1[1] compare:a2[1]];
    }];
}


-(GCFieldInfo*)infoForField:(GCField*)field{
    GCFieldInfo * rv = nil;
    NSString * key = cacheKey(field.key, field.activityType);
    if (self.preferPredefined) {
        rv = self.predefinedCache[key];
        if (rv == nil) {
            rv = self.cache[ key ];
            if (rv == nil) {
                NSString * keyall = cacheKey(field.key, GC_TYPE_ALL);
                rv = self.predefinedCache[ keyall];
                if (rv) {
                    rv = self.cache[keyall];
                }
            }
        }
    }else{
        rv = self.cache[ key ];
        if (rv == nil) {
            rv = self.predefinedCache[key];
            if( rv == nil){
                NSString * keyall = cacheKey(field.key, GC_TYPE_ALL);
                rv = self.cache[keyall];
                if (rv == nil) {
                    rv = self.predefinedCache[keyall];
                }
            }
        }
    }
    if( rv == nil && [field isHealthField]){
        rv = [GCHealthMeasure fieldInfoFromField:field];
        if (rv) {
            self.cache = [self.cache dictionaryByAddingEntriesFromDictionary:@{key:rv}];
        }
    }
// Only if iPhone/ConnectStats on mac, no calculated fields
#if TARGET_OS_IPHONE
    if( rv == nil && [field isCalculatedField]){
        rv = [GCFieldsCalculated fieldInfoForCalculatedField:field];
        if (rv) {
            self.cache = [self.cache dictionaryByAddingEntriesFromDictionary:@{key:rv}];
        }
    }
#endif

    return rv;
}
-(GCFieldInfo*)infoForField:(NSString*)field andActivityType:(NSString*)aType{
    return [self infoForField:[GCField fieldForKey:field andActivityType:aType]];
}
-(GCFieldInfo*)infoForActivityType:(NSString*)activityType{
    NSString * key = cacheKey(activityType, activityType);
    GCFieldInfo * rv = nil;
    if (_preferPredefined) {
        rv = self.predefinedCache[key];
        if (rv==nil) {
            rv = self.cache[key];
        }
    }else{
        rv = self.cache[key];
        if (rv==nil) {
            rv = self.predefinedCache[key];
        }
    }
    return rv;
}

@end
