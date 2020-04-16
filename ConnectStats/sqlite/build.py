#!/usr/bin/env python3
#
#
#

import sqlite3
import argparse
import json
import os
import pprint
import openpyxl
from collections import defaultdict


def sqlite3_table_exists(conn,tablename):
    cursor = conn.execute( "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?", (tablename,) )
    return cursor.fetchone()[0] == 1

class ActivityType:
    def from_modern_json(input):
        rv = ActivityType()
        rv.data = {
            'activityType' : input['typeKey'],
            'activityTypeId':input['typeId'],
            'parentActivityTypeId':input['parentTypeId'],
            }
        return rv

    def __getitem__(self,item):
        return self.data[item] if item in self.data else None

    def activityType(self):
        return self.data['activityType']
    
    def update_parent( self, parent ):
        self.data['parentActivityType'] = parent['activityType']
    
    def add_display(self,language,display):
        self.data[language] = display
        
    def display(self,language):
        rv = None
        if language in self.data:
            rv = self.data[language]
        elif language == 'en':
            rv = ' '.join( [x.capitalize() for x in  self.activityType().split( '_' ) ] )
        return rv

    def languages(self):
        return [key for key in self.data.keys() if len(key) == 2]
    
    def to_dict(self):
        return self.info
    
    def __repr__(self):
        return "ActivityType({},'{}',{})".format(self.data['activityType'],self.data['parentActivityType'] );


class ActivityTypes:
    def __init__(self):
        self.types = []
        self.verbose = False

        
    def read_from_modern_json(self,source):
        f = open(source, 'r')
        r = json.loads( f.read() )
        n = 0
        check = {}
        for item in r:
            at = ActivityType.from_modern_json(item)
            if at['activityType'] in check:
                print( 'Duplicate type {}'.format( at ) )
            check[at['activityType']] = at
            self.types.append( at )
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

    def update_parents(self):
        byTypeId = {}
        for one in self.types:
            byTypeId[one['activityTypeId']] = one
        for one in self.types:
            parentId = one['parentActivityTypeId']
            if parentId:
                one.update_parent( byTypeId[ parentId ] )
        
    def activityType(self,activityType):
        for one in self.types:
            if one['activityType'] == activityType:
                return one
        return None
                       
    def languages(self):
        rv = {}
        for one in self.types:
            rv.update( dict.fromkeys( one.languages() ) )
        return list(rv.keys())
                       
    def read_from_legacy_json(self,source,language):
        f = open(source, 'r')
        r = json.loads( f.read() )
        n = 0
        for item in r['dictionary']:
            if 'key' in item:
                n+=1
                key = self.remap_activityType( item['key'] )
                display = item['display']
                self.activityType(key).add_display(language,display)
        if self.verbose:
            print( 'added {}/{} types display for {} from {}'.format( n, len(self.types), language, source ) )
            
        self.update_parents()

        
    def save_to_db(self,dbname,languages):
        conn = sqlite3.connect(dbname)
        conn.execute( 'DROP TABLE IF EXISTS gc_activityTypes' )

        languages_cols = ['`{}`'.format( x ) for x in languages]
        columns = ', '.join( ['{} TEXT'.format( x ) for x in languages_cols] )
        
        sql = 'CREATE TABLE gc_activityTypes (activityType TEXT, parentActivityType TEXT,activityTypeId INTEGER, parentActivityTypeId INTEGER, {})'.format( columns )
        conn.execute( sql )

        types = sorted( self.types, key = lambda x: (x['parentActivityTypeId'],x['activityTypeId'] ) )

        sql='INSERT INTO gc_activityTypes (activityType,parentActivityType,activityTypeId,parentActivityTypeId,{}) VALUES (?,?,?,?,{})'.format( ','.join( languages_cols ), ','.join( ['?' for x in languages] ) )
        for type in types:
            vals = [type[x] for x in ['activityType','parentActivityType','activityTypeId','parentActivityTypeId']]
            display = [type.display(x) for x in languages]
            if sum(1 for _ in filter( None.__ne__, display )) > 0:
                vals.extend( display )
                conn.execute( sql, vals )
                conn.commit()
            else:
                if verbose:
                    print( 'MISSING: activityType {}/{} has no display'.format( key, type.typeId ) )

    def save_to_dict(self):
        return {'gc_activityTypes':self.types}
                
    def __getitem__(self,arg):
        remap = self.remap_activityType(arg)
        alt = None
        for one in self.types:
            if one.activityType() == arg:
                return one
            if one.activityType() == remap:
                alt = one
        return alt
    
