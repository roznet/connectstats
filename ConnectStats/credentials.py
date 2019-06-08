#!/usr/bin/python

import json

with open( 'credentials.json', 'r') as jsonfile:
    full = json.load( jsonfile );
    sample = dict()
    for service,one in full.iteritems():
        servicedict = dict()
        for key,val in one.iteritems():
            if key.endswith('_url' ) or key.endswith('_callback') or key.endswith('_param'):
                servicedict[key] = val
            else:
                servicedict[key] = "***"
        sample[service] = servicedict

with open( 'credentials.sample.json', 'w' ) as outfile:
    json.dump( sample, outfile, indent = 2, sort_keys=True );
