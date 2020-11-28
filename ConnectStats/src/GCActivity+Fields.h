//  MIT Licence
//
//  Created on 23/01/2016.
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

#import <Foundation/Foundation.h>
#import "GCActivity.h"
#import "ConnectStats-Swift.h"

@interface GCActivity (Fields)

-(GCField*)fieldForKey:(NSString*)fieldkey;
-(GCNumberWithUnit*)numberWithUnitForFieldFlag:(gcFieldFlag)fieldFlag ;
-(GCNumberWithUnit*)numberWithUnitForFieldKey:(NSString*)fieldKey ;

/**
 *  Organized and group fields available in the activity
 *  Primary fields as NSArray of NSArray of NSString for each Field Key for related field
 *                                  of the fields in displayPrimaryFields
 *  Other Fields as NSArray of NSArray of NSString for each field key of fields not in previous
 *                                  array
 *
 */
-(GCActivityOrganizedFields*)groupedFields;


//DEPRECATED_MSG_ATTRIBUTE("use displayUnitForField.")

@end