class Field:
    def __init__(self, key):
        self.key = key
        self.fieldDisplayNameByLanguage = dict()
        self.unitByType = defaultdict(dict);
        self.category = 'ignore'
        self.display_order = -1

    def display_dicts(self):
        rv = {'field':self.key }
        rv.update( self.fieldDisplayNameByLanguage )
        return [ rv ]

    def uom_dicts(self):
        rv = []
        for t,units in self.unitByType.items():
            one = {'field':self.key,'activitytype':t}
            one.update(units)
            rv.append( one )
        return rv

    def order_dicts(self):
        rv = []
        rv.append( { 'field':self.key,'category':self.category,'display_order':self.display_order} )
        return rv

    
    def add_category(self,category):
        self.category = category

    def add_display_order(self,order):
        self.display_order = order

    def add_display(self, language, displayName, activityType = None ):
        rv = False
        if language not in self.fieldDisplayNameByLanguage:
            if displayName != self.key:
                rv = True
                self.fieldDisplayNameByLanguage[language] = displayName
        else:
            if displayName != self.key and displayName != self.fieldDisplayNameByLanguage[language]:
                rv = True
                self.fieldDisplayNameByLanguage[language] = displayName
        return rv
                
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

    def field(self,key):
        if key not in self.fields:
            self.fields[key] = Field(key)

        return self.fields[key]
        
    def read_from_legacy_db(self, db_from, language, unitsystem, table = 'gc_fields' ):
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
            
    def fix_legacy_unit_system_missing(self):
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

    def read_field_order_from_db(self,dbname):
        conn = sqlite3.connect(dbname)
        if sqlite3_table_exists( conn, 'gc_fields_order' ):
            sql = 'SELECT field,display_order,category,activityType FROM gc_fields_order';
            res = conn.execute( sql )
            self.fields_order = []
            for row in res:
                (field,display_order,category,activityType) = row
                self.fields_order.append( {'field':field,'display_order':display_order,'category':category,'activityType':activityType} )

    def save_field_order_to_db(self,dbname,categories=None ):
        conn = sqlite3.connect(dbname)
        conn.execute( 'DROP TABLE IF EXISTS gc_fields_order' )
        conn.execute('CREATE TABLE gc_fields_order (field TEXT, category TEXT, display_order REAL, activityType TEXT)' )
        ordered = sorted(self.fields_order, key=lambda x: (categories.categories[x['category']].display_order,x['display_order']) )
        for one in ordered:
            sql='INSERT INTO gc_fields_order (field,category,display_order,activityType) VALUES (?,?,?,?)'
            conn.execute( sql, (one['field'],one['category'],one['display_order'],one['activityType']) )
        conn.commit()
        
    def read_display_from_db(self,dbname):
        conn = sqlite3.connect(dbname)
        sql = 'SELECT * FROM gc_fields_display';
        res = conn.execute( sql )
        cols = res.description

        n = 0
        added = 0
        for row in res:
            fieldKey = row[0]
            if fieldKey:
                self.fields[ fieldKey ] = Field(fieldKey)
            for (idx,col) in enumerate(cols):
                if col != 'field' and row[idx] is not None:
                    n += 1
                    if self.fields[ fieldKey ].add_display( col,row[idx] ):
                        added += 1
                    
        if self.verbose:
            print( 'Added {}/{} display from {}'.format(added,n,dbname) )

    def read_uom_from_db(self,dbname):
        conn = sqlite3.connect(dbname)
        sql = 'SELECT * FROM gc_fields_uom';
        res = conn.execute( sql )
        cols = res.description

        if self.verbose:
            print( 'Adding uom from {}'.format(dbname) )
        
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
        
    def save_to_dict(self):
        display = {}
        for key,field in self.fields.items():
            display[key] = field.fieldDisplayNameByLanguage
            
        uom = {}
        for key in self.fields:
            field = self.fields[key]
            units = defaultdict(dict)
            for s,one in field.unitByType.items():
                for t,u in one.items():
                    units[t][s] = u

            if len(units) == 1:
                vals = [key, 'all', units[t]['metric'], units[t]['statute'] if 'statute' in units[t] else None]
                uom[ key ] = { 'all' : {'metric':units[t]['metric'], 'statute': units[t]['statute'] if 'statute' in units[t] else None } }
            else:
                uom[ key ] = {}
                for t in units:
                    uom[ key ][t] = {'metric':units[t]['metric'], 'statute': units[t]['statute'] if 'statute' in units[t] else None }
        
        return { 'gc_fields_uom': uom, 'gc_fields_display': display }

    def read_from_excel(self,wb):
        if 'gc_fields_display' in wb.sheetnames:
            ws = wb['gc_fields_display']
            cells = list(ws.values)
            cols = cells[0]
            values = [dict( zip(cols,x) ) for x in cells[1:]]
            values = [ {k:v for k,v in x.items() if v is not None} for x in values ]
            for x in values:
                field = x['field']
                for lang,val in x.items():
                    if x != 'field':
                        if self.field(field).add_display(lang,val):
                            print( 'changed {}[{}] = {}'.format( field,lang,val) )
        if 'gc_fields_uom' in wb.sheetnames:
            ws = wb['gc_fields_uom']
            cells = list(ws.values)
            cols = cells[0]
            values = [dict( zip(cols,x) ) for x in cells[1:]]
            values = [ {k:v for k,v in x.items() if v is not None} for x in values ]
            for x in values:
                field = x['field']
                for lang,val in x.items():
                    if x != 'field':
                        if self.field(field).add_display(lang,val):
                            print( 'changed {}[{}] = {}'.format( field,lang,val) )
    
    def save_to_excel(self,wb):
        ws = wb.create_sheet('gc_fields_display')
        wb.remove(wb['Sheet'])
        fields = self.save_to_dict()
        languages = defaultdict(int)
        for key,val in fields['gc_fields_display'].items():
            for l in val.keys():
                languages[l] += 1
        cols = ['field']
        cols.extend( sorted(list(languages.keys()), key=lambda x: languages[x], reverse=True) )
        row = 1
        for i in range(len(cols)):
            ws.cell(row=row,column=(i+1),value=cols[i] )
        row = 2
        keys = sorted( fields['gc_fields_display'].keys() )
        for key in keys:
            vals = fields['gc_fields_display'][key]
            if( len(vals )> 0):
                for i in range(len(cols)):
                    if i == 0:
                        ws.cell(row=row,column=(i+1),value=key )
                    if cols[i] in vals:
                        ws.cell(row=row,column=(i+1),value=vals[cols[i]] )
                row += 1
        

