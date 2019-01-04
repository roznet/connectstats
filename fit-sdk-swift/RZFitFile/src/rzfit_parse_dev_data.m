//  MIT License
//
//  Created on 02/01/2019 for ConnectStats
//
//  Copyright (c) 2019 Brice Rosenzweig
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


#include "rzfit_parse_dev_data.h"

#include "rzfit_convert_auto.h"
#include "fit_example.h"

const FIT_UINT16 kMaxDevFields = 64;

@interface RZFitDevDataParser ()
@property (nonatomic,assign) FIT_CONVERT_STATE * state;
@property (nonatomic,assign) FIT_UINT8 * dev_data_buffer;
@property (nonatomic,assign) FIT_UINT16 dev_data_buffer_size;
@property (nonatomic,assign) FIT_FIELD_DESCRIPTION_MESG * dev_field_description;
@property (nonatomic,assign) NSUInteger dev_field_description_index;
@property (nonatomic,assign) NSUInteger dev_field_description_size;
@property (nonatomic,retain) NSMutableDictionary<NSString*,NSString*> * cacheUnits;

@property (nonatomic,retain) NSArray<NSString*>*knownUnits;

@end

@implementation RZFitDevDataParser

+(RZFitDevDataParser*)devDataParser:(FIT_CONVERT_STATE *)state knownUnits:(NSArray<NSString*>*)known{
    RZFitDevDataParser * rv = [[RZFitDevDataParser alloc] init];
    rv.state = state;
    rv.dev_data_buffer_size = 256;
    rv.dev_data_buffer = malloc(rv.dev_data_buffer_size);
    rv.dev_field_description_size = kMaxDevFields;
    rv.dev_field_description = malloc(sizeof(FIT_FIELD_DESCRIPTION_MESG)*rv.dev_field_description_size);
    rv.dev_field_description_index = 0;
    rv.knownUnits = known;
    rv.cacheUnits = [NSMutableDictionary dictionary];
    return rv;
}

-(void)dealloc{
    free(self.dev_data_buffer);
    free(self.dev_field_description);
    
    RZRelease(_knownUnits);
    RZSuperDealloc;
}

-(void)recordDeveloperField:(const FIT_UINT8*)mesgR{
    FIT_FIELD_DESCRIPTION_MESG * mesg = (FIT_FIELD_DESCRIPTION_MESG*)mesgR;
    if( self.dev_field_description_index < self.dev_field_description_size){
        memcpy(self.dev_field_description+self.dev_field_description_index, mesg, sizeof(FIT_FIELD_DESCRIPTION_MESG));
        self.dev_field_description_index++;
        NSString * key = [NSString stringWithCString:mesg->field_name encoding:NSUTF8StringEncoding];
        NSString * unit = [NSString stringWithCString:mesg->units encoding:NSUTF8StringEncoding];
        
        // if match existing, use that for consistency
        for (NSString * one in self.knownUnits) {
            if( [[unit lowercaseString] isEqualToString:[one lowercaseString]] ){
                unit = one;
            }
        }
        
        if( unit.length > 0){
            if( mesg->native_mesg_num != FIT_MESG_NUM_INVALID && mesg->native_field_num != FIT_FIELD_NUM_INVALID){
                NSString * native = objc_rzfit_field_num_to_field(mesg->native_mesg_num,mesg->native_field_num);
                if( native ){
                    // record both so later we can find it as native as well
                    self.cacheUnits[native] = unit;
                }
            }

            self.cacheUnits[key] = unit;
        }
    }
}

-(void)initState:(FIT_CONVERT_STATE*)state{
    state->dev_data_buffer = self.dev_data_buffer;
    state->dev_data_buffer_size = self.dev_data_buffer_size;
}

