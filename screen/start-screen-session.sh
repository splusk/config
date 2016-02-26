#!/bin/bash
## Add this to your remote server that your will run screen on.
## Then when you ssh to your screen session from your windows/mac machine
## Run this script to hook into your screen session and get proper X11 support
## For example from your windows machine:
## ssh -XYt <remote-server> /users/splusk/bin/start-screen-session.sh <remote-server>
## Which will execute the code below

. ~/.bashrc
#screen_pushenv
#ssh <remote-server> 'bash -s' < /users/splusk/bin/screen-sendenv.py DISPLAY
if [ ! -z $1 ]; then
    screen -S $1 -X setenv DISPLAY $DISPLAY
    screen -D -R $1 
else
    screen -S $HOSTNAME
fi
