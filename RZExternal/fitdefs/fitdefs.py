#!/usr/bin/python
#
# Update to latest sdk:
# Update: (cd ~/Dowloads/FitSDKRelease_20/cpp/; cp *.hpp *.cpp ~/Development/xcode/shared/FitSDKRelease_20)
# run fitdefs.py and then cp the files as instructed in Install:
#



import re
import pprint
umap = {'%': 'percent',
        'bpm': 'bpm',
        'counts': 'dimensionless',
        'cycles': 'dimensionless',
        'g/d': 'dimensionless',
        'if': 'if',
        'kcal': 'kilocalorie',
        'lengths': 'dimensionless',
        'm': 'meter',
        'm/s': 'mps',
        'mm': 'millimeter',
        'ms': 'millisecond',
        'percent': 'percent',
        'rpm': 'rpm',
        's': 'second',
        'semicircles': 'semicircle',
        'strides': 'dimensionless',
        'strides/min': 'spm',
        'strokes/lap': 'dimensionless',
        'swim': 'dimensionless',
        'tss': 'dimensionless',
        'watts': 'watt'}
fieldmap = { 'Altitude': 'WeightedMeanElevation',
             'AvgAltitude': 'WeightedMeanElevation',
             'AvgBallSpeed': 'AvgBallSpeed',
             'AvgCadence': 'WeightedMeanCadence',
             'AvgCombinedPedalSmoothness': 'AvgCombinedPedalSmoothness',
             'AvgFractionalCadence': 'WeightedMeanFractionalCadence',
             'AvgGrade': 'AvgGrade',
             'AvgHeartRate': 'WeightedMeanHeartRate',
             'AvgLapTime': 'SumDuration',
             'AvgLeftPedalSmoothness': 'WeightedMeanLeftPedalSmoothness',
             'AvgLeftTorqueEffectiveness': 'WeightedMeanLeftTorqueEffectiveness',
             'AvgNegGrade': 'WeightedMeanNegGrade',
             'AvgNegVerticalSpeed': 'WeightedMeanNegVerticalSpeed',
             'AvgVerticalRatio' : 'WeightedMeanVerticalRatio',
             'AvgPosGrade': 'WeightedMeanPosGrade',
             'AvgPosVerticalSpeed': 'WeightedMeanPosVerticalSpeed',
             'AvgPower': 'WeightedMeanPower',
             'AvgRightPedalSmoothness': 'WeightedMeanRightPedalSmoothness',
             'AvgRightTorqueEffectiveness': 'WeightedMeanRightTorqueEffectiveness',
             'AvgRunningCadence': 'WeightedMeanRunCadence',
             'AvgSpeed': 'WeightedMeanSpeed',
             'AvgStanceTime': 'WeightedMeanStanceTime',
             'AvgStanceTimePercent': 'WeightedMeanStanceTimePercent',
             'AvgStrokeCount': 'WeightedMeanStrokes',
             'AvgStrokeDistance': 'WeightedMeanStrokeDistance',
             'AvgTemperature': 'WeightedMeanAirTemperature',
             'AvgVerticalOscillation': 'WeightedMeanVerticalOscillation',
             'BallSpeed': 'BallSpeed',
             'BestLapIndex': 'BestLapIndex',
             'Cadence': 'WeightedMeanCadence',
             'Cadence256': 'Cadence256',
             'Calories': 'Calories',
             'CombinedPedalSmoothness': 'CombinedPedalSmoothness',
             'CompressedAccumulatedPower': 'CompressedAccumulatedPower',
             'CycleLength': 'CycleLength',
             'Cycles': 'Cycles',
             'Distance': 'SumDistance',
             'EndPositionLat': 'EndPositionLat',
             'EndPositionLong': 'EndPositionLong',
             'EventGroup': 'EventGroup',
             'FirstLapIndex': 'FirstLapIndex',
             'FirstLengthIndex': 'FirstLengthIndex',
             'GpsAccuracy': 'GpsAccuracy',
             'Grade': 'Grade',
             'HeartRate': 'WeightedMeanHeartRate',
             'IntensityFactor': 'SumIntensityFactor',
             'LeftPedalSmoothness': 'LeftPedalSmoothness',
             'LeftTorqueEffectiveness': 'LeftTorqueEffectiveness',
             'MaxAltitude': 'MaxElevation',
             'MaxBallSpeed': 'MaxBallSpeed',
             'MaxCadence': 'MaxCadence',
             'MaxFractionalCadence': 'MaxFractionalCadence',
             'MaxHeartRate': 'MaxHeartRate',
             'MaxMeanGroundTime': 'MaxGroundContactTime',
             'MaxNegGrade': 'MaxNegGrade',
             'MaxNegVerticalSpeed': 'MaxNegVerticalSpeed',
             'MaxPosGrade': 'MaxPosGrade',
             'MaxPosVerticalSpeed': 'MaxPosVerticalSpeed',
             'MaxPower': 'MaxPower',
             'MaxRunningCadence': 'MaxRunCadence',
             'MaxSpeed': 'MaxSpeed',
             'MaxTemperature': 'MaxAirTemperature',
             'MinAltitude': 'MinElevation',
             'MinHeartRate': 'MinHeartRate',
             'NecLat': 'NecLat',
             'NecLong': 'NecLong',
             'NormalizedPower': 'WeightedMeanNormalizedPower',
             'NumActiveLengths': 'NumActiveLengths',
             'NumAvgSaturatedHemoglobinPercent': 'NumAvgSaturatedHemoglobinPercent',
             'NumAvgTotalHemoglobinConc': 'NumAvgTotalHemoglobinConc',
             'NumCompressedSpeedDistance': 'NumCompressedSpeedDistance',
             'NumLaps': 'NumLaps',
             'NumLengths': 'NumLengths',
             'NumMaxSaturatedHemoglobinPercent': 'NumMaxSaturatedHemoglobinPercent',
             'NumMaxTotalHemoglobinConc': 'NumMaxTotalHemoglobinConc',
             'NumMinSaturatedHemoglobinPercent': 'NumMinSaturatedHemoglobinPercent',
             'NumMinTotalHemoglobinConc': 'NumMinTotalHemoglobinConc',
             'NumSpeed1s': 'NumSpeed1s',
             'NumStrokeCount': 'NumStrokeCount',
             'NumTimeInCadenceZone': 'NumTimeInCadenceZone',
             'NumTimeInHrZone': 'NumTimeInHrZone',
             'NumTimeInPowerZone': 'NumTimeInPowerZone',
             'NumTimeInSpeedZone': 'NumTimeInSpeedZone',
             'NumZoneCount': 'NumZoneCount',
             'OpponentScore': 'OpponentScore',
             'PlayerScore': 'PlayerScore',
             'PoolLength': 'PoolLength',
             'PositionLat': 'PositionLat',
             'PositionLong': 'PositionLong',
             'Power': 'WeightedMeanPower',
             'RepetitionNum': 'RepetitionNum',
             'Resistance': 'Resistance',
             'RightPedalSmoothness': 'RightPedalSmoothness',
             'RightTorqueEffectiveness': 'RightTorqueEffectiveness',
             'SaturatedHemoglobinPercent': 'SaturatedHemoglobinPercent',
             'SaturatedHemoglobinPercentMax': 'SaturatedHemoglobinPercentMax',
             'SaturatedHemoglobinPercentMin': 'SaturatedHemoglobinPercentMin',
             'Speed': 'WeightedMeanSpeed',
             'Sport': 'ActivityType',
             'StanceTime': 'WeightedMeanGroundContactTime',
             'StanceTimePercent': 'StanceTimePercent',
             'StartPositionLat': 'StartPositionLat',
             'StartPositionLong': 'StartPositionLong',
             'StartTime': 'StartTime',
             'SubSport': 'ActivityTypeDetail',
             'SwcLat': 'SwcLat',
             'SwcLong': 'SwcLong',
             'Temperature': 'WeightedMeanAirTemperature',
             'Time128': 'Time128',
             'TimeFromCourse': 'TimeFromCourse',
             'Timestamp': 'Timestamp',
             'TotalAscent': 'GainElevation',
             'TotalCalories': 'SumEnergy',
             'TotalDescent': 'LossElevation',
             'TotalDistance': 'SumDistance',
             'TotalElapsedTime': 'SumDuration',
             'TotalFatCalories': 'TotalFatCalories',
             'TotalFractionalCycles': 'TotalFractionalCycles',
             'TotalHemoglobinConc': 'TotalHemoglobinConc',
             'TotalHemoglobinConcMax': 'TotalHemoglobinConcMax',
             'TotalHemoglobinConcMin': 'TotalHemoglobinConcMin',
             'TotalMovingTime': 'SumMovingDuration',
             'TotalTimerTime': 'SumElapsedDuration',
             'TotalTrainingEffect': 'SumTrainingEffect',
             'TrainingStressScore': 'SumTrainingStressScore',
             'VerticalOscillation': 'WeightedMeanVerticalOscillation',
             'VerticalSpeed': 'VerticalSpeed',
             'Zone': 'Zone',

             "developer_Cadence" :     "WeightedMeanCadence",
             "developer_Elevation" :     "GainElevation" ,
             "developer_Form Power" : "WeightedMeanFormPower" ,
             "developer_Ground Time" : "WeightedMeanGroundContactTime" ,
             "developer_Leg Spring Stiffness" : "WeightedMeanLegSpringStiffness" ,
             "developer_Power" : "WeightedMeanPower" ,
             "developer_Vertical Oscillation" :"WeightedMeanVerticalOscillation",

             'swc': 'swc',
             'total_cycles': 'total_cycles',
             'message_index': 'message_index',
             'avg_step_length': 'avg_step_length',
             'enhanced_max_speed': 'enhanced_max_speed',
             'event_type': 'event_type',
             'start_position': 'start_position',
             'avg_stance_time_balance': 'avg_stance_time_balance',
             }

