#!/bin/bash
# Wrapper to run PlexPostProc.sh with the ability to debug
# Set debug to anything but 0 to log all activity
# And data sent to/from the script
set -o pipefail
PATH="/bin:/usr/bin"
SCRIPT="$0"
BASEDIR=$(dirname "$0")

PLEXPOSTPROC="$BASEDIR/PlexPostProc.sh"
FILETOPROC="$1"         # %FILE% - Filename of original file

DEBUG=0

if [ $DEBUG -ne 0 ]; then
  LOG=$(mktemp -t PlexPost-$(date -Is).XXX.log)
  touch $LOG

  echo "$(date -Ins) BEGIN" | tee -a $LOG
  echo "===VARIABLES===" | tee -a $LOG

  for var in "$@"; do
    echo "$var" | tee -a $LOG
  done
  $PLEXPOSTPROC "$FILETOPROC" 2>&1 | tee -a $LOG
  echo "$(date -Ins) END" | tee -a $LOG
fi

$PLEXPOSTPROC "$FILETOPROC"
