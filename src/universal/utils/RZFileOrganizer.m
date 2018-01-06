//  MIT Licence
//
//  Created on 09/03/2009.
//
//  Copyright (c) None Brice Rosenzweig.
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

#import "RZFileOrganizer.h"
#import "RZMacros.h"
#import "RZLog.h"

NS_INLINE NSArray * filesMatchingLogic(NSString * documentsDirectory, FileOrganizerMatch match ){
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];

    NSArray * files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];

    if (match == nil || files == nil) {
        return files;
    }
    else{
        NSMutableArray * results =  [NSMutableArray arrayWithCapacity:files.count];
        for (NSString * file in files) {
            if ( match(file) ){
                [results addObject:file];
            }
        }
        return results;
    }
}

@implementation RZFileOrganizer

+(nullable NSString*)writeableFilePath:(nullable NSString*)aName forGroup:(NSString*)group{
    NSURL * url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:group];
    return [url path];
}

+(NSString*)writeableFilePath:(nullable NSString*)aName{
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];

    return( aName ? [documentsDirectory stringByAppendingPathComponent:aName] : documentsDirectory);
}

+(BOOL)ensureWriteableFilePath:(NSString*)aName{
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:aName];
    NSError * error = nil;
    BOOL rv = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (!rv) {
        RZLog(RZLogError, @"Error Creating Directory: %@", error);
    }
    return rv;
}


+(NSArray*)writeableFilesMatching:(nullable FileOrganizerMatch)match{
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];

    return filesMatchingLogic(documentsDirectory, match);
}

+(NSArray*)bundleFilesMatching:(nullable FileOrganizerMatch)match forClass:(Class)cls{
    NSString	*	documentsDirectory	= [NSBundle bundleForClass:cls].resourcePath;

    return filesMatchingLogic(documentsDirectory, match);
}


+(nullable NSString*)writeableFilePathIfExists:(NSString*)aName{
    NSArray		*	paths				= NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString	*	documentsDirectory	= paths[0];
    NSString    *   rv = [documentsDirectory stringByAppendingPathComponent:aName];
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:rv]){
        rv = nil;
    }
	return( rv );
}

+(NSString*)bundleFilePath:(nullable NSString*)aName forClass:(Class)cls{
    if (aName) {
        return( [[NSBundle bundleForClass:cls].resourcePath stringByAppendingPathComponent:aName] );
    }else{
        return [NSBundle bundleForClass:cls].resourcePath;
    }
}


+(NSString*)bundleFilePath:(nullable NSString*)aName{
    NSString * bundlePath = [NSBundle mainBundle].resourcePath ;
    return( aName ? [bundlePath stringByAppendingPathComponent:aName] : bundlePath);
}

+(nullable NSString*)bundleFilePathIfExists:(NSString*)aName{
    NSString * rv  = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:aName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:rv]) {
        rv = nil;
    }
    return rv;
}


+(void)forceRebuildEditable:(NSString*)aName{
    BOOL				success;
    NSError			*	error;
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSString		*	writableFilePath	= [self writeableFilePath:aName];

    success = [fileManager fileExistsAtPath:writableFilePath];
    if (success){
		success = [fileManager removeItemAtPath:writableFilePath error:&error];
		if( ! success )
			RZLog(RZLogWarning, @"Failed to delete database file '%@' with message '%@'.", writableFilePath, [error localizedDescription]);
	}else{
		return;
	};
}


+(void)createEditableCopyOfFile:(NSString*)aName{
    BOOL				success;
    NSError			*	error;
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSString		*	writableFilePath	= [self writeableFilePath:aName];

    success = [fileManager fileExistsAtPath:writableFilePath];
    if (success){
		success = [fileManager removeItemAtPath:writableFilePath error:&error];
		if( ! success )
			RZLog(RZLogError, @"Failed to delete database file '%@' with message '%@'.", writableFilePath, [error localizedDescription]);
	}

    NSString *defaultFilePath = [RZFileOrganizer bundleFilePath:aName];
    success = [fileManager fileExistsAtPath:defaultFilePath];
    if (!success) {
        RZLog( RZLogError,@"Failed to find '%@'.", defaultFilePath);
    }

    success = [fileManager copyItemAtPath:defaultFilePath toPath:writableFilePath error:&error];
    if (!success) {
        RZLog(RZLogError, @"Failed to create writable file '%@' with message '%@'.", writableFilePath, [error localizedDescription]);
    }
}

