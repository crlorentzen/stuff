#!/bin/sh
# Simplify to using ffmpeg directly
# better control

alias date='date "+%Y-%m-%dT%H:%M:%S%z"'
PATH="/usr/local/bin/:/usr/bin:/bin"
SCRIPT="$0"

QUOTE="'"
DEBUG=0

fatal() {
  echo "[FATAL] $1."
  echo "[FATAL] Program is now exiting."
  exit 1;
}


# If file to process doesn't exist fail
if [ ! -f "$1" ]; then
  fatal "$1 does not exist"
fi

# ensure ffmpeg is available and executable
alias FF=$(which ffmpeg)
RETVAL="$?"
if [ ! ${RETVAL} ]
then
  fatal "Cannot find ffmpeg (is it installed?)"
fi

INFILE="$1"
INDIR=$(dirname "${INFILE}")
export TMPDIR=${INDIR}
OUTFILE=$(mktemp) # Temporary File for transcoding
FF_OPTS=''
FF_VFS=''

#bwdif/yadif options,
#  mode:
#    send_frame - Output one frame for each frame. (def: yadif),
#    send_field - Output one frame for each field. frame doubling (def: bwdif)
#  parity: ttf - top field first, btf - bottom fiend first, auto (def)
#  deint: all - all frames (def), interlaced - if frame marked interlaced
VF_DEINT='bwdif=mode=send_frame:parity=auto:deint=interlaced'

VF_CROP=$(FF -ss 00:01:30 -i "${INFILE}" -t 10 -filter:v cropdetect -f null - 2>&1| awk '/crop/{print $NF}' | tail -n1)
VF_CROP="${VF_CROP}:keep_aspect=1"

VF_SCALE="scale=w=${QUOTE}min(1280,iw)${QUOTE}:h=${QUOTE}min(720,ih)${QUOTE}:force_original_aspect_ratio=decrease"
VF_PAD="pad=${QUOTE}ceil(iw/2)*2:ceil(ih/2)*2${QUOTE}"



FF_VFS="${VF_DEINT},${VF_CROP},${VF_SCALE},${VF_PAD}"
FFV_CODEC="libx264 -preset veryfast -crf 20"
FFA_CODEC="aac"
# -q:a 3"


FF_OPTS="-filter:v ${FF_VFS} -c:v ${FFV_CODEC} -c:a ${FFA_CODEC} -f mp4 -y"

echo "FF -i \"${INFILE}\" ${FF_OPTS} ${OUTFILE}"

FF -i "${INFILE}" ${FF_OPTS} "${OUTFILE}"
RETVAL=$?
if [ $RETVAL -ne 0 ]; then
  fatal "Encoding failed"
fi

rm -f "${INFILE}"
mv -f "${OUTFILE}" "${INFILE}"
