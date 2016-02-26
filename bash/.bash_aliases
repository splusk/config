## Variables
WHOAMI=<username>
APPS=/Users/$WHOAMI/Apps
WORK=/Users/$WHOAMI/Work
REPO=$WORK/repo
HG=$REPO/hg
JBOSS=$APPS/JBoss
DOCKER_SHARE=/Users/$WHOAMI/docker-share
CORE=$HG/core

#******************** START OF ALIAS ********************
# LS
alias ls='ls -FGH'
alias ll='ls -lh'
alias la='ll -A'
alias lr='ll -R'

# Commands
alias h=history
alias hi=history
alias vf=cd
alias xs=cd
alias m=less
alias ssh='ssh -XY -q 2> /dev/null'
alias d=dirs
alias pd=pushd
alias pd2='pushd +2'
alias po=popd
alias m=more
alias rm='rm -i'
alias mv='mv -i'
alias diff='diff -q'
alias clean='rm -f *~ .*~ dead.letter  *.swp'
alias ..='cd ..'

# Shortcuts
alias sbash='source ~/.bashrc'
alias work='cd $WORK'
alias repo='cd $REPO'
alias hgrepo='cd $HG'
alias core='cd $CORE'
alias jboss='cd $JBOSS'
alias devops='cd $WORK/Devops/Docker'
alias st='open -a SourceTree'
alias cr='export LC_ALL=en_US.UTF-8 && crucible.py'
alias drsc='docker rm $(docker ps -a -q)'
alias drni='docker rmi $(docker images -q --filter "dangling=true")'
alias python-server='python -m SimpleHTTPServer 9192'
remote-screen() {
    ssh -XYt $1 /users/$WHOAMI/bin/start-screen-session.sh $1
}
dsrc() {
    for i in `docker ps -a|grep -v "NAMES"|awk '{ print $NF }'`; do 
        echo "Stopping: "
        docker rm -f $i
    done
    echo "now deleting tangling images"
    drni
}
mvn() {
    echo alias mvn command executing
    command mvn -P '!build-custom-site-rpm,!build-custom-site-rpm-using-docker' -Dmaven.javadoc.skip=true $@
}
bigmvn() {
    echo Searching for pom
    DIR=`pwd`/
    while true; do
        if [ -e $DIR/pom.xml ];then
            mvn clean install -f $DIR/pom.xml -DskipITs -Dmaven.test.skip=true #-P '!build-custom-ui'
            break;
        else
            DIR=$DIR../
        fi
    done
}
## Master command
doit() {
    pushd . &> /dev/null
    CMD_TO_DO=$@
    if [[ "$CMD_TO_DO" == *"skipCore" ]]; then
        CORE=
        CMD_TO_DO=${CMD_TO_DO%skipCore*}
    fi
    for hgrepo in $REPOS
    do
        if [ ! -z "$hgrepo" ]; then
            cd $hgrepo
            uu=`echo $hgrepo | sed 's#.*/##'`
            echo
            echo "/********** $uu ***********/"
            $CMD_TO_DO
            rc=$?
            if [[ "$CMD_TO_DO" == "mvn"* ]]; then
                drni
                if [[ $rc != 0 ]]; then
                    echo
                    echo $uu failed; break $rc
                    echo
                fi
                echo
            fi
        fi
    done
    popd &> /dev/null
}
git_create_remote_repo() {
    USER=$1
    REPO_NAME=$2
    curl -u '$USER' https://api.github.com/user/repos -d '{"name":"$REPO_NAME"}'
    git remote add origin https://github.com/$USER/$REPO_NAME.git
    git push origin master
}