limitfield = {
    'fit_record_mesg.m': {
        'Altitude': 'WeightedMeanElevation',
        'AvgCadence': 'AvgCadence',
        'AvgCombinedPedalSmoothness': 'AvgCombinedPedalSmoothness',
        'AvgFractionalCadence': 'AvgFractionalCadence',
        'AvgHeartRate': 'WeightedMeanHeartRate',
        'AvgLapTime': 'SumDuration',
        'AvgLeftPedalSmoothness': 'WeightedMeanLeftPedalSmoothness',
        'AvgLeftTorqueEffectiveness': 'WeightedMeanLeftTorqueEffectiveness',
        'AvgPower': 'WeightedMeanPower',
        'AvgRightPedalSmoothness': 'WeightedMeanRightPedalSmoothness',
        'AvgRightTorqueEffectiveness': 'WeightedMeanRightTorqueEffectiveness',
        'AvgRunningCadence': 'WeightedMeanRunCadence',
        'AvgSpeed': 'WeightedMeanSpeed',
        'AvgStrokeCount': 'WeightedMeanStrokes',
        'AvgStrokeDistance': 'WeightedMeanStrokeDistance',
        'AvgTemperature': 'WeightedMeanAirTemperature',
        'AvgVerticalOscillation': 'WeightedMeanVerticalOscillation',
        'Cadence': 'Cadence',
        'Distance': 'SumDistance',
        'HeartRate': 'WeightedMeanHeartRate',
        'IntensityFactor': 'SumIntensityFactor',
        'LeftPedalSmoothness': 'LeftPedalSmoothness',
        'LeftTorqueEffectiveness': 'LeftTorqueEffectiveness',
        'NumStrokeCount': 'NumStrokeCount',
        'PositionLat': 'PositionLat',
        'PositionLong': 'PositionLong',
        'Power': 'WeightedMeanPower',
        'Speed': 'WeightedMeanSpeed',
        'StartPositionLat': 'StartPositionLat',
        'StartPositionLong': 'StartPositionLong',
        'StartTime': 'StartTime',
        'Temperature': 'WeightedMeanAirTemperature',
        'Timestamp': 'Timestamp',
        'VerticalOscillation': 'WeightedMeanVerticalOscillation',
        'VerticalSpeed': 'VerticalSpeed',
        }
    }

