#!/usr/bin/python

import sys
import os
import json

theme = "default"
doit = True

def uicolorhex( hex, alp ):
    return {"red":"0x{}".format(hex[2:4]), "green":"0x{}".format(hex[4:6]),"blue":"0x{}".format(hex[6:8]),"alpha":"{}".format( alp ) }


GC_TYPE_RUNNING =     "running";
GC_TYPE_CYCLING =     "cycling";
GC_TYPE_SWIMMING =    "swimming";
GC_TYPE_HIKING =      "hiking";
GC_TYPE_FITNESS =     "fitness_equipment";
GC_TYPE_WALKING =     "walking";
GC_TYPE_OTHER =       "other";
GC_TYPE_ALL =         "all";

GC_TYPE_DAY =         "day";
GC_TYPE_TENNIS =      "tennis";

GC_TYPE_MULTISPORT =  "multi_sport";
GC_TYPE_TRANSITION =  "transition";

GC_TYPE_SKI_XC =      "cross_country_skiing";
GC_TYPE_SKI_DOWN =    "resort_skiing_snowboarding";
GC_TYPE_SKI_BACK =    "backcountry_skiing_snowboarding";
GC_TYPE_INDOOR_ROWING = "indoor_rowing";
GC_TYPE_ROWING =      "rowing";

GC_TYPE_UNCATEGORIZED = "uncategorized";

defs = {
    "{theme}-SwimStrokeColor-gcSwimStrokeFree": {"red":"0xC4", "green":"0x3D", "blue":"0xBF", "alpha":"0.8"},
    "{theme}-SwimStrokeColor-gcSwimStrokeBack": {"red":"0x1F", "green":"0x8E","blue":"0xF0", "alpha":"0.8"},
    "{theme}-SwimStrokeColor-gcSwimStrokeBreast": {"red":"0x95", "green":"0xDE", "blue":"0x2B", "alpha":"0.8"},
    "{theme}-SwimStrokeColor-gcSwimStrokeButterfly": {"red":"0xD5", "green":"0x76","blue":"0xD1", "alpha":"0.8"},
    "{theme}-SwimStrokeColor-gcSwimStrokeOther": {"red":"0x61", "green":"0xAF","blue":"0xF3", "alpha":"0.8"},
    "{theme}-SwimStrokeColor-gcSwimStrokeMixed": {"red":"0x61", "green":"0xAF", "blue":"0xF3", "alpha":"0.8"},

    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_SWIMMING,theme=theme): uicolorhex("0xFFE4A9", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_CYCLING,theme=theme):  uicolorhex("0xFFDADA", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_RUNNING,theme=theme):  uicolorhex("0xDCEEFF", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_HIKING,theme=theme):   uicolorhex("0xE8C89E", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_FITNESS,theme=theme):  uicolorhex("0xCAA4E8", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_TENNIS,theme=theme):   uicolorhex("0x22B5B0", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_MULTISPORT,theme=theme):uicolorhex("0xA6BB82", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_OTHER,theme=theme):uicolorhex("0xD2D2D2", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_SKI_BACK,theme=theme): uicolorhex("0xa2d7b5", 1.0),
    "{theme}-ActivityCellLighterBackgroundColor-{}".format(GC_TYPE_SKI_DOWN,theme=theme): uicolorhex("0xecf0f1",1.0),

    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_SWIMMING,theme=theme): uicolorhex("0xFFD466", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_CYCLING,theme=theme):  uicolorhex("0xFFA0A0", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_RUNNING,theme=theme):  uicolorhex("0x98D3FF", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_HIKING,theme=theme):   uicolorhex("0xC8A26A", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_FITNESS,theme=theme):  uicolorhex("0xF169EF", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_TENNIS,theme=theme):   uicolorhex("0x96CC00", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_MULTISPORT,theme=theme):uicolorhex("0xA6BB82", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_OTHER,theme=theme):uicolorhex("0xA6BB82", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_SKI_BACK,theme=theme): uicolorhex("0xa2d7b5", 1.0),
    "{theme}-ActivityCellDarkerBackgroundColor-{}".format(GC_TYPE_SKI_DOWN,theme=theme): uicolorhex("0xbdc3c7", 1.0)
}


def mkdir(path,doit):
    if not os.path.isdir( path ):
        print 'mkdir {}'.format( path )
        if doit:
            os.mkdir(path)

def save_json( jsonpath, contents, doit ):
    print( 'Saving {}'.format( jsonpath ) )
    if doit:
        with open( jsonpath, 'w' ) as jsonfile:
            json.dump( contents, jsonfile )

    
def info_json():
    return {"info": { "version":1,"author":"xcode" } }
            
def color_json( defs ):
    return { "color-space": "srgb", "components" : defs }

def colorset_json( defs ):
    rv = { "info": { "version":1,"author":"xcode" },
           "colors" : [ { "idiom": "universal",
                          "color" : color_json( defs ) },
                        { "idiom": "universal", "appearances" : [ { "appearance": "luminosity", "value": "dark" } ],
                          "color" : color_json( defs ) }
           ]
    }
    return rv
    
            

assetdir = 'Colors-{}.xcassets'.format( theme )
if not os.path.isdir( assetdir ):
    mkdir( assetdir, doit )
save_json( "{}/Contents.json".format( assetdir ), info_json(), doit )

for (key,components) in defs.iteritems():
    name = key.format( theme = theme )

    colorsetdir = '{}/{}.colorset'.format( assetdir, name )
    mkdir( colorsetdir, doit )

    contents = colorset_json( components )

    jsonpath = '{}/Contents.json'.format( colorsetdir )
    save_json( jsonpath, contents, doit )
           
