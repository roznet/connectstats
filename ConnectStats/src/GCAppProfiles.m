//  MIT Licence
//
//  Created on 15/11/2012.
//
//  Copyright (c) 2012 Brice Rosenzweig.
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

#import "GCAppGlobal.h"
#import "GCAppProfiles.h"
#import "Flurry.h"
#import "GCService.h"
#import "GCAppProfiles+Swift.h"


#define kSOURCE_IDENTIFER @"identifer"
#define kSOURCE_NAME      @"name"

NSInteger kServiceNoAnchor = 0;

@interface GCAppProfiles ()
@property (nonatomic,retain) NSArray<NSMutableDictionary*> * profiles;
@property (nonatomic,assign) NSUInteger currentProfile;
@end

@implementation GCAppProfiles

-(void)dealloc{
    [_profiles release];

    [super dealloc];
}

+(GCAppProfiles*)singleProfileWithValues:(NSDictionary*)dict{
    GCAppProfiles * rv = [[[GCAppProfiles alloc] init] autorelease];
    if (rv) {
        NSMutableDictionary * defs = [NSMutableDictionary dictionaryWithDictionary:[rv defaultProfile]];
        [defs addEntriesFromDictionary:dict];
        rv.profiles = @[ defs ];
        rv.currentProfile = 0;
    }
    return rv;

}
+(GCAppProfiles*)profilesFromSettings:(NSMutableDictionary*)dict{
    GCAppProfiles * rv = [[[GCAppProfiles alloc] init] autorelease];
    if (rv) {
        [rv loadFromSettings:dict];
    }
    return rv;
}

-(NSDictionary*)defaultProfile{
    return @{PROFILE_LOGIN_NAME:@"",
             PROFILE_NAME:@"Default",
             PROFILE_DBPATH:@"activities.db",
    };
}

-(void)loadFromSettings:(NSMutableDictionary*)dict{
    self.profiles = dict[CONFIG_PROFILES];
    self.currentProfile = [dict[CONFIG_CURRENT_PROFILE] intValue];
    
    if (!self.profiles) {
        // Default profile
        
        NSMutableDictionary * defaultDict = [NSMutableDictionary dictionaryWithDictionary:[self defaultProfile]];
        
        self.profiles = [NSMutableArray arrayWithArray:@[ defaultDict ] ];
        self.currentProfile = 0;
    }
    [self updateToKeychain];

}

-(void)saveToSettings:(NSMutableDictionary*)dict{
    if (dict[OBSOLETE_CONFIG_LOGIN_NAME]) {
        [dict removeObjectForKey:OBSOLETE_CONFIG_LOGIN_NAME];
    }
    if (dict[OBSOLETE_CONFIG_LOGIN_PWD]) {
        [dict removeObjectForKey:OBSOLETE_CONFIG_LOGIN_PWD];
    }

    dict[CONFIG_PROFILES] = self.profiles;
    dict[CONFIG_CURRENT_PROFILE] = @(self.currentProfile);
}


-(NSString*)mangledStringForKey:(NSString*)key atIdx:(NSUInteger)idx{
    id obj = _profiles[idx][key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }else{
        return [NSString stringFromMangedData:obj withKey:MANGLE_KEY];
    }
}
-(NSString*)mangledStringForKey:(NSString*)key{
    return [self mangledStringForKey:key atIdx:_currentProfile];
}

-(void)setMangledString:(NSString*)val forKey:(NSString*)aKey{
    if (val) {
        _profiles[_currentProfile][aKey] = [val mangledDataWithKey:MANGLE_KEY];
    }else{
        RZLog(RZLogError, @"nil val for key %@", aKey);
    }
}

-(NSString*)stringForKey:(NSString*)key atIdx:(NSUInteger)idx{
    id obj = _profiles[idx][key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }else{
        return @"";
    }
}

