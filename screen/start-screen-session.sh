#!/bin/bash
. ~/.bashrc
#screen_pushenv
#ssh gottrhel7ca 'bash -s' < /users/shane/bin/screen-sendenv.py DISPLAY
if [ ! -z $1 ]; then
    screen -S $1 -X setenv DISPLAY $DISPLAY
    screen -D -R $1 
else
    screen -S $HOSTNAME
fi
