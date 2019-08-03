#!/usr/bin/python

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
    

connto = sqlite3.connect('fields.db')

def known_fields():
    sql = 'SELECT field FROM gc_fields_en GROUP BY field'
    rv = {}
    for row in connto.execute( sql ):
        rv[row[0]] = 1
    return rv

with open('fit_map.json', 'r' ) as of:
    existing = json.load( of )

known = known_fields()

for (msg,defs) in existing.iteritems():
    newdefs = defs.copy()
    for (key,val) in defs.iteritems():
        if key != val:
            continue
        checkval = val
        for (fit,cs) in [ ('total_', 'sum_'), ('avg_', 'weighted_mean_'), ]:
            if checkval.startswith( fit ):
                checkval = checkval.replace( fit,cs )
        candidate = to_camel_case( checkval )
        if candidate in known:
            newdefs[val] = candidate
    existing[msg] = newdefs

with open( 'fit_map.json', 'w' ) as outfile:
    json.dump( existing, outfile, indent = 2, sort_keys = True )
    
print( 'Saved fit_map.json' )
