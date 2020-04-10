#!/usr/bin/env python3
#
#
#

import sqlite3
import argparse
import json
import os
import pprint
from collections import defaultdict

class ActivityType:
    def __init__(self,typeKey,typeId,parentId):
        self.key = typeKey
        self.typeId = typeId
        self.parentId = parentId
        self.display = dict()


    def add_display(self,language,display):
        self.display[language] = display
        
    def __repr__(self):
        return "ActivityType({},'{}',{})".format(self.typeId,self.key, pprint.pformat( self.display ) );


class ActivityTypes:
    def __init__(self):
        self.typesByKey = dict()
        self.typesById = dict()

    def load_modern_json(self,source):
        f = open(source, 'r')
        r = json.loads( f.read() )
        for item in r:
            typeKey = item[u'typeKey']
            parentTypeId = item[u'parentTypeId']
            typeId =item[u'typeId']
            self.typesByKey[typeKey] = ActivityType( typeKey, typeId, parentTypeId )
            self.typesById[typeId] = self.typesByKey[typeKey] 

    def remap_activityType(self,atype):
        remap = {
            "snowmobiling": "snowmobiling_ws",                     
            "snow_shoe": "snow_shoe_ws",												 
            "skating": "skating_ws",
            "backcountry_skiing_snowboarding": "backcountry_skiing_snowboarding_ws",
            "skate_skiing": "skate_skiing_ws",
            "cross_country_skiing": "cross_country_skiing_ws",
            "resort_skiing_snowboarding": "resort_skiing_snowboarding_ws",
        }
        if atype in remap:
            return remap[atype]
        else:
            return atype

    def add_language(self,source,language):
        f = open(source, 'r')
        r = json.loads( f.read() )
        for item in r['dictionary']:
            if 'key' in item:
                key = self.remap_activityType( item['key'] )
                display = item['display']
                self.typesByKey[key].add_display(language,display)
                

    def save_to_db(self,dbname, languages):
        conn = sqlite3.connect(dbname)
        conn.execute( 'DROP TABLE IF EXISTS gc_activityTypes' )

        languages_cols = ['`{}`'.format( x ) for x in languages]
        columns = ', '.join( ['{} TEXT'.format( x ) for x in languages_cols] )
        
        sql = 'CREATE TABLE gc_activityTypes (activityType TEXT, parentActivityType TEXT,activityTypeId INTEGER, parentActivityTypeId INTEGER, {})'.format( columns )
        conn.execute( sql )

        types = sorted(list( self.typesByKey.keys() ))
        sql='INSERT INTO gc_activityTypes (activityType,parentActivityType,activityTypeId,parentActivityTypeId,{}) VALUES (?,?,?,?,{})'.format( ','.join( languages_cols ), ','.join( ['?' for x in languages] ) )
        for key in types:
            type = self.typesByKey[key]
            parent = self.typesById[ type.parentId ].key if type.parentId in self.typesById else None
            
            vals = [key,parent
                    ,type.typeId,type.parentId]
            display = [type.display[x] if x in type.display else None for x in languages]
            vals.extend( display )
            if sum(1 for _ in filter( None.__ne__, display )) > 0:
                conn.execute( sql, vals )
        conn.commit()

                
    def __getitem__(self,arg):
        remap = self.remap_activityType(arg)
        if arg in self.typesByKey:
            return self.typesByKey[arg]
        elif remap in self.typesByKey:
            return self.typesByKey[remap]
        return None
    
class Field:
    def __init__(self, key):
        self.key = key
        self.fieldDisplayNameByLanguage = dict()
        self.unitByType = defaultdict(dict);


    def add_display(self, language, displayName, activityType = None ):
        if not language in self.fieldDisplayNameByLanguage:
            if displayName != self.key:
                self.fieldDisplayNameByLanguage[language] = displayName
        else:
            if displayName != self.key and displayName != self.fieldDisplayNameByLanguage[language]:
                print( 'Inconsistent name for {} in {} : {} and {}'.format(self.key, language, displayName, self.fieldDisplayNameByLanguage[language] ) )
                
    def add_uom(self, system, uom, activityType ):
        if not activityType in self.unitByType[system]:
            self.unitByType[system][activityType] = uom
        else:
            if uom != self.unitByType[system][activityType]:
                print( 'Inconsistent unit for {} in {} {} : {} and {}'.format(self.key, system, activityType, uom, self.unitByType[system][activityType] ) )

        if 'all' in self.unitByType[system]:
            to_remove = list([x for x in self.unitByType[system].keys() if x != 'all' and self.unitByType[system][x] == self.unitByType[system]['all'] ])
            for x in to_remove:
                del self.unitByType[system][x]

    def __repr__(self):
        return "Field('{}',{},{})".format(self.key, pprint.pformat( self.fieldDisplayNameByLanguage ), pprint.pformat( dict(self.unitByType) ));

