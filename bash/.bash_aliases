## Variables
APPS=/Users/shane.kakau/Apps
WORK=/Users/shane.kakau/Work
REPO=$WORK/repo
HG=$REPO/hg
JBOSS=$APPS/JBoss
DOCKER_SHARE=/Users/shane.kakau/docker-share
CORE=$HG/crewplace
CUSTOM_PROFILES=$HG/custom-profiles
CUSTOM_CREWPLACE=$HG/custom-crewplace
ACME_CREWPLACE=$HG/acme-crewplace
GC_CREWPLACE=$HG/gc-crewplace

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
alias acme='cd $ACME_CREWPLACE'
alias crewbid='cd $ACME_CREWPLACE/sites/crewbid'
alias gc='cd $GC_CREWPLACE'
alias bid6='cd $REPO/bid6'
alias provider='cd $HG/crewplace.provider'
alias jboss='cd $JBOSS'
alias academy='cd $WORK/Academy'
alias devops='cd $WORK/Devops/Docker'
alias st='open -a SourceTree'
alias prima='javaws http://primavera-prod.jeppesen.com/pr/timesheet.jnlp 2>/dev/null'
alias cr='export LC_ALL=en_US.UTF-8 && crucible.py'
alias drsc='docker rm $(docker ps -a -q)'
alias drni='docker rmi $(docker images -q --filter "dangling=true")'
alias python-server='python -m SimpleHTTPServer 9192'
alias crewangels-atlasboard='docker run -it --rm -p 4444:3333 -v `pwd`/jeppboard/packages/crewangels:/opt/jeppboard/packages/crewangels:rw --name crewangels-atlasboard team-crewangels-atlasboard bash'
alias hawtio='cp ~/Apps/JBoss/resources/hawtio.war $DOCKER_SHARE/ && touch $DOCKER_SHARE/hawtio.war.dodeploy'
remote-screen() {
    ssh -XYt $1 /users/shane/bin/start-screen-session.sh $1
}
dsrc() {
    for i in `docker ps -a|grep -v "NAMES"|awk '{ print $NF }'`; do 
        echo "Stopping: "
        docker rm -f $i
    done
    echo "now deleting tangling images"
    drni
}
_docker-deploy() {
    if [ "$1" == "deploy" ]; then
        rm -fr $DOCKER_SHARE/site.war && cp -r $2/application/target/site*/ $DOCKER_SHARE/site.war && touch $DOCKER_SHARE/site.war.dodeploy
    else
        #touch $DOCKER_SHARE/hawtio.war.dodeploy
        dsrc
        $1/site/my_RUN_SYSTEM.sh
    fi
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
## Core builds
buildcore() {
    pushd . &> /dev/null
    cd $CORE
    mvn clean install -DskipITs -pl '!doc.operation'
    popd &> /dev/null
}
_common-hot-deploy-build() {
    bigmvn
    SITE=$HG/$1-crewplace/sites/$2
    rsync -az --exclude *sources*.jar --exclude *javadoc*.jar $DIR/target/*.jar $SITE/application/target/site*/WEB-INF/lib/
    _docker-deploy deploy $SITE
}
core-build-sync() {
    ss=${1:-crewbid}
    _common-hot-deploy-build acme $ss
}
gc-core-build-sync() {
    _common-hot--deploy-build gc crewbid
}
## Site builds
_base-doit() {
    USER=$1
    SITE=$2
    TASK=$3

    pushd . &> /dev/null
    cd $USER
    acme-build $SITE
    _docker-deploy $TASK $USER/sites/$SITE
    popd &> /dev/null
}
acme-build() {
    if [ ! -e pom.xml ]; then
        return;
    fi
    ss=${1:-crewbid}
    for project in crewaccess crewbid crewaccessbid crewexchange all; do
        PROJECTS=$PROJECTS'!sites/'$project'/ui,!sites/'$project'/application,!sites/'$project'/site,'
    done
    mvn clean install -Dmaven.test.skip=true -pl $PROJECTS
    mvn clean install -Dmaven.test.skip=true -f sites/$ss/pom.xml
    drni
}
acme-start() {
    ss=${1:-crewbid}
    _docker-deploy $ACME_CREWPLACE/sites/$ss
}
acme-build-start() {
    ss=${1:-crewbid}
    _base-doit $ACME_CREWPLACE $ss
}
acme-build-deploy() {
    ss=${1:-crewbid}
    _base-doit $ACME_CREWPLACE $ss deploy
}
gc-build() {
    bigmvn
}
gc-start() {
    _docker-deploy $GC_CREWPLACE/sites/crewbid
}
gc-build-start() {
    bigmvn
    gc-start
}
gc-build-deploy() {
    bigmvn
    _docker-deploy $GC_CREWPLACE/sites/crewbid deploy
}

## Master command
doit() {
    pushd . &> /dev/null
    CMD_TO_DO=$@
    if [[ "$CMD_TO_DO" == *"skipCore" ]]; then
        CORE=
        CMD_TO_DO=${CMD_TO_DO%skipCore*}
    fi
    for hgrepo in $CORE $CUSTOM_PROFILES $CUSTOM_CREWPLACE $ACME_CREWPLACE $GC_CREWPLACE
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
upload_data() {
    FILE=upload
    OPTIONS=$@
    XML_FILE=${OPTIONS/*-f}
    if [[ ! -z "$XML_FILE" ]]; then
        FILE=${XML_FILE%.xml*}
    fi
    cd $HG/crewplace.upload
    export PYTHONPATH=lib/requests
    python upload_data.py $@ -f $FILE.xml
    python upload_data.py $@ -f $FILE-crew.xml -d crewInfo
    cd - &> /dev/null
}
grunt-accept() {
    pushd . &> /dev/null
    upload_data
    cd $CORE/crewplace.ui/src/test
    grunt acceptance-tests-local --baseUrl=http://dockerhost:20200/site/ $@
    popd &> /dev/null
}
grunt-monitor() {
    pushd . &> /dev/null
    cd $CORE/crewplace.ui/src/test && ./node_modules/grunt-cli/bin/grunt  monitor --deployment $DOCKER_SHARE/site.war
    popd &> /dev/null
    #grunt monitor --deployment $DOCKER_SHARE/site.war
}
createWorkspace() {
    mkdir -p $WORK/workspace/$1/.metadata/.plugins/org.eclipse.core.runtime
    mkdir -p $WORK/workspace/$1/.metadata/.plugins/org.eclipse.e4.workbench
    cp -r $WORK/workspace/crewplace-docker/.metadata/.plugins/org.eclipse.core.runtime/.settings $WORK/workspace/$1/.metadata/.plugins/org.eclipse.core.runtime/
    cp -r $WORK/workspace/resources/eclipse/workbench.xmi $WORK/workspace/$1/.metadata/.plugins/org.eclipse.e4.workbench/
}
tz-convert() {
    aDate="$1"
    location=${2:-"America/Denver"}
    echo Time in $location
    TZ=$location date -jf "%Y-%m-%d %H:%M:%S %z" "$aDate" +"%Y-%m-%dT%H:%M:%S%z"
}
big-acme-build() {
    if [ ! -e pom.xml ]; then
        echo "Must be in acme-crewplace to run this commnad"
        return;
    fi
    SITES="crewbid all crewaccess crewaccessbid crewexchange"
    for project in $SITES; do
        PROJECTS=$PROJECTS'!sites/'$project'/ui,!sites/'$project'/application,!sites/'$project'/site,'
    done
    mvn clean install -Dmaven.test.skip=true -pl $PROJECTS
    SITES=${1:-$SITES}
    for project in $SITES; do
        rc=$?
        mvn clean install -Dmaven.test.skip=true -f sites/$project/pom.xml &
        if [[ $rc != 0 ]]; then
            echo \n $project failed; break $rc \n
        fi
    done
    fg
    drni
}
git_create_remote_repo() {
    USER=$1
    REPO_NAME=$2
    curl -u '$USER' https://api.github.com/user/repos -d '{"name":"$REPO_NAME"}'
    git remote add origin https://github.com/$USER/$REPO_NAME.git
    git push origin master
}
