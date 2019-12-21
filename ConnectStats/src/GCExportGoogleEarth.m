//  MIT Licence
//
//  Created on 10/01/2013.
//
//  Copyright (c) 2013 Brice Rosenzweig.
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

#import "GCExportGoogleEarth.h"
#import "GCFields.h"
#import "GCActivity+ExportText.h"
#import "GCField.h"
@import RZExternal;
@import RZExternalUniversal;

@implementation GCExportGoogleEarth
@synthesize activity;

/*
<Style id="linestyleExample">
<LineStyle>
<color>7f0000ff</color>
<width>4</width>
<gx:labelVisibility>1</gx:labelVisibility>
</LineStyle>
</Style>
*/

-(void)dealloc{
    [activity release];
    [super dealloc];
}

-(BOOL)saveKMZFile:(NSString*)kmzfn{

    NSString * kml = [self exportTrackKML];
    NSString * kmzpath = [RZFileOrganizer writeableFilePath:kmzfn];
    NSError * err = nil;
    
    OZZipFile * zipFile= [[OZZipFile alloc] initWithFileName:kmzpath mode:OZZipFileModeCreate error:&err];

    OZZipWriteStream *stream= [zipFile writeFileInZipWithName:@"track.kml" compressionLevel:OZZipCompressionLevelBest];
    [stream writeData:[kml dataUsingEncoding:NSUTF8StringEncoding]];
    [stream finishedWriting];
    [zipFile close];
    [zipFile release];

    return true;
}


-(NSString*)exportTrackKML{
    NSMutableString * output = [NSMutableString stringWithCapacity:256];

    [output appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\">\n"];
    GCXMLElement * document = [GCXMLElement element:@"Document"];
    GCXMLElement * style = [GCXMLElement element:@"Style"];

    NSArray<GCField*> * fields = [activity availableTrackFields];
    NSString * activityType = activity.activityType;

    GCXMLElement * schema = [GCXMLElement element:@"Schema"];
    [schema addParameter:@"id" withValue:@"schema"];
    for (GCField * field in fields) {
        NSString * key = field.key;
        GCXMLElement * schemaField = [GCXMLElement element:@"gx:SimpleArrayField"];
        [schemaField addParameter:@"name" withValue:key];
        [schemaField addParameter:@"type" withValue:@"float"];
        [schemaField addChild:[GCXMLElement element:@"displayName" withValue:[GCField fieldForKey:key andActivityType:activityType].displayName]];
        [schema addChild:schemaField];
    }

    [style addParameter:@"id" withValue:@"activitytrack"];
    GCXMLElement * linestyle = [GCXMLElement element:@"LineStyle"];
    [linestyle addChild:[GCXMLElement element:@"color" withValue:@"ffff0000"]];
    [linestyle addChild:[GCXMLElement element:@"width" withValue:@"4"]];
    [style addChild:linestyle];

    NSString * description = @"<![CDATA[Generated with <a href=\"https://www.ro-z.net/connectstats\">ConnectStats</a>]]>";
    NSString * source = [NSString stringWithFormat:@"<![CDATA[%@]]>",[activity exportSource]];

    [document addChild:[GCXMLElement element:@"name" withValue:[activity exportTitle]]];
    [document addChild:[GCXMLElement element:@"description" withValue:description]];
    [document addChild:style];
    [document addChild:schema];

    GCXMLElement * placemark = [GCXMLElement element:@"Placemark"];
    [placemark addChild:[GCXMLElement element:@"name" withValue:activity.activityName]];
    [placemark addChild:[GCXMLElement element:@"description" withValue:source]];
    [placemark addChild:[GCXMLElement element:@"styleUrl" withValue:@"#activitytrack"]];

    NSArray * points = [activity trackpoints];

    GCXMLElement * track = [GCXMLElement element:@"gx:Track"];
    NSMutableArray * when = [NSMutableArray arrayWithCapacity:points.count];
    NSMutableArray * coords = [NSMutableArray arrayWithCapacity:points.count];
    NSMutableArray * extra = [NSMutableArray arrayWithCapacity:fields.count];
    for (GCField * field in fields) {
        NSString * key = field.key;
        GCXMLElement * simpleArray = [GCXMLElement element:@"gx:SimpleArrayData"];
        [simpleArray addParameter:@"name" withValue:key];
        [extra addObject:simpleArray];
    }
    for (GCTrackPoint * point in points) {
        if ([point validCoordinate]) {
            [when addObject:[GCXMLElement element:@"when" withValue:[point.time formatAsRFC3339]]];
            NSString * coordval = [NSString stringWithFormat:@"%f %f %f", point.longitudeDegrees,point.latitudeDegrees,point.altitude];
            [coords addObject:[GCXMLElement element:@"gx:coord" withValue:coordval]];
            NSUInteger idx = 0;
            for (GCField * field in fields) {
                GCNumberWithUnit * val = [point numberWithUnitForField:field inActivity:activity];
                GCXMLElement * elemExtra = [GCXMLElement element:@"gx:value" withValue:[NSString stringWithFormat:@"%f", val.value]];
                [extra[idx] addChild:elemExtra];
                idx++;
            }
        }
    }
    NSMutableArray * trackchildren = [NSMutableArray arrayWithArray:when];
    [trackchildren addObjectsFromArray:coords];
    track.children = trackchildren;

    GCXMLElement * extended = [GCXMLElement element:@"ExtendedData"];
    GCXMLElement * schemaData = [GCXMLElement element:@"SchemaData"];
    [schemaData addParameter:@"schemaUrl" withValue:@"#schema"];
    for (GCXMLElement * oneArrayData in extra) {
        [schemaData addChild:oneArrayData];
    }
    [extended addChild:schemaData];
    [track addChild:extended];
    [placemark addChild:track];
    [document addChild:placemark];
    [output appendString:[document toXML:@""]];
    [output appendString:@"</kml>"];

    return output;
}


