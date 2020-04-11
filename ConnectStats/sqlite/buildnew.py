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


def sqlite3_table_exists(conn,tablename):
    cursor = conn.execute( "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?", (tablename,) )
    return cursor.fetchone()[0] == 1

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
        self.verbose = False

    def load_modern_json(self,source):
        f = open(source, 'r')
        r = json.loads( f.read() )
        n = 0
        for item in r:
            typeKey = item[u'typeKey']
            parentTypeId = item[u'parentTypeId']
            typeId =item[u'typeId']
            self.typesByKey[typeKey] = ActivityType( typeKey, typeId, parentTypeId )
            self.typesById[typeId] = self.typesByKey[typeKey]
            n+=1

        if self.verbose:
            print( 'added {} activityTypes from {}'.format( n, source ) )

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
        n = 0
        for item in r['dictionary']:
            if 'key' in item:
                n+=1
                key = self.remap_activityType( item['key'] )
                display = item['display']
                self.typesByKey[key].add_display(language,display)
        if self.verbose:
            print( 'added {}/{} types display for {} from {}'.format( n, len(self.typesByKey), language, source ) )

    def save_to_db(self,dbname,languages):
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

    def save_to_dict(self):
        rv = {}
        for key in types:
            type = self.typesByKey[key]
            parent = self.typesById[ type.parentId ].key if type.parentId in self.typesById else None

            rv[ key ] = { 'activityType': key, 'parentActivityType': parent, 'activityTypeId':type.typeId, 'parentActivityTypeId':type.parentId }
            rv[ key ].update( type.display )
            
        return rv
                
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
        rv = False
        if language not in self.fieldDisplayNameByLanguage:
            if displayName != self.key:
                rv = True
                self.fieldDisplayNameByLanguage[language] = displayName
        else:
            if displayName != self.key and displayName != self.fieldDisplayNameByLanguage[language]:
                print( 'Inconsistent name for {} in {} : {} and {}'.format(self.key, language, displayName, self.fieldDisplayNameByLanguage[language] ) )
                
    def add_uom(self, system, uom, activityType ):
        rv = False
        if activityType not in self.unitByType[system]:
            self.unitByType[system][activityType] = uom
            rv = True
        else:
            if uom != self.unitByType[system][activityType]:
                print( 'Inconsistent unit for {} in {} {} : {} and {}'.format(self.key, system, activityType, uom, self.unitByType[system][activityType] ) )

        if 'all' in self.unitByType[system]:
            to_remove = list([x for x in self.unitByType[system].keys() if x != 'all' and self.unitByType[system][x] == self.unitByType[system]['all'] ])
            for x in to_remove:
                del self.unitByType[system][x]
        return rv

    def __repr__(self):
        return "Field('{}',{},{})".format(self.key, pprint.pformat( self.fieldDisplayNameByLanguage ), pprint.pformat( dict(self.unitByType) ));

class Fields:
    def __init__(self,types):
        self.fields = dict()
        self.activityTypes = types
        self.verbose = types.verbose

    def add_legacy_db(self, db_from, language, unitsystem, table = 'gc_fields' ):
        conn = sqlite3.connect(db_from)
        cursor = conn.execute('select * from {}'.format(table))
        
        n = {}
        n_new = {}
        
        for row in cursor:
            (fieldKey, activityType, displayName, uom ) = row
            if self.activityTypes[fieldKey]:
                continue
            
            if fieldKey not in self.fields:
                n_new[fieldKey] = 1
                self.fields[fieldKey] = Field(fieldKey)

            r1 = self.fields[fieldKey].add_display( language, displayName, activityType )
            r2 = self.fields[fieldKey].add_uom( unitsystem, uom, activityType )
            if r1 or r2:
                n[fieldKey] = 1

        if self.verbose:
            print( 'added {}/{} field display (new {}) for {} from {}'.format( len(n), len( self.fields ), len(n_new), language, db_from ) )
            
    def add_db(self,dbname):
        conn = sqlite3.connect(dbname)
        sql = 'SELECT * FROM gc_fields_display';
        res = conn.execute( sql )
        cols = res.description
        
        for row in res:
            fieldKey = row[0]
            if fieldKey:
                self.fields[ fieldKey ] = Field(fieldKey)
            for (idx,col) in enumerate(cols):
                if col != 'field':
                    self.fields[ fieldKey ].add_display( col,row[idx] )
            
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

    def fix_unit_system_missing(self):
        metric_to_statute = dict()
        # collect known conversions
        for key,field in self.fields.items():
            for t,u in field.unitByType['metric'].items():
                if t in field.unitByType['statute'] and u != field.unitByType['statute'][t]:
                    metric_to_statute[u] = field.unitByType['statute'][t]
                    
        for key,field in self.fields.items():
            for t,u in field.unitByType['metric'].items():
                n_u = None
                if u in metric_to_statute:
                    n_u = metric_to_statute[u]
                    if n_u == 'foot' and 'Elevation' not in key:
                        n_u = 'yard'
                if n_u:
                    if t not in field.unitByType['statute'] or 'statute' not in field.unitByType:
                        if self.verbose:
                            print( 'updating missing {}/{} to {} (from {})'.format( key, t, n_u, u) )
                        if 'statute' in field.unitByType:
                            field.unitByType['statute'][t] = n_u
                        else:
                            field.unitByType = {'statute': {t:n_u} }
                    if t in field.unitByType['statute'] and n_u != field.unitByType['statute'][t]:
                        if self.verbose:
                            print( 'fixing inconsistent {}/{} {} != {} (from {})'.format( key, t, field.unitByType['statute'][t], n_u, u) )
                        field.unitByType['statute'][t] = n_u

                if 'Elevation' in key and field.unitByType['metric'][t] != 'meter':
                    if self.verbose:
                        print( 'fixing elevation {}/{} {}/{} to {}/{}'.format( key, t, field.unitByType['metric'][t], field.unitByType['statute'][t] if t in field.unitByType['statute'] else None , 'meter', 'foot') )

                    field.unitByType['metric'][t] = 'meter'
                    if t in field.unitByType['statute']:
                        field.unitByType['statute'][t] = 'foot'
                    else:
                        field.unitByType['statue'] = {t:'foot'}
        
    def save_to_dict(self):
        rv = {}
        display = {}
        for key,field in self.fields.items():
            display[key] = field.fieldDisplayNameByLanguage
        uom = {}


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
        
            
        
