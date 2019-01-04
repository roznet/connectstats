#!/usr/bin/python

import re
import subprocess
import argparse

import os



def check_diffs(args):
    if os.path.isdir( args.sdkpath ):
        print 'Checking {}'.format(args.sdkpath)

        files = os.listdir( args.output )
        for f in files:
            f_from=os.path.join( args.sdkpath, 'c/'+f )
            f_to=os.path.join( args.output, f )
            if os.path.isfile( f_from ) and os.path.isfile( f_to ):
                print 'ksdiff {} {}'.format( f_from, f_to )
                subprocess.call( [ 'ksdiff', '--partial-changeset',f_from, f_to ]  )
            else:
                print 'missing {} {}'.format( f_from, f_to )
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser( description='diff with sdk' )
    parser.add_argument( 'sdkpath' )
    parser.add_argument( '-o', '--output', default= 'sdk' )
    #parser.add_argument( '-i', '--inputfile', default = 'sdk/fit_example.h' )
    args = parser.parse_args()

    check_diffs( args )


