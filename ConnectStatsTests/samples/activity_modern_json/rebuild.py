#!/usr/bin/env python3

from pprint import pprint
import argparse
import sys
import os
import json
import shutil

class TestCollector:
    def __init__(self,args):
        self.simdir = args.simdir
        self.args = args

    def find_last_json(self,midfix,inc=20,n=3):
        to_copy = []
        last = None
        last_fn = None

        index = 0
        maxindex = n * inc;

        total_activities = 0

        while index < inc*1000:
            fn = 'last_{}_search_{}.json'.format( midfix,index )
            from_fp = os.path.join( self.simdir, fn )
            to_fp = fn

            if os.path.isfile( from_fp ):
                last = fn
                if index < maxindex:
                    with open( from_fp ) as j_f:
                        data = json.load( j_f )
                    if 'activityList' in data:
                        n_activities = len(data['activityList'])
                    else:
                        n_activities = len(data)
                        
                    total_activities += n_activities
                    
                    print( 'cp {} [{} activities, total={}]'.format( fn, n_activities, total_activities ) )
                    with open( fn,'w' ) as j_o:
                        json.dump( data, j_o )
                    last_fn = 'last_{}_search_{}.json'.format( midfix,index +inc)

            index += inc

        if last:
            print( 'cp {} to {}'.format( last, last_fn ) )
            shutil.copyfile( os.path.join( self.simdir, last), last_fn )
            
    def find_details(self):
        fn = 'services_activities.json'
        info_fn = os.path.join( self.simdir, fn )
        shutil.copyfile( info_fn, fn )
        with open( fn, 'r' ) as info_fp:
            data = json.load( info_fp )

        cycling_id = sorted(data['types']['cycling'].keys())[0]
        running_id = sorted(data['types']['running'].keys())[0]
        
        cycling_ids = [ cycling_id] + list(data['duplicates'][cycling_id].keys() )
        running_ids = [ running_id] + list(data['duplicates'][running_id].keys() )

        in_dir = os.listdir( self.simdir )
        
        for cp_id in cycling_ids + running_ids:
            for f in in_dir:
                if cp_id in f or cp_id.replace('__connectstats__', '_cs_') in f or cp_id.replace('__strava__','') in f:
                    if f.endswith('.fit') or f.endswith('.json'):
                        print( 'cp {}'.format( f ) )
                        shutil.copyfile( os.path.join( self.simdir, f), f )
        
            
    def collect(self):
        self.find_details()

        self.find_last_json( 'modern', 20, 3 )
        self.find_last_json( 'connectstats', 20, 3 )
        self.find_last_json( 'strava', 1, 2 )


if __name__ == '__main__':
    parser = argparse.ArgumentParser( description='Query ConnectStats API', formatter_class=argparse.RawTextHelpFormatter )
    parser.add_argument( 'simdir' )
    parser.add_argument( '-c', '--config', help='config.php file to use to extract information', default = '../api/config.php' )
    parser.add_argument( '-t', '--token', help='Token id for the access Token Secret (0=no authentification)', default = 0 )
    parser.add_argument( '-v', '--verbose', help='verbose output', action='store_true' )
    args = parser.parse_args()
    
    collector = TestCollector(args)
    collector.collect()