class Driver :
    def __init__(self,args):
        self.args = args
        
    def init_legacy(self):
        self.types = ActivityTypes()
        self.types.verbose = self.args.verbose
        self.types.load_modern_json( 'download/activity_types_modern.json' )
        self.fields = Fields(self.types)
        
        self.languages = [ 'en', 'fr', 'ja', 'de', 'it', 'es', 'pt', 'zh' ]

        for lang in self.languages:
            self.fields.add_legacy_db( 'cached/fields_{}_metric.db'.format( lang ), lang, 'metric' )
            self.types.add_language( 'cached/activity_types_{}.json'.format( lang ), lang )
        self.fields.add_legacy_db( 'edit/fields_en_power.db', 'en', 'metric', 'gc_fields_power' )
        self.fields.add_legacy_db( 'edit/fields_en_manual.db', 'en', 'metric', 'gc_fields_manual' )
        self.fields.add_legacy_db( 'cached/fields_en_statute.db', 'en', 'statute' )
        self.fields.fix_unit_system_missing()


    def init_empty(self):
        self.types = ActivityTypes()
        self.types.verbose = self.args.verbose
        self.fields = Fields(types)
        
    def build(self):
        for fn in self.args.files:
            self.process_file( fn )

    def cmd_build(self):
        self.build()

        output = self.args.output
        if output.endswith( '.db' ):
            self.fields.save_to_db(self.args.output, self.languages, ['metric', 'statute'])
            self.types.save_to_db( self.args.output, self.languages )
        if output.endswith( '.json' ):
            a = self.fields.save_dict()
            b = self.types.save_dict( )
            print( a )
            

    def cmd_show(self):
        self.build()

        #pprint.pprint( sorted(list(self.fields.fields.keys() ) ))
        #pprint.pprint( sorted(list(self.types.typesByKey ) ) )
        #pprint.pprint( [types.typesByKey[x] for x in ['running', 'trail_running'] ] )
        #pprint.pprint( [fields.fields[x] for x in ['MinPace', 'WeightedMeanHeartRate', 'WeightedMeanPace', 'DirectVO2Max', 'MinHeartRate']] )


    def load_db(self,dbname):
        if os.path.exists( dbname ):
            conn = sqlite3.connect( dbname )
            if( sqlite3_table_exists( conn, 'gc_fields_display' ) ):
                self.fields.load_from_db(conn)
            
        
    def process_file(self,fn):
        if os.path.exists( fn ):
            if fn.endswith( '.db' ) :
                self.load_db( fn )
            elif fn.endswith( '.json' ):
                self.load_json( fn )
        
        
if __name__ == "__main__":
                
    commands = {
        'show':{'attr':'cmd_show','help':'Show status of files'},
        'build':{'attr':'cmd_build','help':'Rebuild database'},
    }

    init = {
        'legacy':{'attr':'init_legacy','help':'Build from legacy files'},
        'empty':{'attr':'init_empty','help':'Build empty base'},
        'latest':{'attr':'init_latest', 'help':'Build with latest file'},
    }
    
    description = "\n".join( [ '  {}: {}'.format( k,v['help'] ) for (k,v) in commands.items() ] )
    init_desc = "\n".join( [ '  {}: {}'.format( k,v['help'] ) for (k,v) in init.items() ] )

    languages = [ 'en', 'fr', 'ja', 'de', 'it', 'es', 'pt', 'zh' ]
    what = ['activityType','unit','display']
    
    parser = argparse.ArgumentParser( description='Check configuration', formatter_class=argparse.RawTextHelpFormatter )
    parser.add_argument( 'command', metavar='Command', help='command to execute:\n' + description)
    parser.add_argument( '-s', '--save', action='store_true', help='save output otherwise just print' )
    parser.add_argument( '-o', '--output', help='output file' )
    parser.add_argument( '-i', '--init', help='init method (default legacy)\n' + init_desc, default='legacy' )
    parser.add_argument( '-v', '--verbose', action='store_true', help='verbose output' )
    parser.add_argument( '-w', '--what', help='list what to show or process, defaults to {}'.format( '+'.join(what)), default='+'.join(what))
    parser.add_argument( '-l', '--languages', help='list of languages to show or process. defaults to {}'.format( '+'.join( languages ) ) , default='+'.join(languages))
    parser.add_argument( 'files',    metavar='FILES', nargs='*', help='files to process' )
    args = parser.parse_args()

    command = Driver(args)

    if args.init in init:
        getattr(command,init[args.init]['attr'])()
        if args.command in commands:
            getattr(command,commands[args.command]['attr'])()
        else:
            print( 'Invalid command "{}"'.format( args.command) )
            parser.print_help()
    else:
        print( 'Invalid init "{}"'.format( args.command) )
        parser.print_help()

        
        