-(NSString*)stringForKey:(NSString*)key{
    return _profiles[_currentProfile][key];
}
-(void)setString:(NSString*)val forKey:(NSString *)aKey{
    if (val) {
        _profiles[_currentProfile][aKey] = val;
    }else{
        RZLog(RZLogError, @"nil val for key %@", aKey);
    }
}
-(NSString*)currentDatabasePath{
    return [self stringForKey:PROFILE_DBPATH];
}
-(NSString*)currentTennisDatabasePath{
    return [@"tennis_" stringByAppendingString:[self stringForKey:PROFILE_DBPATH]];
}
-(NSString*)currentDerivedDatabasePath{
    return [NSString stringWithFormat:@"derived_%@.db", [self stringForKey:PROFILE_NAME]];
}
-(NSString*)currentDerivedFilePrefix{
    return [NSString stringWithFormat:@"derived_%@", [self stringForKey:PROFILE_NAME]];
}
-(NSString*)currentProfileName{
    return [self stringForKey:PROFILE_NAME];
}
-(NSString*)currentQueryAnchorFilePathForClass:(Class)cls{
    return [NSString stringWithFormat:@"hkqueryanchor_%@_%@.data", [self stringForKey:PROFILE_NAME], NSStringFromClass(cls)];
}
#pragma mark - Source
-(gcServiceSourceValidator)currentSourceValidator{
    NSString * source = [self configGetString:PROFILE_CURRENT_SOURCE defaultValue:@""];
    return Block_copy(^(NSString*identifer){
        return [identifer isEqualToString:source];
    });
}


-(BOOL)registerSource:(NSString*)identifer withName:(NSString*)name{
    NSArray * current = [self configGetArray:PROFILE_SOURCES defaultValue:@[]];
    BOOL foundIdentifier = false;
    BOOL foundName = false;
    for (NSDictionary * one in current) {
        if ([one[kSOURCE_IDENTIFER] isEqualToString:identifer]) {
            foundIdentifier = true;
        }
        if ([one[kSOURCE_NAME] isEqualToString:name]) {
            foundName = true;
        }
    }
    if (!foundIdentifier) {
        if (foundName) {
            // Case of identifier change for same name (new phone hardware for ex)
            foundIdentifier = true;
            NSMutableArray * newSources = [NSMutableArray array];
            RZLog(RZLogInfo, @"%@ changed identifier", name);
            NSString * currentSource = [self configGetString:PROFILE_CURRENT_SOURCE defaultValue:@""];

            for (NSDictionary * dict in current) {
                if ([dict[kSOURCE_NAME] isEqualToString:name]) {
                    if ([currentSource isEqualToString:dict[kSOURCE_IDENTIFER]]) {
                        RZLog( RZLogInfo, @"%@ was current source, updating", name);
                        [self configSet:PROFILE_CURRENT_SOURCE stringVal:identifer];
                    }

                    [newSources addObject:@{kSOURCE_IDENTIFER:identifer,kSOURCE_NAME:name}];
                }else{
                    [newSources addObject:dict];
                }
            }
            [self configSet:PROFILE_SOURCES arrayVal:[NSArray arrayWithArray:newSources]];
        }else{
            [self configSet:PROFILE_SOURCES arrayVal:[current arrayByAddingObject:@{kSOURCE_IDENTIFER:identifer,kSOURCE_NAME:name}]];
        }
    }
    return !foundIdentifier;
}
-(BOOL)sourceIsSet{
    return ![[self configGetString:PROFILE_CURRENT_SOURCE defaultValue:@""] isEqualToString:@""];
}
-(NSString*)currentSource{
    return [self configGetString:PROFILE_CURRENT_SOURCE defaultValue:@""];
}

-(void)setCurrentSource:(NSString*)identifier{
    [self configSet:PROFILE_CURRENT_SOURCE stringVal:identifier];
}

