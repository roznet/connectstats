#!/bin/sh
a=$1
[[ -z $a ]] && a='ConnectStats.app'
f=`find ~/Library -name $a -print | grep "iPhone Simulator"`;
echo "$f"
#cd "$f"
