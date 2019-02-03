#!/usr/bin/python

# download latest fit sdk
# run utility agasint that directory
#     ./diffsdk.py /path/to/FitSDKRElease_20.XX.00
# check the files it suggest to copy and copy them
# check the diff in the files it didn't copy for any thing to adjust manually

import re
import subprocess
import argparse
import hashlib
import os

def file_hash(filepath):
    openedFile = open(filepath)
    readFile = openedFile.read()

    hash = hashlib.sha1(readFile)

    return hash.hexdigest()

def update_version(fn_from,fn_to):
    patterns = {
        'copyright' : re.compile( '// Copyright ([0-9]+) Garmin Canada' ),
        'profile'   : re.compile( '// Profile Version = ([0-9]+)' ),
        'tag'       : re.compile( '// Tag = production/' )
        }

    values = {
        }
    f_i = open(fn_from, 'r')

    for line in f_i:
        if line.startswith( '//' ):
            for k,v in patterns.iteritems():
                if v.match( line ):
                    values[k] = line

    fn_to_w = fn_to + '~'
                    
    f_o = open(fn_to, 'r')
    f_o_w = open( fn_to_w, 'w')

    changed = False
    
    for line in f_o:
        wrote = False
        if line.startswith( '//' ):
            for k,v in patterns.iteritems():
                if k in values:
                    if v.match( line ):
                        if values[k] != line:
                            changed = True
                        f_o_w.write(values[k])
                        wrote = True
        if not wrote:
            f_o_w.write(line)

    if changed:

        fn_to_tmp = fn_to_w + '~TMP'
        if os.path.exists( fn_to_tmp ):
            os.remove( fn_to_tmp )

        print 'Changed {} to {}'.format( fn_to, fn_to_w )
        os.rename( fn_to, fn_to_tmp )
        os.rename( fn_to_w, fn_to )
        os.rename( fn_to_tmp, fn_to_w )
        
        



def check_diffs(args):
    if os.path.isdir( args.sdkpath ):
        print 'Checking {}'.format(args.sdkpath)

        skip = ['fit_config.h', 'fit_convert.h', 'fit_convert.c']
        files = os.listdir( args.output )
        for f in files:
            if f.endswith( '~' ):
                continue
            f_from=os.path.join( args.sdkpath, 'c/'+f )
            f_to=os.path.join( args.output, f )
            if os.path.isfile( f_from ) and os.path.isfile( f_to ):
                if file_hash(f_from) != file_hash( f_to ):
                    update_version(f_from, f_to )
                if file_hash(f_from) != file_hash( f_to ):
                    if f not in skip:
                        print 'cp {} {}'.format( f_from, f_to )
                    subprocess.call( [ 'ksdiff', '--partial-changeset',f_from, f_to ]  )
                    
            else:
                print 'missing {} {}'.format( f_from, f_to )
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser( description='diff with sdk' )
    parser.add_argument( 'sdkpath' )
    parser.add_argument( '-u', '--update', action='store_true' )
    parser.add_argument( '-o', '--output', default='sdk' )
    args = parser.parse_args()

    check_diffs( args )