-(NSArray*)availableSources{
    NSArray * sources = [self configGetArray:PROFILE_SOURCES defaultValue:@[]];
    return [sources arrayByMappingBlock:^(NSDictionary*dict){
        return dict[kSOURCE_IDENTIFER];
    }];
}

-(NSString*)sourceName:(NSString*)idendifier{
    NSArray * sources = [self configGetArray:PROFILE_SOURCES defaultValue:@[]];
    for (NSDictionary * dict in sources) {
        if ([dict[kSOURCE_IDENTIFER] isEqualToString:idendifier]) {
            return dict[kSOURCE_NAME];
        }
    }
    return nil;
}

#pragma mark - push notification

-(BOOL)pushNotificationEnabled{
    return self.pushNotificationType != gcNotificationPushTypeNone && [self serviceEnabled:gcServiceConnectStats];
}
-(gcNotificationPushType)pushNotificationType{
    return [self configGetInt:CONFIG_NOTIFICATION_PUSH_TYPE defaultValue:gcNotificationPushTypeNone];
}

-(void)setPushNotificationType:(gcNotificationPushType)pushNotificationType{
    [self configSet:CONFIG_NOTIFICATION_PUSH_TYPE intVal:pushNotificationType];
}

#pragma mark - Index Access;

-(NSString*)profileNameForIdx:(NSUInteger)idx{
    return [self stringForKey:PROFILE_NAME atIdx:idx];

}
-(NSString*)datbasePathForIdx:(NSUInteger)idx{
    return [self stringForKey:PROFILE_DBPATH atIdx:idx];

}
-(NSUInteger)activitiesCountForIdx:(NSUInteger)idx{

    FMDatabase * db = [FMDatabase databaseWithPath:[RZFileOrganizer writeableFilePath:[self datbasePathForIdx:idx]]];
    [db open];
    NSUInteger rv = [db intForQuery:@"SELECT COUNT(*) FROM gc_activities"];
    [db close];
    return rv;
}
#pragma mark -
-(NSUInteger)countOfProfiles{
    return _profiles.count;
}

/*
-(void)setLoginName:(NSString*)name{
    [self setString:name forKey:PROFILE_LOGIN_NAME];
}
-(void)setPassword:(NSString*)pwd{
    [self setMangledString:pwd forKey:PROFILE_LOGIN_PWD];
}
 -(NSString*)currentLoginName{
 return [self stringForKey:PROFILE_LOGIN_NAME];
 }
 -(NSString*)currentPassword{
 return [self mangledStringForKey:PROFILE_LOGIN_PWD];
 }

 */
-(BOOL)setProfileName:(NSString*)name{
    BOOL exists=false;
    for (NSUInteger i = 0; i<_profiles.count; i++) {
        if (i!=_currentProfile && [name isEqualToString:_profiles[i][PROFILE_NAME]]) {
            exists = true;
        }
    }
    if (!exists) {
        [self setString:name forKey:PROFILE_NAME];
        [self notify];
    }
    return !exists;
}

-(NSUInteger)profileIndexForName:(NSString*)aName{
    NSUInteger i =0;
    for (i =0; i<_profiles.count; i++) {
        if ([_profiles[i][PROFILE_NAME] isEqualToString:aName]) {
            break;
        }
    }
    return i;
}
#pragma mark -
-(NSArray*)profileNames{
    return [_profiles valueForKey:PROFILE_NAME];
}

-(void)publishEvent{
    NSDictionary * params = @{@"Count": @(_profiles.count)};
    [Flurry logEvent:EVENT_NEW_PROFILE withParameters:params];
}

-(void)addOrSelectProfile:(NSString*)pName{
    NSUInteger existing = [self profileIndexForName:pName];
    if (existing < _profiles.count) {
        _currentProfile = existing;
        [GCAppGlobal publishEvent:EVENT_SWITCH_PROFILE];
    }else{
        self.profiles = [_profiles arrayByAddingObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"",PROFILE_LOGIN_NAME,
                                       [NSData data],PROFILE_LOGIN_PWD,
                                       pName,PROFILE_NAME,
                                       [NSString stringWithFormat:@"activities_%@.db",pName],PROFILE_DBPATH,
                                       nil]];
        _currentProfile = _profiles.count-1;
#ifdef GC_USE_FLURRY
        [self publishEvent];
#endif

    }
    [self notify];
}

