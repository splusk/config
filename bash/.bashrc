#
# user .profile file

#PS1='\h:\w\$ '

# Usage:  Copy this file to a user's home directory and edit it to
# customize it to taste.  It is run by bash each time it starts up.

# These lines are in ~/.profile instead
#TERM=xterm-256color
##export TERM
#
## Source
#case "z$PROFILE" in
#    z)  #echo sourcing profile ;
#        . ~/.profile ;;
#    z*) #echo "profile already sourced"
#        ;;
#esac

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

case $TERM in
    xterm*)
    #Red - 31, Green - 32, Yellow -33, Blue - 34, Purple -35, Lite Blue -36, White - 37
        PS1='\[\e[0;32m\]\h:\[\e[0;33m\] \w\[\e[0;0m\]> '
            ;;
    *)
        PS1='\[\e[0;31m\]\h:\[\e[0;32m\] \w\[\e[0;0m\]> '
            ;;
esac
PROMPT_COMMAND='echo -ne "\033]0;${PWD##*/}\007"'

# Set up bash environment:
if [ $?prompt ]; then		# shell is interactive.
    history=500		# previous commands to remember.
    savehist=400		# number to save across sessions.
    system=`hostname`	# name of this system.
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Personal (temporary) umask
#umask 022
# Normal umask
umask 002

#eval $(docker-machine env dev)
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/shane.kakau/.docker/machine/machines/dev"
export DOCKER_MACHINE_NAME="dev"

## PATHS
setjdk() {
    export JAVA_HOME=$(/usr/libexec/java_home -v $1)
}
export M2_HOME=/usr/local/apache-maven/apache-maven-3.3.3
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=$PATH:$M2_HOME/bin