def process_profile(fn):
    data = {}
    f = open( fn, 'r')
    of = open( 'defs.m', 'w' )

    watchfor = ['FIT_MANUFACTURER', 'FIT_GARMIN_PRODUCT', 'FIT_ANTPLUS_DEVICE_TYPE', 'FIT_DEVICE_TYPE' ]
    invalid = ['BITS_1_', 'BITS_0_', 'BITS_2_', 'INVALID', 'COUNT', 'ALL' ]

    enumname = None;
    for line in f:
        if enumname:
            if enumname+'_COUNT' in line:
                of.write( '}, //%s\n' %(enumname,) )
                enumname = None
            else:
                autovar = line.split( ' ' )[1]
                autovalue = autovar[len(enumname)+1:]
                autokey = autovalue.lower()
                autodisplay = autovalue.lower().replace( '_', ' ' ).title()
                of.write( '  @(%s):  @"%s",\n' %( autovar, autokey ) )
        else:
            start = False
            if line.startswith( 'typedef FIT_ENUM' ):
                start = True;
            else:
                for check in watchfor:
                    if line.startswith( 'typedef' ) and check in line:
                        start = True;

            if start:
                enumname = line.split(' ')[2]
                enumname = enumname.replace(';','').rstrip()
                data[enumname] = 1
                of.write( '@"%s": @{\n' %(enumname,) )
    return data

first_cap_re = re.compile('(.)([A-Z][a-z]+)')
all_cap_re = re.compile('([a-z0-9])([A-Z])')
def from_camel_case(name):
    if name.startswith( 'developer_' ):
        return name
    s1 = first_cap_re.sub(r'\1_\2', name)
    return all_cap_re.sub(r'\1_\2', s1).lower()