-(void)deleteProfile:(NSString*)pName{
    NSUInteger idx= [self profileIndexForName:pName];
    if (idx < _profiles.count) {
        NSDictionary * profile = self.profiles[idx];
        NSString * dbname = profile[PROFILE_DBPATH];
        NSMutableArray * newprofiles = [NSMutableArray arrayWithArray:_profiles];
        [newprofiles removeObjectAtIndex:idx];
        self.profiles = [NSArray arrayWithArray:newprofiles];
        _currentProfile = 0;
        if (_profiles.count==0) {
            [self addOrSelectProfile:@"Default"];
        }
        [RZFileOrganizer removeEditableFile:dbname];
        [self notify];
    }

}

#pragma mark - config

-(NSArray*)configGetArray:(NSString*)key defaultValue:(NSArray*)aDefault{
    NSArray * rv = self.profiles[_currentProfile][key];
    if (!rv) {
        rv = aDefault;
        [self configSet:key arrayVal:aDefault];
    }
    return rv;
}
-(void)configSet:(NSString*)key arrayVal:(NSArray*)aValue{
    self.profiles[_currentProfile][key] = aValue;
}
-(NSString*)configGetString:(NSString*)key defaultValue:(NSString*)aDefault{
    NSString * rv = self.profiles[_currentProfile][key];
    if (!rv) {
        rv = aDefault;
        [self configSet:key stringVal:aDefault];
    }
    return rv;

}
-(void)configSet:(NSString*)key stringVal:(NSString*)aValue{
    self.profiles[_currentProfile][key] = aValue;
}
-(BOOL)configGetBool:(NSString*)key defaultValue:(BOOL)aDefault{
	BOOL rv = aDefault;
	NSNumber * val = self.profiles[_currentProfile][key];
	if( val ){
		rv = val.boolValue;
	}else{//make sure the default is persisted to avoid surprises and inconsistencies
		[self configSet:key intVal:aDefault];
	}
	return( rv );
}
-(BOOL)configToggleBool:(NSString*)key{
	BOOL rv = FALSE;
	if( [self configGetBool:key defaultValue:FALSE] ){
		[self configSet:key boolVal:FALSE];
		rv = FALSE;
	}else{
		[self configSet:key boolVal:TRUE];
		rv = TRUE;
	}
	return( rv );
}

-(void)configSet:(NSString*)key boolVal:(BOOL)aValue{
	self.profiles[_currentProfile][key] = @(aValue);
}
-(NSInteger)configGetInt:(NSString*)key defaultValue:(NSInteger)aDefault{
	NSInteger rv = aDefault;
	NSNumber * val = self.profiles[_currentProfile][key];
	if( val ){
		rv = val.integerValue;
	}else{//make sure the default is persisted to avoid surprises and inconsistencies
		[self configSet:key intVal:aDefault];
	}
	return( rv );

}
-(void)configSet:(NSString*)key intVal:(NSInteger)aValue{
	self.profiles[_currentProfile][key] = @(aValue);
}

-(id)configHasKey:(NSString*)key{
    return self.profiles[_currentProfile][key];
}

#pragma mark - Login Name and passwords

-(NSString*)currentLoginNameForService:(gcService)service{
    return [self stringForKey:[self key:PROFILE_SERVICE_LOGIN forService:service]];
}

-(void)setLoginName:(NSString*)name forService:(gcService)service{
    [self setString:name forKey:[self key:PROFILE_SERVICE_LOGIN forService:service]];
}