class Fields:
    def __init__(self,types):
        self.fields = dict()
        self.activityTypes = types

    def add_db(self, db_from, language, unitsystem, table = 'gc_fields' ):
        conn = sqlite3.connect(db_from)
        cursor = conn.execute('select * from {}'.format(table))

        for row in cursor:
            (fieldKey, activityType, displayName, uom ) = row
            if self.activityTypes[fieldKey]:
                continue
            
            if fieldKey not in self.fields:
                self.fields[fieldKey] = Field(fieldKey)

            self.fields[fieldKey].add_display( language, displayName, activityType )
            self.fields[fieldKey].add_uom( unitsystem, uom, activityType )

    def save_to_db(self,dbname, languages, systems):
        conn = sqlite3.connect(dbname)
        conn.execute( 'DROP TABLE IF EXISTS gc_fields_display' )
        conn.execute( 'DROP TABLE IF EXISTS gc_fields_uom' )

        languages_cols = ['`{}`'.format( x ) for x in languages]
        columns = ', '.join( ['{} TEXT'.format( x ) for x in languages_cols] )
        
        sql = 'CREATE TABLE gc_fields_display (field TEXT, {})'.format( columns )
        conn.execute( sql )

        fields = sorted(list( self.fields.keys() ))
        sql='INSERT INTO gc_fields_display (field,{}) VALUES (?,{})'.format( ','.join( languages_cols ), ','.join( ['?' for x in languages] ) )
        for key in fields:
            field = self.fields[key]
            vals = [key]
            display = [field.fieldDisplayNameByLanguage[x] if x in field.fieldDisplayNameByLanguage else None for x in languages]
            vals.extend( display )
            if sum(1 for _ in filter( None.__ne__, display )) > 0:
                conn.execute( sql, vals )
        conn.commit()

        sql = 'CREATE TABLE gc_fields_uom (field TEXT,activityType TEXT,metric TEXT,statute TEXT)'
        conn.execute( sql )
        sql='INSERT INTO gc_fields_uom (field,activityType,metric,statute) VALUES (?,?,?,?)'


        metric_to_statue = dict()
        for key,field in self.fields.items():
            for t,u in field.unitByType['metric'].items():
                if t in field.unitByType['statute'] and u != field.unitByType['statute'][t]:
                    metric_to_statue[u] = field.unitByType['statute'][t]

        for key in fields:
            field = self.fields[key]
            units = defaultdict(dict)
            for s,one in field.unitByType.items():
                for t,u in one.items():
                    units[t][s] = u

            if len(units) == 1:
                vals = [key, 'all', units[t]['metric'], units[t]['statute'] if 'statute' in units[t] else None]
                conn.execute( sql, vals )
            else:
                for t in units:
                    vals = [key, t, units[t]['metric'], units[t]['statute'] if 'statute' in units[t] else None]
                    conn.execute( sql, vals )
        conn.commit()
        
class Driver :
    def __init__(self,args):
        self.args = args
        
    def cmd_build_legacy(self):
        types = ActivityTypes()
        types.load_modern_json( 'download/activity_types_modern.json' )

        fields = Fields(types)
        languages = [ 'en', 'fr', 'ja', 'de', 'it', 'es', 'pt', 'zh' ]

        for lang in languages:
            fields.add_db( 'cached/fields_{}_metric.db'.format( lang ), lang, 'metric' )
            types.add_language( 'cached/activity_types_{}.json'.format( lang ), lang )
        fields.add_db( 'edit/fields_en_power.db', 'en', 'metric', 'gc_fields_power' )
        fields.add_db( 'edit/fields_en_manual.db', 'en', 'metric', 'gc_fields_manual' )
        fields.add_db( 'cached/fields_en_statute.db', 'en', 'statute' )

        #pprint.pprint( list(fields.fields.keys() ) )
        #pprint.pprint( list(types.typesByKey ) ))
        #pprint.pprint( [types.typesByKey[x] for x in ['running', 'trail_running'] ] )
        #pprint.pprint( [fields.fields[x] for x in ['MinPace', 'WeightedMeanHeartRate', 'WeightedMeanPace', 'DirectVO2Max', 'MinHeartRate']] )

        fields.save_to_db('out/fields_new.db', languages, ['metric', 'statute'])
        types.save_to_db( 'out/fields_new.db', languages )

    def cmd_show(self):
        for fn in self.args.files:
            self.process_file( fn )

    def sqlite3_table_exists(self,conn,tablename):
        cursor = conn.execute( "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?", (tablename,) )
        return cursor.fetchone()[0] == 1
        
    def load_db(self,dbname):
        if os.path.exists( dbname ):
            conn = sqlite3.connect( dbname )
            if( self.sqlite3_table_exists( conn, 'gc_fields_display' ) ):
                print( '{} has gc_fields_display'.format( dbname ) )
            
        
    def process_file(self,fn):
        if os.path.exists( fn ):
            if fn.endswith( '.db' ) :
                self.load_db( fn )
            elif fn.endswith( '.json' ):
                self.load_json( fn )
        
        
if __name__ == "__main__":
                
    commands = {
        'show':{'attr':'cmd_show','help':'Show status of files'},
        'legacy':{'attr':'cmd_build_legacy','help':'Build from legacy files'},
        'add':{'attr':'cmd_add','help':'add information'},
    }
    
    description = "\n".join( [ '  {}: {}'.format( k,v['help'] ) for (k,v) in commands.items() ] )

    languages = [ 'en', 'fr', 'ja', 'de', 'it', 'es', 'pt', 'zh' ]
    what = ['activityType','unit','display']
    
    parser = argparse.ArgumentParser( description='Check configuration', formatter_class=argparse.RawTextHelpFormatter )
    parser.add_argument( 'command', metavar='Command', help='command to execute:\n' + description)
    parser.add_argument( '-s', '--save', action='store_true', help='save output otherwise just print' )
    parser.add_argument( '-o', '--output', help='output file' )
    parser.add_argument( '-v', '--verbose', action='store_true', help='verbose output' )
    parser.add_argument( '-w', '--what', help='list what to show or process, defaults to {}'.format( '+'.join(what)), default='+'.join(what))
    parser.add_argument( '-l', '--languages', help='list of languages to show or process. defaults to {}'.format( '+'.join( languages ) ) , default='+'.join(languages))
    parser.add_argument( 'files',    metavar='FILES', nargs='*', help='files to process' )
    args = parser.parse_args()

    command = Driver(args)

    if args.command in commands:
        getattr(command,commands[args.command]['attr'])()
    else:
        print( 'Invalid command "{}"'.format( args.command) )
        parser.print_help()
