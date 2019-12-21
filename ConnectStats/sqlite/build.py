#!/usr/bin/env python3
#
#
#

import sqlite3
import json
connto = sqlite3.connect('out/fields.db')


def fieldflags():
    d = {
    'gcFieldFlagNone':                      0,
    'gcFieldFlagSumDistance':               1,
    'gcFieldFlagSumDuration':               1 << 1,
    'gcFieldFlagWeightedMeanHeartRate':     1 << 2,
    'gcFieldFlagWeightedMeanSpeed':         1 << 3,
    'gcFieldFlagCadence':                   1 << 4,
    'gcFieldFlagAltitudeMeters':            1 << 5,
    'gcFieldFlagPower':                     1 << 6,
    'gcFieldFlagSumStrokes':                1 << 7,
    'gcFieldFlagSumSwolf':                  1 << 8,
    'gcFieldFlagSumEfficiency':             1 << 9,
    'gcFieldFlagVerticalOscillation':       1 << 10,
    'gcFieldFlagGroundContactTime':         1 << 11,
    'gcFieldFlagTennisShots':               1 << 12,
    'gcFieldFlagTennisRegularity':          1 << 13,
    'gcFieldFlagTennisEnergy':              1 << 14,
    'gcFieldFlagTennisPower':               1 << 15
    }


def activitytype_modern(source,table_to):
    connto.execute('DROP TABLE IF EXISTS %s' %(table_to,))
    connto.execute('CREATE TABLE %s (activityTypeDetail TEXT,activityTypeId INTEGER, parentActivityTypeId INTEGER)' %(table_to,))
    f = open(source, 'r')
    r = json.loads( f.read() )
    for item in r:
        typeKey = item[u'typeKey']
        parentTypeId = item[u'parentTypeId']
        typeId =item[u'typeId']
        sql = 'INSERT INTO %s (activityTypeDetail,activityTypeId,parentActivityTypeId) VALUES (?,?,?)' %(table_to,)
        connto.execute(sql, (typeKey,typeId,parentTypeId))
    connto.commit()

def activitytype(source,table_to):
    connto.execute('DROP TABLE IF EXISTS %s' %(table_to,))
    connto.execute('CREATE TABLE %s (activityType text,activityTypeDetail text,display text)' %(table_to,))
    f = open(source, 'r')
    r = json.loads( f.read() )
    for item in r['dictionary']:
        if 'parent' in item:
            parent =  remap_activityType( item[u'parent'][u'key'] )
            key= remap_activityType( item[u'key'] )

            display = item[u'display']
            sql='INSERT INTO %s (activityType,activityTypeDetail,display) VALUES (?,?,?)' %(table_to,)
            connto.execute( sql, (parent,key,display) )
    connto.commit()

def uom(db_from,table_to):
    connto.execute('DROP TABLE IF EXISTS %s' %(table_to,))
    connto.execute('CREATE TABLE %s (field text,activityType text,uom text)' %(table_to,))
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select * from gc_fields')
    for row in cursor:
        sql='INSERT INTO %s (field,activityType,uom) VALUES (?,?,?)' %(table_to,)
        connto.execute( sql, (row[0],remap_activityType( row[1] ),row[3]) )

    connto.commit()

def language(db_from,table_to):
    connto.execute('DROP TABLE IF EXISTS %s' %(table_to,))
    connto.execute('CREATE TABLE %s (field text,activityType text,fieldDisplayName text)' %(table_to,))
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select * from gc_fields')
    for row in cursor:
        sql = 'SELECT * FROM %s WHERE field=? AND activityType=?' %(table_to,)
        r = connto.execute( sql, (row[0], row[1] ) ) 
        if not r.fetchone():
            sql='INSERT INTO %s (field,activityType,fieldDisplayName) VALUES (?,?,?)' %(table_to,)
            if(row[0]!=row[2]):
                connto.execute( sql, (row[0],remap_activityType( row[1] ),row[2]) )

    connto.commit()

def addextra(db_from,table_to,table_from):
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select * from %s' %(table_from,) )
    for row in cursor:
        sql = 'SELECT * FROM %s WHERE field=? AND activityType=?' %(table_to,)
        r = connto.execute( sql, (row[0], row[1] ) )
        if not r.fetchone():
            sql='INSERT INTO %s (field,activityType,fieldDisplayName) VALUES (?,?,?)' %(table_to,)
            connto.execute( sql, (row[0],remap_activityType( row[1] ),row[2]) )
    connto.commit()
