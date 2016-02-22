#!/bin/bash

STATE=OFF

if [ "$1" = "on" ]; then
    STATE=ON
    #sed -ie 's/^127.0.0.1.*$/& ADDing MORE TEXT TO THE END/g' config
    grep -F "ProxyCommand ssh gk nc cms-common-gui-1"  ~/.ssh/config | sed -ie 's/$/& ADDing SOME MORE TEXT AT THE END/g'
fi
echo $STATE 
