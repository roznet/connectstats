#!/usr/bin/env python3

import sys
import os
import json
import argparse

def mkdir(path,doit):
    if not os.path.isdir( path ):
        print( 'mkdir {}'.format( path ) )
        if doit:
            os.mkdir(path)

def save_json( jsonpath, contents, doit ):
    print( 'Saving {}'.format( jsonpath ) )
    if doit:
        with open( jsonpath, 'w' ) as jsonfile:
            json.dump( contents, jsonfile )

    
def info_json():
    return {"info": { "version":1,"author":"xcode" } }
            
def colorset_json( defs ):
    rv = { "info": { "version":1,"author":"xcode" },
           "colors" : defs['colors']
    }
    return rv
    
            
def save_theme(theme, jsonfile, doit = False):

    with open(jsonfile,'r') as jf:
        defs = json.load(jf)
    
    assetdir = 'Colors-{}.xcassets'.format( theme )
    if not os.path.isdir( assetdir ):
        mkdir( assetdir, doit )
    save_json( "{}/Contents.json".format( assetdir ), info_json(), doit )

    for (key,components) in defs.items():
        name = '{theme}-{key}'.format( theme = theme, key = key )

        colorsetdir = '{}/{}.colorset'.format( assetdir, name )
        mkdir( colorsetdir, doit )

        contents = colorset_json( components )

        jsonpath = '{}/Contents.json'.format( colorsetdir )
        save_json( jsonpath, contents, doit )

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser( description='Build Theme Base', formatter_class=argparse.RawTextHelpFormatter )
    parser.add_argument( 'theme', help='Name of the theme to create' )
    parser.add_argument( 'jsonfile', help='Path to json file generated from the unit test GCTestUserInterface.testSkins' )
    parser.add_argument( '-s', '--save', help='Actually save all the directories and json files for the asset catalog', action='store_true' )
    parser.add_argument( '-v', '--verbose', help='verbose output', action='store_true' )
    args = parser.parse_args()

    save_theme( args.theme, args.jsonfile, args.save )
