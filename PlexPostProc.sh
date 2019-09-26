#!/bin/bash
# Requires HandBrakeCLI, mktemp, dirname
set -o pipefail
PATH="/bin:/usr/bin"
SCRIPT="$0"
BASEDIR=$(dirname "$0")

fatal() {
  echo "[FATAL] $1."
  echo "[FATAL] Program is now exiting."
  exit 1;
}
# The above is a simple function for handeling fatal erros. (It outputs an error, and exits the program.)

if [ ! -z "$1" ]; then
  # The if selection statement proceeds to the script if $1 is not empty.
  if [ ! -f "$1" ]; then
    fatal "$1 does not exist"
  fi
  # The above if selection statement checks if the file exists before proceeding.
  FILENAME="$1"         # %FILE% - Filename of original file
  DIR=$(dirname "$FILENAME")
  TEMPFILENAME=$(mktemp -p "$DIR") # Temporary File for transcoding

  echo "********************************************************"
  echo "Transcoding, Converting to H.264 w/Handbrake"
  echo "********************************************************"

  HandBrakeCLI -i "$FILENAME" -f mp4 --aencoder av_aac --mixdown dpl2 -e qsv_h264 --x264-preset veryfast --x264-profile auto -q 20 --maxHeight 720 --decomb bob -o "$TEMPFILENAME"
  RETVAL=$?
  if [ $RETVAL -ne 0 ]; then
    fatal "Handbrake has failed (Is it installed?)"
  fi

  echo "********************************************************"

  echo "Cleanup / Copy $TEMPFILENAME to $FILENAME"

  rm -f "$FILENAME"
  mv -f "$TEMPFILENAME" "${FILENAME%.ts}.mp4"
  chmod 664 "${FILENAME%.ts}.mp4" # This step may no tbe neccessary, but hey why not.

  echo "********************************************************"

else
  echo "Usage: $0 FileName"
fi
