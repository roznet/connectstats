#!/bin/bash

#versions
#1.9
#archive="2013-04-14/GarminConnect 04-14-2013 23.38"
#1.9.1 
#archive="2013-04-18/GarminConnect 04-14-2018 22.28"
#1.10
#archive="2013-06-30/GarminConnect 30-06-2013 09.28"
#1.10.1
#archive="2013-07-08/GarminConnect 08-07-2013 20.46"
#1.13
archive="2013-09-22/GarminConnect 22-09-2013 10.43"
#1.14
#archive="2013-11-10/GarminConnect 10-11-2013 11.07"

crashfile=`pwd`/app.crash
crashout=`pwd`/crash.txt
echo $crashfile
~/Development/xcode/shared/PLCrashReporter/Tools/plcrashutil convert --format=ios $1  > $crashfile
#xcode4.5: sympath=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/PrivateFrameworks/DTDeviceKit.framework/Versions/A/Resources
#xcode5:
sympath=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/PrivateFrameworks/DTDeviceKitBase.framework/Versions/A/Resources

export DEVELOPER_DIR=/Applications/XCode.app/Contents/Developer


DYSYM=/Users/brice/Library/Developer/Xcode/Archives/${archive}.xcarchive/dSYMs/ConnectStats.app.dSYM/Contents/Resources/DWARF
DYSYM=/Users/brice/Library/Developer/Xcode/Archives/${archive}.xcarchive/dSYMs
APPS=/Users/brice/Library/Developer/Xcode/Archives/${archive}.xcarchive/Products/Applications
sympath=/Users/brice/bin
$sympath/symbolicatecrash   $crashfile "$DYSYM" "$APPS"> $crashout
ls -l $crashout
head $crashout


