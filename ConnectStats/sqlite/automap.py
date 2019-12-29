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
tomap_fitsport = (

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

tomap = (
    'GENERIC',                                                    
    'TREADMILL',                                                  #  Run/Fitness Equipment
    'STREET',                                                     #  Run
    'TRAIL',                                                      #  Run
    'TRACK',                                                      #  Run
    'SPIN',                                                       #  Cycling
    'INDOOR_CYCLING',                                             #  Cycling/Fitness Equipment
    'ROAD',                                                       #  Cycling
    'MOUNTAIN_BIKING',                                            #  Cycling
    'DOWNHILL',                                                   #  Cycling
    'RECUMBENT',                                                  #  Cycling
    'CYCLOCROSS',                                                 #  Cycling
    'HAND_CYCLING',                                               #  Cycling
    'TRACK_CYCLING',                                              #  Cycling
    'INDOOR_ROWING',                                              #  Fitness Equipment
    'ELLIPTICAL',                                                 #  Fitness Equipment
    'STAIR_CLIMBING',                                             #  Fitness Equipment
    'LAP_SWIMMING',                                               #  Swimming
    'OPEN_WATER',                                                 #  Swimming
    'FLEXIBILITY_TRAINING',                                       #  Training
    'STRENGTH_TRAINING',                                          #  Training
    'WARM_UP',                                                    #  Tennis
    'MATCH',                                                      #  Tennis
    'EXERCISE',                                                   #  Tennis
    'CHALLENGE',                                                  
    'INDOOR_SKIING',                                              #  Fitness Equipment
    'CARDIO_TRAINING',                                            #  Training
    'INDOOR_WALKING',                                             #  Walking/Fitness Equipment
    'E_BIKE_FITNESS',                                             #  E-Biking
    'BMX',                                                        #  Cycling
    'CASUAL_WALKING',                                             #  Walking
    'SPEED_WALKING',                                              #  Walking
    'BIKE_TO_RUN_TRANSITION',                                     #  Transition
    'RUN_TO_BIKE_TRANSITION',                                     #  Transition
    'SWIM_TO_BIKE_TRANSITION',                                    #  Transition
    'ATV',                                                        #  Motorcycling
    'MOTOCROSS',                                                  #  Motorcycling
    'BACKCOUNTRY',                                                #  Alpine Skiing/Snowboarding
    'RESORT',                                                     #  Alpine Skiing/Snowboarding
    'RC_DRONE',                                                   #  Flying
    'WINGSUIT',                                                   #  Flying
    'WHITEWATER',                                                 #  Kayaking/Rafting
    'SKATE_SKIING',                                               #  Cross Country Skiing
    'YOGA',                                                       #  Training
    'PILATES',                                                    #  Fitness Equipment
    'INDOOR_RUNNING',                                             #  Run
    'GRAVEL_CYCLING',                                             #  Cycling
    'E_BIKE_MOUNTAIN',                                            #  Cycling
    'COMMUTING',                                                  #  Cycling
    'MIXED_SURFACE',                                              #  Cycling
    'NAVIGATE',                                                   
    'TRACK_ME',                                                   
    'MAP',                                                        
    'SINGLE_GAS_DIVING',                                          #  Diving
    'MULTI_GAS_DIVING',                                           #  Diving
    'GAUGE_DIVING',                                               #  Diving
    'APNEA_DIVING',                                               #  Diving
    'APNEA_HUNTING',                                              #  Diving
    'VIRTUAL_ACTIVITY',                                           
    'OBSTACLE',                                                   #  Used for events where participants run, crawl through mud, climb over walls, etc.
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