-(void)updateToKeychain{
    for (NSMutableDictionary * one in self.profiles) {
        // Currently only garmin, but in case later more use username/pwd,
        gcService service = gcServiceGarmin;

        NSNumber * garminEnabled = one[CONFIG_GARMIN_ENABLE];
        if( garminEnabled && garminEnabled.boolValue){
            NSString * lastSaveKey = [self key:PROFILE_LAST_KEYCHAIN_SAVE forService:service];
            NSString * passwordKey = [self key:PROFILE_SERVICE_PWD forService:service];
            NSString * usernameKey = [self key:PROFILE_SERVICE_LOGIN forService:service];

            NSDate * lastSave = one[lastSaveKey];

            if( ! lastSave ){
                NSString * username = one[ usernameKey];

                NSString * pwd = [NSString stringFromMangedData:one[passwordKey] withKey:MANGLE_KEY];

                if( username && pwd ){
                    NSString * serviceName = [[GCService service:service] displayName];

                    BOOL success = [self savePassword:pwd forService:service];

                    if( success){
                        RZLog(RZLogInfo, @"Moved password for %@/%@ to keychain", serviceName, username);
                        one[ lastSaveKey ] = [NSDate date];
                        if( one[passwordKey]){
                            [one removeObjectForKey:passwordKey];
                        }
                    }else{
                        RZLog(RZLogWarning, @"Failed to move password for %@/%@ to keychain", serviceName, username);
                    }
                }
            }
        }
    }
}

-(NSString*)currentPasswordForService:(gcService)service{
    NSString * rv = @"";
    NSString * lastSaveKey = [self key:PROFILE_LAST_KEYCHAIN_SAVE forService:service];
    NSDate * lastSave = self.profiles[_currentProfile][lastSaveKey];
    if( lastSave){
        rv = [self retrievePasswordForService:service] ?: @"";
    }else{
        NSString * passwordKey = [self key:PROFILE_SERVICE_PWD forService:service];
        rv = [self mangledStringForKey:passwordKey];
    }

    return rv;
}

-(void)setPassword:(NSString*)pwd forService:(gcService)service{

    if( pwd ){
        if( [self savePassword:pwd forService:service]){
            NSString * lastSaveKey = [self key:PROFILE_LAST_KEYCHAIN_SAVE forService:service];
            self.profiles[_currentProfile][lastSaveKey] = [NSDate date];
        }else{
            RZLog(RZLogError, @"Failed to save password to keychain");
        }
    }else{
        [self clearPasswordForService:service];
    }
}

-(NSString*)key:(NSString*)key forService:(gcService)service{
    // special legacy case
    if (service == gcServiceGarmin) {
        if ([key isEqualToString:PROFILE_SERVICE_LOGIN]) {
            return PROFILE_LOGIN_NAME;
        }else if([key isEqualToString:PROFILE_SERVICE_PWD]){
            return PROFILE_LOGIN_PWD;
        }
    }
    NSString * sstr = @"unknown";
    switch (service) {
        case gcServiceStrava:
            sstr = PROFILE_SERVICE_STRAVA;
            break;
        case gcServiceGarmin:
            sstr = PROFILE_SERVICE_GARMIN;
            break;
        case gcServiceConnectStats:
            sstr = PROFILE_SERVICE_CONNECTSTATS;
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"%@%@",key,sstr];
}

#pragma mark - Services Information

-(BOOL)serviceSuccess:(gcService)service{
    return [self configGetBool:[self key:PROFILE_SERVICE_SETUP forService:service] defaultValue:NO];
}

-(void)serviceSuccess:(gcService)service set:(BOOL)set{
    [self configSet:[self key:PROFILE_SERVICE_SETUP forService:service] boolVal:set];
}