def addextrauom(db_from,table_to,table_from):
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select * from %s' %(table_from,))
    for row in cursor:
        sql = 'SELECT * FROM %s WHERE field=? AND activityType=?' %(table_to,)
        r = connto.execute( sql, (row[0],row[1] ) )
        if not r.fetchone():
            sql='INSERT INTO %s (field,activityType,uom) VALUES (?,?,?)' %(table_to,)
            connto.execute( sql, (row[0],row[1],row[3]) )
    connto.commit()

def addday(db_from,table_to):
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select * from gc_fields_day_metric')
    for row in cursor:
        sql = 'SELECT * FROM %s WHERE field=? AND activityType=?' %(table_to,)
        r = connto.execute( sql, (row[0],row[1] ) )
        if not r.fetchone():
            sql='INSERT INTO %s (field,activityType,fieldDisplayName) VALUES (?,?,?)' %(table_to,)
            connto.execute( sql, (row[0],row[1],row[2]) )
    connto.commit()
def adddayuom(db_from,table_to):
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select * from gc_fields_day_metric')
    for row in cursor:
        sql = 'SELECT * FROM %s WHERE field=? AND activityType=?' %(table_to,)
        r = connto.execute( sql, (row[0],row[1] ) )
        if not r.fetchone():
            sql='INSERT INTO %s (field,activityType,uom) VALUES (?,?,?)' %(table_to,)
            connto.execute( sql, (row[0],row[1],row[3]) )
    connto.commit()

def fieldorder(db_from,table):
    connto.execute('DROP TABLE IF EXISTS %s' %(table,))
    connto.execute('CREATE TABLE %s (field TEXT, category TEXT, display_order REAL, activityType TEXT)' %(table,))
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select field,category,display_order,activityType from %s' %(table,))
    for row in cursor:
        sql='INSERT INTO %s (field,category,display_order,activityType) VALUES (?,?,?,?)' %(table,)
        connto.execute( sql, (row[0],row[1],row[2],row[3]) )
    connto.commit()

def categoryorder(db_from,table):
    connto.execute('DROP TABLE IF EXISTS %s' %(table,))
    connto.execute('CREATE TABLE %s (category TEXT, display_order REAL, displayName TEXT)' %(table,))
    conn = sqlite3.connect(db_from)
    cursor = conn.execute('select category,display_order,displayName from %s' %(table,))
    for row in cursor:
        sql='INSERT INTO %s (category,display_order,displayName) VALUES (?,?,?)' %(table,)
        connto.execute( sql, (row[0],row[1],row[2]) )
    connto.commit()

def remap_activityType(atype):
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
    

# Build int fields.db:
# Will add specific from the language+ what is in english power and manual
# To add new fields, just add them manually to fields_en_manual
for lang in [ 'en', 'fr', 'ja', 'de', 'it', 'es', 'pt', 'zh' ] :
    language( 'cached/fields_%s_metric.db' %(lang,) , 'gc_fields_'+lang )
    addextra('edit/fields_en_power.db', 'gc_fields_' + lang, 'gc_fields_power')
    addextra('edit/fields_en_manual.db', 'gc_fields_' + lang, 'gc_fields_manual')
    activitytype( 'cached/activity_types_%s.json' %( lang, ), 'gc_activityType_' + lang );

activitytype_modern( 'download/activity_types_modern.json', 'gc_activityType_modern' )
#####
# Add Defaults metric and statute uom
uom('cached/fields_en_metric.db','gc_fields_uom_metric')
uom('cached/fields_en_statute.db','gc_fields_uom_statute')

#####
# Add Uom for power fields
addextrauom('edit/fields_en_power.db', 'gc_fields_uom_metric', 'gc_fields_power')
addextrauom('edit/fields_en_power.db', 'gc_fields_uom_statute','gc_fields_power')

#####
# add days field from fields_en_day.db
# to recreate the db, edit fields_en_day.sql
addday('cached/fields_en_day.db', 'gc_fields_en')
adddayuom('cached/fields_en_day.db', 'gc_fields_uom_metric')

#####
# Add Field Order and Category order
# To add new fields, edit fields_order.db
fieldorder('edit/fields_order.db','fields_order')
categoryorder('edit/fields_order.db','category_order')

fieldflags()
