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

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^FileOrganizerMatch)(NSString*fn);

@interface RZFileOrganizer : NSObject

/**
 @brief return path to the bundle corresponding to a class. Useful for example for test bundles.
 @param aName file name to append to path, if nil only return the path
 @param cls Class for the bundle.
 */
+(NSString*)bundleFilePath:(nullable NSString*)aName forClass:(Class)cls;
+(nullable NSString*)bundleFilePathIfExists:(NSString*)aName forClass:(Class)cls;
/**
 @brief path to a bundle file
 @param aName file name to add to path, if nil, it will return just the path to the sandbox
 */
+(NSString*)bundleFilePath:(nullable NSString*)aName;
+(nullable NSString*)bundleFilePathIfExists:(NSString*)aName;
+(NSArray<NSString*>*)bundleFilesMatching:(nullable FileOrganizerMatch)match forClass:(Class)cls;


/**
 @brief path of a writable file in the user sandbox
 @param aName file name to add to path, if nil, it will return just the path to the sandbox
 */
+(NSString*)writeableFilePath:(nullable NSString*)aName;
+(NSString*)writeableFilePathWithFormat:(nullable NSString*)fmt, ...;
+(nullable NSString*)writeableFilePathIfExists:(NSString*)aName;
+(nullable NSString*)writeableFilePathIfExistsWithFormat:(NSString*)fmt, ...;
+(NSArray<NSString*>*)writeableFilesMatching:(nullable FileOrganizerMatch)match;
+(BOOL)ensureWriteableFilePath:(NSString*)aName;

/**
 @brief path to a writable file in the group shared area
 @param aName file name, i fnil will return just the path
 @param group url of the group
 @return path for file or nil if group is not supported
 */
+(nullable NSString*)writeableFilePath:(nullable NSString*)aName forGroup:(NSString*)group;

+(void)createEditableCopyOfFile:(NSString*)aName;
+(BOOL)createEditableCopyOfFileIfNeeded:(NSString*)aName;
+(void)createEditableCopyOfFile:(NSString*)aName forClass:(Class)cls;
+(void)forceRebuildEditable:(NSString*)aName;
+(void)removeEditableFile:(NSString*)aName;

+(void)saveDictionary:(NSDictionary*)aDict withName:(NSString*)aName;
+(NSDictionary*)loadDictionary:(NSString*)aName;
+(void)saveArray:(NSArray*)aArray withName:(NSString*)aName;
+(NSArray*)loadArray:(NSString*)aName;

@end

NS_ASSUME_NONNULL_END
