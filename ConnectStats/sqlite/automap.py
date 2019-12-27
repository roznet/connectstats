#!/usr/bin/env python3
#
# This will automatically try to generate a list of activity types by
# trying to fuzzy match the input list with the known types by connectstats
# can be expanded later for fields name if necessary

import sqlite3
import json
import pprint

import numpy as np
from fuzzywuzzy import fuzz

# replace with which ever list needs to be converted
tomap = (

    "GENERIC",
    "RUNNING",
    "CYCLING",
    "TRANSITION",
    "FITNESS_EQUIPMENT",
    "SWIMMING",
    "BASKETBALL",
    "SOCCER",
    "TENNIS",
    "AMERICAN_FOOTBALL",
    "TRAINING",
    "WALKING",
    "CROSS_COUNTRY_SKIING",
    "ALPINE_SKIING",
    "SNOWBOARDING",
    "ROWING",
    "MOUNTAINEERING",
    "HIKING",
    "MULTISPORT",
    "PADDLING",
    "FLYING",
    "E_BIKING",
    "MOTORCYCLING",
    "BOATING",
    "DRIVING",
    "GOLF",
    "HANG_GLIDING",
    "HORSEBACK_RIDING",
    "HUNTING",
    "FISHING",
    "INLINE_SKATING",
    "ROCK_CLIMBING",
    "SAILING",
    "ICE_SKATING",
    "SKY_DIVING",
    "SNOWSHOEING",
    "SNOWMOBILING",
    "STAND_UP_PADDLEBOARDING",
    "SURFING",
    "WAKEBOARDING",
    "WATER_SKIING",
    "KAYAKING",
    "RAFTING",
    "WINDSURFING",
    "KITESURFING",
    "TACTICAL",
    "JUMPMASTER",
    "BOXING",
    "FLOOR_CLIMBING",
)

def search():
    connto = sqlite3.connect('out/fields.db')
    res = connto.execute( 'SELECT activityTypeDetail FROM gc_activityType_modern' );

    types = res.fetchall();
    for one in tomap:
        best = None
        found = None
        for candidate in types:
            ratio = fuzz.ratio(one.lower(), candidate[0].lower() )
            if best is None or best < ratio:
                found = candidate[0]
                best = ratio

        print( '  @"{}": @"{}",'.format( one, found ) )


    
search()
