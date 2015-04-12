#!/bin/bash
VERSION="0.1"

SYSTEM_CONFIG="/etc/chronicle.cfg"
USER_CONFIG="$HOME/.chronicle.cfg"
EDITOR="vim"

CHRONICLE_DIR="$HOME/.chronicle"
DATE_FORMAT="%Y/%m/%d/%H:%M:%S"

TMP_ENTRY="/tmp/chronicle.cfg"
TMP_ENTRY_ORIG="/tmp/chronicle.cfg.empty"

DEBUG="FALSE"
WARNINGS="TRUE"
COLOR="TRUE"

command="$1"



# ---[ Information ]--------------------------------------------------------- #

manual () {
    echo "Chronicle, the command line journal manager.
    Version $VERSION

    Usage:
        chronicle COMMAND

    Commands:
        enter:          Write a new entry.
        default-conig:  Print the default config values, write them to the given file if present.
        version:        Output only the version
        help:           Output this.
    "
}



# ---[ Feedback ]------------------------------------------------------------ #

ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;11m"
COL_GREEN=$ESC_SEQ"32;11m"
COL_YELLOW=$ESC_SEQ"33;11m"
COL_BLUE=$ESC_SEQ"34;11m"
COL_MAGENTA=$ESC_SEQ"35;11m"
COL_CYAN=$ESC_SEQ"36;11m"
print_colored_text () {
    color=$1
    text=$2
    color_code="COL_$color"
    if [ "$WARNINGS" == "TRUE" ]
    then
        echo -e "${!color_code}$text$COL_RESET"
    else
        echo $text
    fi
}

debug () {
    if [ "$DEBUG" == "TRUE" ]
    then
        print_colored_text GREEN "[DEBUG]: $@"
    fi
}

warning () {
    if [ "$WARNINGS" == "TRUE" ]
    then
        print_colored_text YELLOW "[WARNING]: $@"
    fi
}

error () {
    print_colored_text RED "[ERROR]: $@"
}



# ---[ Config ]-------------------------------------------------------------- #

safe_source (){
    configfile=$1
    configfile_secured="/tmp/$(basename $configfile)"

    if [ ! -r $configfile ]
    then
        warning "Could not read config file \"$configfile\"."
        if [ -e $configfile ]
        then
            if [ -d $configfile ]
            then
                debug "It's a directory"
            else
                debug "You don't have the correct permissions"
            fi
        else
            debug "It doesnt exist"
        fi
        return
    fi
        
    # check if the file contains something we don't want
    if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"
    then
        debug "Config file is unclean, cleaning it..."
        # filter the original to a new file
        egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
        configfile="$configfile_secured"
    fi
    
    source $configfile
}

read_config (){
    debug "Reading system-wide config"
    safe_source $SYSTEM_CONFIG
    debug "Reading user config"
    safe_source $USER_CONFIG
}

default_config (){
    debug "Generating default config file"
    file_argument=$2
    output_file="/dev/stdout"

    if [ $file_argument ]
    then
        output_file=$file_argument
        debug "Writing default config file to $output_file"
    else
        debug "Writing default config file to stdout."
    fi

    echo "DEBUG=$DEBUG" >>$output_file
    echo "WARNINGS=$WARNINGS" >>$output_file
    echo "COLOR=$COLOR" >>$output_file

    echo "CHRONICLE_DIR=$CHRONICLE_DIR" >>$output_file
    echo "EDITOR=$EDITOR" >>$output_file
    echo "DATE_FORMAT=$DATE_FORMAT" >>$output_file

    echo "SYSTEM_CONFIG=$SYSTEM_CONFIG" >>$output_file
    echo "USER_CONFIG=$USER_CONFIG" >>$output_file
    echo "TMP_ENTRY=$TMP_ENTRY" >>$output_file
    echo "TMP_ENTRY_ORIG=$TMP_ENTRY_ORIG" >>$output_file
}



# ---[ New entry ]----------------------------------------------------------- #

prepare () {
    # If the tmp entry exists, delete it first.
    if [ -e $TMP_ENTRY ]
    then
        rm -f $TMP_ENTRY
    fi

    file=$1
    echo "---" >> $file
    echo "date: $(date +"%Y-%m-%d")" >> $file
    echo "time: $(date +"%H:%M")" >> $file
    echo "tags: " >> $file
    echo "---" >> $file
}

enter () {
    debug "Starting new entry"
    prepare $TMP_ENTRY

    cp $TMP_ENTRY $TMP_ENTRY_ORIG

    # possibly edit the file
    $EDITOR $TMP_ENTRY

    diff $TMP_ENTRY $TMP_ENTRY_ORIG > /dev/null 2>&1
    if [ "$?" == "1" ]
    then
        entry_file=$CHRONICLE_DIR/$(date +"$DATE_FORMAT").txt
        debug "Generating a new entry file: $entry_file"
        mkdir -p $(dirname $entry_file)
        mv $TMP_ENTRY $entry_file
    else
        debug "Not generating a new entry, no new content"
    fi

    rm -f $TMP_ENTRY_ORIG
}



# ---[ Execute ]------------------------------------------------------------- #

read_config
case $command in
    "enter" )
        enter
        ;;
    "default-config" )
        default_config $@
        ;;
    "help" )
        manual
        ;;
    "version" )
        echo $VERSION
        ;;
    * )
        manual
        ;;
esac
