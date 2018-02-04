//
//  FITFitFileDecode.m
//  GarminConnect
//
//  Created by Brice Rosenzweig on 04/05/2016.
//  Copyright © 2016 Brice Rosenzweig. All rights reserved.
//

#import "FITFitFileDecode.h"
#import "GCUnit+FIT.h"
#import "RZUtils/RZUtils.h"
#import "FITFitFile.h"



#include <fstream>
#include <iostream>
#include <strstream>
#include <sstream>
#import "RZExternalCpp/RZExternalCpp.h"
#include "FITFitEnumMap.h"

// Include at the end to avoid redefine
#import "FITFitFieldValue.h"

#define SEMICIRCLE_TO_DEGREE(x) (double)x*(180./2147483648.)

@interface FITFitFileDecode ()
@property (nonatomic,strong) NSData * data;


@property (nonatomic) NSUInteger currentMessageIndex;



@end


#pragma mark - Listener

class Listener : public fit::MesgListener
{
    public :
    NSObject<FITFitFileDecodeListenerProtocol> * delegate;
    
    
    void OnMesg(fit::Mesg&mesg){
        NSString * messageName = [NSString stringWithUTF8String:mesg.GetName().c_str()];
        NSMutableDictionary * values = [NSMutableDictionary dictionaryWithCapacity:mesg.GetNumFields()];
        
        for (FIT_UINT16 i = 0; i < (FIT_UINT16)mesg.GetNumFields(); i++)
        {
            fit::Field* field = mesg.GetFieldByIndex(i);
            FITFitFieldValue * val = [FITFitFieldValue fieldValueFrom:*field];
            NSString * fieldname = val.fieldKey;
            values[fieldname] = val;
        }
        std::vector<fit::DeveloperField> dev = mesg.GetDeveloperFields();
        if( dev.size() > 0){
            for( auto one = dev.begin(); one != dev.end(); ++one ){
                FITFitFieldValue * val = [FITFitFieldValue fieldValueFromDeveloper:*one];
                NSString * fieldname = val.fieldKey;
                values[fieldname] = val;
            }
        }
        
        // Collapsed locations:
        NSMutableDictionary * toRemove = [NSMutableDictionary dictionary];
        NSMutableDictionary * locations = [NSMutableDictionary dictionary];
        
        for (NSString * fieldKey in values) {
            if( [fieldKey hasSuffix:@"_lat"]){
                NSString * prefix = [fieldKey substringToIndex:(fieldKey.length-4)];
                NSString * longFieldKey = [prefix stringByAppendingString:@"_long"];
                if (values[longFieldKey]) {
                    FITFitFieldValue * longValue = values[longFieldKey];
                    FITFitFieldValue * latValue = values[fieldKey];
                    FITFitFieldValue * locValue = [latValue locationFieldForComplement:longValue];
                    if( locValue ){
                        locations[prefix] = locValue;
                        [toRemove addEntriesFromDictionary:@{longFieldKey:@(1),fieldKey:@(1)}];
                    }
                }
            }
        }
        for (NSString * fieldKey in toRemove) {
            [values removeObjectForKey:fieldKey];
        }
        for (NSString * fieldKey in locations) {
            values[fieldKey] = locations[fieldKey];
        }
        
        [this->delegate recordMessage:messageName values:values];
    }
    

    
};


@implementation FITFitFileDecode

#if !__has_feature(objc_arc)
-(void)dealloc{
    [_fitFile release];
    [_data release];
    [super dealloc];
}
#endif

+(FITFitFileDecode*)fitFileDecode:(NSData*)data{
    FITFitFileDecode * rv = RZReturnAutorelease([[FITFitFileDecode alloc] init]);
    if (rv) {
        rv.data = data;
    }
    return rv;
}

+(FITFitFileDecode*)fitFileDecodeForFile:(NSString*)filepath{
    FITFitFileDecode * rv = RZReturnAutorelease([[FITFitFileDecode alloc] init]);
    if (rv) {
        rv.data = [NSData dataWithContentsOfFile:filepath];
    }
    return rv;
    
}

-(void)testStreams{
    std::stringstream memstream;
    memstream << "h";
    memstream << 1;
    memstream.put('\0');
    memstream << "y";
    
    std::string s = memstream.str();
    // This makes a copy of the buffer
    NSData * data = [NSData dataWithBytes:s.c_str() length:s.length()];
    
    std::cout << "result :"<< s << " / "<< data.length << std::endl;
}

-(void)parse{
    
    RZPerformance * perf = [RZPerformance start];
    fit::Decode decode;
    fit::MesgBroadcaster mesgBroadcasterMain;
    Listener listener;
    listener.delegate = self;
    
    std::istrstream memistream(reinterpret_cast<const char*>(_data.bytes), _data.length);
    
    if (!decode.CheckIntegrity(memistream))
    {
        RZLog(RZLogError, @"FIT file integrity failed.");
        return;
    }
    
    self.fitFile = [FITFitFile fitFile];
    self.currentMessageIndex = 0;
    
    mesgBroadcasterMain.AddListener((fit::MesgListener&)listener);
    
    try
    {
        mesgBroadcasterMain.Run(memistream);
    }
    catch (const fit::RuntimeException& e)
    {
        RZLog(RZLogError, @"Exception decoding file: %s", e.what());
        return;
    }
    
    RZLog( RZLogInfo, @"Decoded FIT file %@", perf);
}

-(void)recordMessage:(NSString *)messageType values:(NSDictionary *)dict{
    
    FITFitMessageFields * fields = [FITFitMessageFields fitMessageFields:dict atIndex:self.currentMessageIndex++];
    
    [self.fitFile addMessageFields:fields forMessageType:messageType];
    
}

@end