class Category :
    def __init__(self,name,display_order,display_name):
        self.name = name
        self.display_order = display_order
        self.display_name = display_name

    def save_to_dict(self):
        return {'name':self.name,'display_order':self.display_order,'display_name':self.display_name}

class Categories :
    def __init__(self):
        self.categories = {}

    def add_category(self,category):
        self.categories[ category.name ] = category

    def read_from_db(self,dbname):
        conn = sqlite3.connect(dbname)
        if sqlite3_table_exists( conn, 'gc_category_order' ):
            cursor = conn.execute('SELECT category,display_order,displayName FROM gc_category_order' )
            for row in cursor:
                cat = Category(row[0],row[1],row[2])
                self.add_category( cat )
        
    def save_to_db(self,dbname):
        conn = sqlite3.connect(dbname)
        conn.execute( 'DROP TABLE IF EXISTS gc_category_order' )
        conn.execute('CREATE TABLE gc_category_order (category TEXT, display_order REAL, displayName TEXT)' )

        ordered = sorted(self.categories.keys(), key=lambda x: self.categories[x].display_order )
        for key in ordered:
            sql='INSERT INTO gc_category_order (category,display_order,displayName) VALUES (?,?,?)'
            cat = self.categories[ key ]
            conn.execute( sql, (cat.name,cat.display_order,cat.display_name) )
        conn.commit()

    def save_to_dict(self):
        rv = []
        ordered = sorted(self.categories.keys(), key=lambda x: self.categories[x].display_order )
        for key in ordered:
            rv.append( self.categories[ key ].save_to_dict() )
        return {'gc_category_order':rv}
    
class Driver :
    def __init__(self,args):
        self.args = args
        
    def init_legacy(self):

        self.types = ActivityTypes()
        self.types.verbose = self.args.verbose
        self.types.read_from_modern_json( 'download/activity_types_modern.json' )
        self.fields = Fields(self.types)
        
        self.languages = [ 'en', 'fr', 'ja', 'de', 'it', 'es', 'pt', 'zh' ]

        for lang in self.languages:
            self.fields.read_from_legacy_db( 'cached/fields_{}_metric.db'.format( lang ), lang, 'metric' )
            self.types.read_from_legacy_json( 'cached/activity_types_{}.json'.format( lang ), lang )
        self.fields.read_from_legacy_db( 'cached/fields_en_statute.db', 'en', 'statute' )
        self.fields.read_from_excel(openpyxl.load_workbook(filename='edit/gc_fields_manual.xlsx'))
        self.fields.fix_legacy_unit_system_missing()

        self.categories = Categories()
        self.categories.read_from_db( 'edit/fields_order.db' )
        self.fields.read_field_order_from_db( 'edit/fields_order.db' )

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
            self.categories.save_to_db(self.args.output )
            self.fields.save_field_order_to_db(self.args.output,self.categories)
        if output.endswith( '.json' ):
            f = self.fields.save_to_dict()
            a = self.types.save_to_dict( )
            f.update( a )
            with open(output, 'w') as of:
                json.dump(f, of, indent=2, sort_keys=True)
        if output.endswith( '.xlsx' ):
            wb = openpyxl.Workbook()
            self.fields.save_to_excel(wb)
            wb.save( output )
            

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
                self.fields.load_display_from_db(conn)
            if( sqlite3_table_exists( conn, 'gc_fields_uom' ) ):
                self.fields.load_uom_from_db(conn)

    def load_excel(self,xlname):
        if os.path.exists( xlname ):
            wb = openpyxl.load_workbook(filename=xlname)
            self.fields.read_from_excel(wb)
        
    def process_file(self,fn):
        if os.path.exists( fn ):
            if fn.endswith( '.db' ) :
                self.load_db( fn )
            elif fn.endswith( '.json' ):
                self.load_json( fn )
            elif fn.endswith( '.xlsx' ):
                self.load_excel( fn )
                
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

        
        