-(BOOL)serviceCompletedFull:(gcService)service{
    return [self configGetBool:[self key:PROFILE_SERVICE_FULL_DONE forService:service] defaultValue:NO];

}
-(void)serviceCompletedFull:(gcService)service set:(BOOL)set{
    if( set == false ){
        RZLog(RZLogInfo, @"%@ reset completedFull",[GCService service:service]);
    }else{
        RZLog(RZLogInfo, @"%@ mark completedFull",[GCService service:service]);
    }
    [self configSet:[self key:PROFILE_SERVICE_LAST_ANCHOR forService:service] intVal:kServiceNoAnchor];
    [self configSet:[self key:PROFILE_SERVICE_FULL_DONE forService:service] boolVal:set];
}
-(NSInteger)serviceAnchor:(gcService)service{
    return [self configGetInt:[self key:PROFILE_SERVICE_LAST_ANCHOR forService:service] defaultValue:kServiceNoAnchor];
}
-(void)serviceAnchor:(gcService)service set:(NSInteger)anchor{
    return [self configSet:[self key:PROFILE_SERVICE_LAST_ANCHOR forService:service] intVal:anchor];
}


-(BOOL)serviceEnabled:(gcService)service{
    BOOL rv = false;
    switch (service) {
        case gcServiceGarmin:
            rv = [self configGetBool:CONFIG_GARMIN_ENABLE defaultValue:NO];
            break;
        case gcServiceStrava:
            rv = [self configGetBool:CONFIG_STRAVA_ENABLE defaultValue:NO];
            break;
        case gcServiceHealthKit:
            rv = [self configGetBool:CONFIG_HEALTHKIT_ENABLE defaultValue:[GCAppGlobal healthStatsVersion]];
            break;
        case gcServiceConnectStats:
            rv = [self configGetBool:CONFIG_CONNECTSTATS_ENABLE defaultValue:NO];
            break;
        case gcServiceEnd:
            rv = false;
            break;
    }
    return rv;
}
-(void)serviceEnabled:(gcService)service set:(BOOL)set{
    switch (service) {
        case gcServiceGarmin:
            [self configSet:CONFIG_GARMIN_ENABLE boolVal:set];
            break;
        case gcServiceStrava:
            [self configSet:CONFIG_STRAVA_ENABLE boolVal:set];
            break;
        case gcServiceHealthKit:
            [self configSet:CONFIG_HEALTHKIT_ENABLE boolVal:set];
            break;
        case gcServiceConnectStats:
            [self configSet:CONFIG_CONNECTSTATS_ENABLE boolVal:set];
            break;
        case gcServiceEnd:
            break;
    }

}

-(BOOL)serviceIncomplete:(gcService)service{
    BOOL rv = false;
    if ([self serviceEnabled:service]) {
        switch (service) {
            case gcServiceGarmin:
            {
                if( ![self serviceSuccess:service] ){
                    gcGarminLoginMethod method = (gcGarminLoginMethod)[self configGetInt:CONFIG_GARMIN_LOGIN_METHOD defaultValue:GARMINLOGIN_DEFAULT];
                    
                    if (method == gcGarminLoginMethodDirect && ([self currentLoginNameForService:service].length==0 || [self currentPasswordForService:service].length==0)) {
                        rv = true;
                    }
                    break;
                }
            }
            default:
                break;
        }
    }
    return rv;
}
-(BOOL)atLeastOneService{
    return
        [self serviceEnabled:gcServiceGarmin] ||
        [self serviceEnabled:gcServiceConnectStats] ||
        [self serviceEnabled:gcServiceStrava] ||
        [self serviceEnabled:gcServiceHealthKit];
}
-(BOOL)profileRequireSetup{
    return [self serviceIncomplete:gcServiceGarmin] || [self atLeastOneService]==false;
}

-(NSUInteger)numberOfServices{
    NSUInteger rv = 0;
    rv += [self serviceEnabled:gcServiceGarmin];
    rv += [self serviceEnabled:gcServiceStrava];
    rv += [self serviceEnabled:gcServiceHealthKit];
    rv += [self serviceEnabled:gcServiceConnectStats];
    return rv;
}
@end