-(NSString*)exportLineStringKML{
    NSMutableString * output = [NSMutableString stringWithCapacity:256];

    [output appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n"];
    GCXMLElement * document = [GCXMLElement element:@"Document"];
    GCXMLElement * style = [GCXMLElement element:@"Style"];
    [style addParameter:@"id" withValue:@"activitytrack"];
    GCXMLElement * linestyle = [GCXMLElement element:@"LineStyle"];
    [linestyle addChild:[GCXMLElement element:@"color" withValue:@"ffff0000"]];
    [linestyle addChild:[GCXMLElement element:@"width" withValue:@"4"]];
    [style addChild:linestyle];

    [document addChild:[GCXMLElement element:@"name" withValue:@"Activity"]];
    [document addChild:[GCXMLElement element:@"description" withValue:@"Activity description"]];
    [document addChild:style];

    GCXMLElement * placemark = [GCXMLElement element:@"Placemark"];
    [placemark addChild:[GCXMLElement element:@"name" withValue:@"Activity Path"]];
    [placemark addChild:[GCXMLElement element:@"description" withValue:@""]];
    [placemark addChild:[GCXMLElement element:@"styleUrl" withValue:@"#activitytrack"]];
    GCXMLElement * linestring = [GCXMLElement element:@"LineString"];
    NSArray * points = [activity trackpoints];
    GCXMLElement * coordinates = [GCXMLElement element:@"coordinates"];
    if (points && points.count) {
        for (GCTrackPoint * aPoint in points) {
            if ([aPoint validCoordinate]) {
                NSString * tmp = [NSString stringWithFormat:@"%f,%f,0.0", aPoint.longitudeDegrees,aPoint.latitudeDegrees];
                [coordinates addChild:[GCXMLElement elementValue:tmp]];
            }
        }
        [linestring addChild:[GCXMLElement element:@"tessellate" withValue:@"1"]];
        [linestring addChild:coordinates];
        [placemark addChild:linestring];
    }
    [document addChild:placemark];

    [output appendString:[document toXML:@""]];
    [output appendString:@"</kml>"];
    return  output;
}
@end
