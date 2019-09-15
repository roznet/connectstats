#!/usr/bin/python

import sys
import os
import shutil


a=[
'backcountry_skiing_snowboarding.imageset',
'cross_country_skiing.imageset',
'cycling-bw.imageset',
'cycling.imageset',
'fitness_equipment.imageset',
'hiking-bw.imageset',
'hiking.imageset',
'indoor_rowing.imageset',
'multi_sport.imageset',
'other.imageset',
'resort_skiing_snowboarding.imageset',
'rowing.imageset',
'running.imageset',
'swimming.imageset',
'tennis.imageset',
'transition.imageset',
'walking.imageset',
]

content = '''{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "%s.png",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "filename" : "%s@2x.png",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "filename" : "%s@3x.png",
      "scale" : "3x"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}'''


dup = {

                 'walking' : 'hiking',
                 'indoor_rowing' : 'rowing',
                 'cross_country_skiing' : 'backcountry_skiing_snowboarding'
}

doit = True
for i in a:
                 name = i.replace( '.imageset', '' )
                 found = os.path.expanduser(  '~/Desktop/CSicons/{}.png'.format( name ) )
                 srcname = name
                 ok = False
		 if( os.path.isfile( found ) ):
                                  ok = True
                                  doit=False
		 elif name in dup:
                                  found = os.path.expanduser(  '~/Desktop/CSicons/{}.png'.format( dup[name] ) )
		                  if( os.path.isfile( found ) ):
                                                   srcname = dup[name]
                                                   doit=True
                                                   ok = True

                 if not ok:
		                  print( 'MISSING {}'.format( name ) )
		 else:
                                  print( 'OK: {} {}'.format( name, found ) )

                 if not doit:
                                  continue
                 dynname = '{}-dyn'.format( name )
                 path='{}.imageset'.format( dynname )
                 print( 'mkdir {}'.format( path ) )
                 if doit:
                                  if not os.path.isdir( path ):
                                                   os.mkdir( path )
                                                   
                 for scale in [ '', '@2x', '@3x' ]:
                                  pngname='{}{}.png'.format( dynname, scale )
                                  src = os.path.expanduser(  '~/Desktop/CSicons/{}{}.png'.format( srcname, scale ) )
                                  dst = '{}/{}'.format( path, pngname )
                                  print( 'cp {} {}'.format( src, dst ) )

                                  if doit:
                                                   shutil.copyfile( src, dst )

                 contname = '{}/Contents.json'.format( path );
                 print( 'create {}'.format( contname ))
                 json = content % ( dynname, dynname, dynname )

                 if doit:
                                  with open( contname, 'w' ) as cf:
                                                           cf.write( json )
                                                                    

                                  
                        


                 