def process_fields(ofn):
    of = open( ofn, 'w' )

    for (fitfield,activityfield) in fieldmap.iteritems():
        if fitfield != activityfield:
            of.write( '@"%s":@"%s",\n' %(from_camel_case(fitfield),activityfield))

    of.write( '\n')
    for (fitfield,activityfield) in fieldmap.iteritems():
        if fitfield == activityfield:
            of.write( '@"%s":@"%s",\n' %(from_camel_case(fitfield),activityfield))


def process_mesg(ifn, ofn):
    f = open( ifn, 'r')
    of = open( ofn, 'w' )

    global units, umap, fields, fieldmap


    unit = None;
    for line in f:
        mUnit = re.search( '// Units: ([a-z%/]+)', line )
        mKnown = re.search( '(FIT_(SINT8|SINT32|DATE_TIME|FLOAT32|UINT8|UINT16)) Get(\w+)\(void\) const', line )
        mUnknown = re.search( '(FIT_([A-Z_]+)) Get(\w+)\(void\) const', line )
        mSet = re.search( 'void Set(\w+)\(FIT_([A-Z_]+) ',line)

        if mUnit:
            unit = mUnit.group(1)
            if unit in umap:
                unit = umap[unit]
            else:
                unit = 'dimensionless'
                units[unit] = 1
        elif mKnown:
            fct = mKnown.group(3)
            fname = fct
            if fct in fieldmap:
                fname = fieldmap[fct]
            else:
                fields[fct] = fct
            if not unit:
                unit = 'dimensionless'
            if( ofn in limitfield and fct not in limitfield[ofn] ):
                of.write( '//SKIP ' )
            of.write( 'FIT_GET_NUMUNIT_FIELD( @"%s", Get%s, %s_INVALID, @"%s" );' %(fname, fct, mKnown.group(1), unit ) )
            of.write( '\n')
            unit = None
        elif mUnknown:
            enum = mUnknown.group(1)
            if enum not in enums:
                of.write( '// Unknown: %s %s (unit: %s)' %(mUnknown.group(1), mUnknown.group(3),unit) )
            else:
                fct = mUnknown.group(3)
                fname = fct
                if fct in fieldmap:
                    fname = fieldmap[fct]
                else:
                    fields[fct] = fct
                of.write( 'FIT_GET_ENUM_FIELD( @"%s", Get%s, %s_INVALID, %s, @"%s" );' %(fname, fct, mUnknown.group(1), enum, enum ) )
            of.write( '\n')
            unit = None
        elif mSet:
            unit = None
    of.close()

def autogen_source( path, fname ):
    inf = open( '%s/%s' %(path, fname ), 'r' )
    ouf = open( fname, 'w' )

    skip_prev_autogen = False

    for line in inf:
        found_start = re.search( '/*Start AutoGenerated ([A-Za-z0-9_.]+)', line )
        found_end = re.search( '/*End AutoGenerated', line )
        if found_start:
            #print 'start %s' %(found_start.group(1),)
            ouf.write( line )
            auf = open( found_start.group(1), 'r' )
            indent = '        '
            for aul in auf:
                ouf.write( '%s%s' %(indent,aul) )
            auf = None
            skip_prev_autogen = True
        elif found_end:
            #print 'end'
            ouf.write( line )
            skip_prev_autogen = False
        else:
            if not skip_prev_autogen:
                ouf.write( line )
        
    print( 'Autogenerated new ./%s. Install: cp %s %s' %(fname, fname, path) )

units = {}
fields = {}
enums = {}

fitsdkpath = '../src/FitSDKRelease_20/'

enums = process_profile( fitsdkpath + 'fit_profile.hpp')

process_mesg( fitsdkpath + 'fit_record_mesg.hpp', 'fit_record_mesg.m' )
process_mesg( fitsdkpath + 'fit_session_mesg.hpp', 'fit_session_mesg.m' )
process_mesg( fitsdkpath + 'fit_length_mesg.hpp', 'fit_length_mesg.m' )
process_mesg( fitsdkpath + 'fit_activity_mesg.hpp', 'fit_activity_mesg.m' )
process_mesg( fitsdkpath + 'fit_file_id_mesg.hpp', 'fit_activity_mesg.m' )
process_mesg( fitsdkpath + 'fit_event_mesg.hpp', 'fit_event_mesg.m' )
process_mesg( fitsdkpath + 'fit_lap_mesg.hpp', 'fit_lap_mesg.m' )
process_mesg( fitsdkpath + 'fit_device_info_mesg.hpp', 'fit_device_info_mesg.m' )
process_fields( 'fit_fields.m' )
autogen_source( '../../FitFileExplorer/src/', 'FITFitFileDecode.mm' )
autogen_source( '../../FitFileExplorer/src/', 'FITFitEnumMap.mm' )


if units:
    print 'Encountered Unknown Units:'
    pprint.pprint( units)


