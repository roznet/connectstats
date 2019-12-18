#!/usr/bin/env python3

#
# This script will try to auto populate known field from the fit format to the connectstats format
# it processes the output of fitconv.py in fit-swift-sdk and won't modify the keys that are not
# equal to themselves. This way any manually updated key will be preserved but new keys maybe
# added automatically if they exists
#
# It will determine if a field exist that checking if it's in the fields.db
#

import sqlite3
import json
from pprint import pprint

def to_snake_case(not_snake_case):
    final = ''
    for i in xrange(len(not_snake_case)):
        item = not_snake_case[i]
        if i < len(not_snake_case) - 1:
            next_char_will_be_underscored = (
                not_snake_case[i+1] == "_" or
                not_snake_case[i+1] == " " or
                not_snake_case[i+1].isupper()
            )
        if (item == " " or item == "_") and next_char_will_be_underscored:
            continue
        elif (item == " " or item == "_"):
            final += "_"
        elif item.isupper():
            final += "_"+item.lower()
        else:
            final += item
    if final[0] == "_":
        final = final[1:]
    return final

def to_camel_case(not_camel_case):
    components = not_camel_case.split( '_' )
    return ''.join([x.title() for x in components ] )
    

connto = sqlite3.connect('out/fields.db')

def known_fields():
    sql = 'SELECT field FROM gc_fields_en GROUP BY field'
    rv = {}
    for row in connto.execute( sql ):
        rv[row[0]] = 1
    return rv

with open('out/fit_map.json', 'r' ) as of:
    existing = json.load( of )

# know are the fields that connectstats will know from the fields database
# it means it will know the display name and the units
known = known_fields()
known_map = {
    'altitude'                        : 'GainElevation',
    'avg_altitude'                    : 'WeightedMeanElevation',
    'avg_cadence'                     : 'WeightedMeanCadence',
    'avg_fractional_cadence'          : 'WeightedMeanFractionalCadence',
    'avg_heart_rate'                  : 'WeightedMeanHeartRate',
    'avg_lap_time'                    : 'SumDuration',
    'avg_neg_grade'                   : 'WeightedMeanNegGrade',
    'avg_neg_vertical_speed'          : 'WeightedMeanNegVerticalSpeed',
    'avg_pos_grade'                   : 'WeightedMeanPosGrade',
    'avg_pos_vertical_speed'          : 'WeightedMeanPosVerticalSpeed',
    'avg_power'                       : 'WeightedMeanPower',
    'avg_speed'                       : 'WeightedMeanSpeed',
    'avg_stance_time'                 : 'WeightedMeanStanceTime',
    'avg_stance_time_percent'         : 'WeightedMeanStanceTimePercent',
    'avg_stroke_count'                : 'WeightedMeanStrokes',
    'avg_stroke_distance'             : 'WeightedMeanStrokeDistance',
    'avg_swimming_cadence'            : 'WeightedMeanSwimCadence',
    'avg_temperature'                 : 'WeightedMeanAirTemperature',
    'avg_vertical_oscillation'        : 'WeightedMeanVerticalOscillation',
    'cadence'                         : 'WeightedMeanCadence',
    'distance'                        : 'SumDistance',
    'enhanced_altitude'               : 'GainElevation',
    'enhanced_avg_altitude'           : 'GainElevation',
    'enhanced_avg_speed'              : 'WeightedMeanSpeed',
    'enhanced_max_altitude'           : 'MaxElevation',
    'enhanced_max_speed'              : 'MaxSpeed',
    'enhanced_min_altitude'           : 'MinElevation',
    'enhanced_speed'                  : 'WeightedMeanSpeed',
    'heart_rate'                      : 'WeightedMeanHeartRate',
    'intensity_factor'                : 'SumIntensityFactor',
    'left_pedal_smoothness'           : 'WeightedMeanLeftPedalSmoothness',
    'left_right_balance'              : 'WeightedMeanRightBalance',
    'left_torque_effectiveness'       : 'WeightedMeanLeftTorqueEffectiveness',
    'max_altitude'                    : 'MaxElevation',
    'max_cadence'                     : 'MaxCadence',
    'max_fractional_cadence'          : 'MaxFractionalCadence',
    'max_heart_rate'                  : 'MaxHeartRate',
    'max_power'                       : 'MaxPower',
    'max_speed'                       : 'MaxSpeed',
    'max_temperature'                 : 'MaxAirTemperature',
    'min_altitude'                    : 'MinElevation',
    'min_heart_rate'                  : 'MinHeartRate',
    'normalized_power'                : 'WeightedMeanNormalizedPower',
    'power'                           : 'WeightedMeanPower',
    'right_pedal_smoothness'          : 'WeightedMeanRightPedalSmoothness',
    'right_torque_effectiveness'      : 'WeightedMeanRightTorqueEffectiveness',
    'speed'                           : 'WeightedMeanSpeed',
    'stance_time'                     : 'WeightedMeanGroundContactTime',
    'temperature'                     : 'WeightedMeanAirTemperature',
    'threshold_power'                 : 'ThresholdPower',
    'total_anaerobic_training_effect' : 'SumAnaerobicTrainingEffect',
    'total_ascent'                    : 'GainElevation',
    'total_calories'                  : 'SumEnergy',
    'total_descent'                   : 'LossElevation',
    'total_distance'                  : 'SumDistance',
    'total_elapsed_time'              : 'SumElapsedDuration',
    'total_moving_time'               : 'SumMovingDuration',
    'total_strokes'                   : 'SumStrokes',
    'total_timer_time'                : 'SumDuration',
    'total_training_effect'           : 'SumTrainingEffect2',
    'training_stress_score'           : 'SumTrainingStressScore',
    'vertical_oscillation'            : 'WeightedMeanVerticalRatio',
}

verbose = False

oldused = {}
missing = {}
for (msg,defs) in existing.items():
    newdefs = defs.copy()

    for (key,val) in defs.items():

        # check if already changed in the json file
        if key != val:
            if val != known_map[key] and verbose:
                print( 'Diff:    {} maps to {} but expected {}'.format( key, val, known_map[key] ) )
            if val not in known and verbose:
                print( 'Unknown: {} maps to {} but not a known field'.format( key, val ) )
            continue
        
        checkval = val
        for (fit,cs) in [ ('total_', 'sum_'), ('avg_', 'weighted_mean_'), ('enhanced_avg_', 'weighted_mean_'), ('enhanced_', 'weighted_mean_')]:
            if checkval.startswith( fit ):
                checkval = checkval.replace( fit,cs )
                break
            
        candidate = to_camel_case( checkval )
        if candidate in known:
            newdefs[val] = candidate
        elif val in known_map:
            if val not in known and verbose:
                print( 'Unknown: {} maps to {} but not a known field'.format( key, val ) )
            newdefs[val] = known_map[val]
        else:
            missing[val] = val
            
    existing[msg] = newdefs

if verbose and len(missing ):
    print( 'Missing fields:' )
    pprint( missing )

with open( 'out/fit_map.json', 'w' ) as outfile:
    json.dump( existing, outfile, indent = 2, sort_keys = True )
    
print( 'Saved out/fit_map.json' )
