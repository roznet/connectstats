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

#import <Foundation/Foundation.h>
#import "GCAppConstants.h"


@interface GCAppProfiles : RZParentObject

@property (nonatomic,readonly) NSUInteger currentProfile;

+(GCAppProfiles*)singleProfileWithValues:(NSDictionary*)dict;
+(GCAppProfiles*)profilesFromSettings:(NSMutableDictionary*)dict;
-(void)saveToSettings:(NSMutableDictionary*)dict;

-(NSString*)currentDatabasePath;
-(NSString*)currentTennisDatabasePath;
-(NSString*)currentDerivedDatabasePath;
-(NSString*)currentDerivedFilePrefix;
-(NSString*)currentQueryAnchorFilePathForClass:(Class)cls;

-(gcServiceSourceValidator)currentSourceValidator;
-(NSString*)currentSource;
-(BOOL)sourceIsSet;
-(void)setCurrentSource:(NSString*)identifier;
-(BOOL)registerSource:(NSString*)identifer withName:(NSString*)name;
-(NSArray*)availableSources;
-(NSString*)sourceName:(NSString*)idendifier;

-(NSString*)currentProfileName;
-(BOOL)setProfileName:(NSString*)name;

-(NSString*)profileNameForIdx:(NSUInteger)idx;
-(NSString*)datbasePathForIdx:(NSUInteger)idx;
-(NSUInteger)activitiesCountForIdx:(NSUInteger)idx;
-(NSUInteger)countOfProfiles;

-(void)setLoginName:(NSString*)name forService:(gcService)service;
-(NSString*)currentLoginNameForService:(gcService)service;
-(NSString*)currentPasswordForService:(gcService)service;
-(void)setPassword:(NSString*)pwd forService:(gcService)service;

-(BOOL)serviceSuccess:(gcService)service;
-(void)serviceSuccess:(gcService)service set:(BOOL)set;
-(BOOL)serviceEnabled:(gcService)service;
-(void)serviceEnabled:(gcService)service set:(BOOL)set;
-(BOOL)serviceIncomplete:(gcService)service;
-(BOOL)serviceCompletedFull:(gcService)service;
-(void)serviceCompletedFull:(gcService)service set:(BOOL)set;
-(NSInteger)serviceAnchor:(gcService)service;
-(void)serviceAnchor:(gcService)service set:(NSInteger)anchor;
-(BOOL)profileRequireSetup;
-(BOOL)atLeastOneService;
-(NSUInteger)numberOfServices;

-(NSArray*)profileNames;
-(void)addOrSelectProfile:(NSString*)pName;
-(void)deleteProfile:(NSString*)pName;

-(BOOL)configGetBool:(NSString*)key defaultValue:(BOOL)aDefault;
-(BOOL)configToggleBool:(NSString*)key;
-(void)configSet:(NSString*)key boolVal:(BOOL)value;
-(NSInteger)configGetInt:(NSString*)key defaultValue:(NSInteger)aDefault;
-(void)configSet:(NSString*)key intVal:(NSInteger)aValue;
-(NSArray*)configGetArray:(NSString*)key defaultValue:(NSArray*)aDefault;
-(void)configSet:(NSString*)key arrayVal:(NSArray*)aValue;
-(NSString*)configGetString:(NSString*)key defaultValue:(NSString*)aDefault;
-(void)configSet:(NSString*)key stringVal:(NSString*)aValue;

-(id)configHasKey:(NSString*)key;

@end