-(nullable NSDictionary<NSString*,NSNumber*>*)parseData{
    if( self.state->dev_data_buffer_index == 0){
        return nil;
    }
    
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    
    NSUInteger index = 0;
    for (NSUInteger field_index = 0; field_index < self.dev_field_description_index; ++field_index) {
        FIT_FIELD_DESCRIPTION_MESG * desc = self.dev_field_description+field_index;
        FIT_MESG_NUM num = FitConvert_GetMessageNumber(self.state);
        
        if( (desc->native_mesg_num == num || desc->native_mesg_num == FIT_MESG_NUM_INVALID)
           && index < self.state->dev_data_buffer_index ){
            
            NSString * name = [NSString stringWithCString:desc->field_name encoding:NSUTF8StringEncoding];
            if( desc->native_mesg_num != FIT_MESG_NUM_INVALID && desc->native_field_num != FIT_FIELD_NUM_INVALID){
                NSString * native = objc_rzfit_field_num_to_field(desc->native_mesg_num,desc->native_field_num);
                if( native ){
                    name = native;
                }
            }
            NSNumber * val = nil;
            switch( desc->fit_base_type_id ){
                case FIT_FIT_BASE_TYPE_ENUM:
                {
                    FIT_ENUM * raw = (FIT_ENUM*)(self.dev_data_buffer+index);
                    if( *raw != FIT_ENUM_INVALID)
                        val = [NSNumber numberWithInt:*raw];
                    index += sizeof(FIT_ENUM);
                    break;
                }
                case FIT_FIT_BASE_TYPE_SINT8:
                {
                    FIT_SINT8 * raw = (FIT_SINT8*)(self.dev_data_buffer+index);
                    if( *raw != FIT_SINT8_INVALID)
                        val = [NSNumber numberWithInt:*raw];
                    index += sizeof(FIT_SINT8);
                    break;
                }
                case FIT_FIT_BASE_TYPE_BYTE:
                case FIT_FIT_BASE_TYPE_UINT8Z:
                case FIT_FIT_BASE_TYPE_UINT8:
                {
                    FIT_UINT8 * raw = (FIT_UINT8*)(self.dev_data_buffer+index);
                    if( *raw != FIT_UINT8_INVALID)
                        val = [NSNumber numberWithInt:*raw];
                    index += sizeof(FIT_UINT8);
                    break;
                }

                case FIT_FIT_BASE_TYPE_SINT16:
                {
                    FIT_SINT16 * raw = (FIT_SINT16*)(self.dev_data_buffer+index);
                    if( *raw != FIT_SINT16_INVALID)
                        val = [NSNumber numberWithInt:*raw];
                    index += sizeof(FIT_SINT16);
                    break;
                }
                case FIT_FIT_BASE_TYPE_UINT16Z:
                case FIT_FIT_BASE_TYPE_UINT16:
                {
                    FIT_UINT16 * raw = (FIT_UINT16*)(self.dev_data_buffer+index);
                    if( *raw != FIT_UINT16_INVALID)
                        val = [NSNumber numberWithInt:*raw];
                    index += sizeof(FIT_UINT16);
                    break;
                }
                case FIT_FIT_BASE_TYPE_SINT32:
                {
                    FIT_SINT32 * raw = (FIT_SINT32*)(self.dev_data_buffer+index);
                    if( *raw != FIT_SINT32_INVALID)
                        val = [NSNumber numberWithInt:*raw];
                    index += sizeof(FIT_SINT32);
                    break;
                }
                case FIT_FIT_BASE_TYPE_UINT32Z:
                case FIT_FIT_BASE_TYPE_UINT32:
                {
                    FIT_UINT32 * raw = (FIT_UINT32*)(self.dev_data_buffer+index);
                    if( *raw != FIT_UINT32_INVALID)
                        val = [NSNumber numberWithInt:*raw];
                    index += sizeof(FIT_UINT32);
                    break;
                }


                case FIT_FIT_BASE_TYPE_FLOAT32:
                {
                    FIT_FLOAT32 * raw = (FIT_FLOAT32*)(self.dev_data_buffer+index);
                    if( *raw != FIT_FLOAT32_INVALID)
                        val = [NSNumber numberWithFloat:*raw];
                    index += sizeof(FIT_FLOAT32);
                    break;
                }

                case FIT_FIT_BASE_TYPE_FLOAT64:
                {
                    FIT_FLOAT64 * raw = (FIT_FLOAT64*)(self.dev_data_buffer+index);
                    if( *raw != FIT_FLOAT64_INVALID)
                        val = [NSNumber numberWithDouble:*raw];
                    index += sizeof(FIT_FLOAT64);
                    break;
                }

                case FIT_FIT_BASE_TYPE_SINT64:
                {
                    FIT_SINT64 * raw = (FIT_SINT64*)(self.dev_data_buffer+index);
                    if( *raw != FIT_SINT64_INVALID)
                        val = [NSNumber numberWithLong:*raw];
                    index += sizeof(FIT_SINT64);
                    break;
                }

                case FIT_FIT_BASE_TYPE_UINT64Z:
                case FIT_FIT_BASE_TYPE_UINT64:
                {
                    FIT_UINT64 * raw = (FIT_UINT64*)(self.dev_data_buffer+index);
                    if( *raw != FIT_UINT64_INVALID)
                        val = [NSNumber numberWithLong:*raw];
                    index += sizeof(FIT_UINT64);
                    break;
                }
                case FIT_FIT_BASE_TYPE_STRING:
                default:
                {
                    continue;
                }
            }
            if( val ){
                rv[name] = val;
            }
        }
    }
    return rv;
}
-(nullable NSDictionary<NSString*,NSNumber*>*)nativeFields{
    if( self.state->dev_data_buffer_index == 0){
        return nil;
    }

    NSMutableDictionary * rv = [NSMutableDictionary dictionary];
    
    for (NSUInteger field_index = 0; field_index < self.dev_field_description_index; ++field_index) {
        FIT_FIELD_DESCRIPTION_MESG * desc = self.dev_field_description+field_index;
        if( desc->native_field_num != FIT_FIELD_NUM_INVALID){
            NSString * name = [NSString stringWithCString:desc->field_name encoding:NSUTF8StringEncoding];

            rv[ name ] = @(desc->native_field_num);
        }
    }
    return rv;
}
-(NSDictionary<NSString*,NSString*>*)units{
    if( self.dev_field_description_index == 0)
        return nil;
    
    return self.cacheUnits;
}
@end

