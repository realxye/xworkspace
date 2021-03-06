
##
##  Functions
##

# get current script dir, no matter how it is called
xwsGetScriptDir(){
    scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
    echo $scriptDir
}

# lower-case string
xwstolower(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

# upper-case string
xwstoupper(){
    echo "$1" | sed "y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/"
}

# get os name
xwsgetos(){
    UNAMESTR=`xwstoupper \`uname -s\``
    if [[ "$UNAMESTR" == MINGW* ]]; then
        echo Windows
    elif [[ "$UNAMESTR" == MSYS* ]]; then
        echo Windows
    elif [[ "$UNAMESTR" == *LINUX* ]]; then
        echo Linux
    elif [ "{$UNAMESTR}" == "{FREEBSD}" ]; then
        echo FreeBSD
    elif [[ "$UNAMESTR" == DARWIN* ]]; then
        echo Mac
    else
        echo Unknown
    fi
}

# get XWSROOT
xwsgetroot(){
    scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
    rootDir=`echo $scriptDir | sed 's/\/[a-zA-Z]*\/[a-zA-Z]*$//'`
    echo $rootDir
}

##
##  Export Path/Settings
##
#  -> OS Name
export XWSROOT=`echo \`xwsgetroot\``
export XOS=`echo \`xwsgetos\``
#  -> Load OS-related files
if [ $XOS == Windows ]; then
    source $XWSROOT/xws/settings/bashrc_xws_win.sh
elif [ $XOS == Linux ]; then
    source $XWSROOT/xws/settings/bashrc_xws_linux.sh
elif [ $XOS == FreeBSD ]; then
    source $XWSROOT/xws/settings/bashrc_xws_linux.sh
elif [ $XOS == Mac ]; then
    source $XWSROOT/xws/settings/bashrc_xws_mac.sh
else
    echo Unknown OS, failed.
fi

##
##  Alias
##

# Common
alias cls='clear'
alias cdw='cd $XWSROOT'

# build
alias makex86rel='make BUILDARCH=x86 BUILDTYPE=release'
alias makex86dbg='make BUILDARCH=x86 BUILDTYPE=debug'
alias makex64rel='make BUILDARCH=x64 BUILDTYPE=release'
alias makex64dbg='make BUILDARCH=x64 BUILDTYPE=debug'

alias makex86relv='make BUILDARCH=x86 BUILDTYPE=release VERBOSE=yes'
alias makex86dbgv='make BUILDARCH=x86 BUILDTYPE=debug VERBOSE=yes'
alias makex64relv='make BUILDARCH=x64 BUILDTYPE=release VERBOSE=yes'
alias makex64dbgv='make BUILDARCH=x64 BUILDTYPE=debug VERBOSE=yes'

# This fix git-bash ssh connection problem
alias xssh='ssh -o IdentitiesOnly=yes'
alias xscp='scp -o IdentitiesOnly=yes'
alias mysql='winpty mysql'

# Git Alias
#  -> get status
alias gits='git status'
#  -> add all files
alias gitaa='git add -A'
#  -> commit
alias gitc='git commit -a -m'
#  -> show repo history
alias gith='git log --pretty=format:"%h - %an, %ar : %s"'
#  -> show file history
alias githf='git log --follow --pretty=format:"%h - %an, %ar : %s" --'