+(void)removeEditableFile:(NSString*)aName{
    BOOL				success;
    NSError			*	error;
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSString		*	writableFilePath	= [self writeableFilePath:aName];

    success = [fileManager fileExistsAtPath:writableFilePath];
    if (success){
		success = [fileManager removeItemAtPath:writableFilePath error:&error];
		if( ! success )
			RZLog(RZLogError, @"Failed to delete database file '%@' with message '%@'.", writableFilePath, [error localizedDescription]);
	}

}

+(BOOL)createEditableCopyOfFileIfNeeded:(NSString*)aName {
    BOOL				success;
	BOOL				rebuild = NO;
    NSError			*	error;
    NSFileManager	*	fileManager			= [NSFileManager defaultManager];
    NSString		*	writableFilePath	= [self writeableFilePath:aName];

    success = [fileManager fileExistsAtPath:writableFilePath];
    if (success){
		if( rebuild ){
			success = [fileManager removeItemAtPath:writableFilePath error:&error];
			if( ! success )
				RZLog( RZLogError, @"Failed to delete database file '%@' with message '%@'.", writableFilePath, [error localizedDescription]);
		}else{
			return FALSE;// did not need rebuild
		};
	}


    NSString *defaultFilePath = [RZFileOrganizer bundleFilePath:aName];
    success = [fileManager fileExistsAtPath:defaultFilePath];
    if (!success) {
        RZLog( RZLogError, @"Failed to find '%@'.", defaultFilePath);
    }

    success = [fileManager copyItemAtPath:defaultFilePath toPath:writableFilePath error:&error];
    if (!success) {
        RZLog( RZLogError, @"Failed to create writable file '%@' with message '%@'.", writableFilePath, [error localizedDescription]);
    }
	return( TRUE ); // needed rebuild
}

+(void)saveDictionary:(NSDictionary*)aDict withName:(NSString*)aName{
    NSFileManager*	fileManager			= [NSFileManager defaultManager];
    NSString*		writableFilePath	= [RZFileOrganizer writeableFilePath:aName];
    NSError*		error				= nil;

	if( ! [aDict writeToFile:writableFilePath atomically:YES] ){
		RZLog( RZLogError, @"Failed to write %@, deleting", aName);
        if(![fileManager removeItemAtPath:writableFilePath error:&error]){
            RZLog(RZLogError, @"Failed to remove file: %@", error.localizedDescription);
        };
	}
}

+(NSDictionary*)loadDictionary:(NSString*)aName{
    NSFileManager*	fileManager			= [NSFileManager defaultManager];
    NSString*		writableFilePath	= [self writeableFilePath:aName];
	NSDictionary * rv = nil;
    if( [fileManager fileExistsAtPath:writableFilePath] ){

		rv = [NSDictionary dictionaryWithContentsOfFile:writableFilePath];
	}
	if( !rv ) {
		rv = [NSDictionary dictionary];
	}
	return( rv );
}

+(void)saveArray:(NSArray*)aDict withName:(NSString*)aName{
    NSFileManager*	fileManager			= [NSFileManager defaultManager];
    NSString*		writableFilePath	= [RZFileOrganizer writeableFilePath:aName];
    NSError*		error				= nil;

	if( ! [aDict writeToFile:writableFilePath atomically:YES] ){
		RZLog(RZLogError, @"Failed to write %@, deleting", aName);
        if(![fileManager removeItemAtPath:writableFilePath error:&error]){
            RZLog(RZLogError, @"Failed to remove file: %@", error.localizedDescription);
        };
	}
}
+(NSArray*)loadArray:(NSString*)aName{
    NSFileManager*	fileManager			= [NSFileManager defaultManager];
    NSString*		writableFilePath	= [self writeableFilePath:aName];
	NSArray * rv = nil;
    if( [fileManager fileExistsAtPath:writableFilePath] ){
        rv = [NSArray arrayWithContentsOfFile:writableFilePath];
	}
	if( !rv ) {
		rv = @[];
	}
	return( rv );
}

@end
