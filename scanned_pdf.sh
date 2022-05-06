#!/bin/bash
set -e

#Make your PDF look scanned.
#Idea from the post in HN. Make a Gist with the command code.
#https://gist.github.com/jduckles/29a7c5b0b8f91530af5ca3c22b897e10

INPUT_FILE="${1}"

if [ "${2}" == "t" ]
then
    Y_SHIFT="530"
else
    Y_SHIFT="540"
fi

if [ ! -z "${3}" ]
then
    SIGN_FILE="${3}"
else
    SIGN_FILE="sign.jpg"
fi

if [ ! -z "${4}" ]
then
    BACKGR_FILE="${4}"
else
    BACKGR_FILE="background.jpg"
fi

xDIR="$(dirname "${INPUT_FILE}")"
xNAME="$(basename -s .pdf "${INPUT_FILE}")"
convert -density 150 "${INPUT_FILE}" -gravity center -extent 1275x1754 tmp.png
convert tmp.png -gravity center -crop 1240x1754+0+0 +repage tmp.png
convert tmp.png \( "${SIGN_FILE}" -rotate $(seq -1.5 .01 1.5 | shuf | head -n1) \) -gravity Center -geometry 200x200-180+"${Y_SHIFT}" -composite tmp.png
composite -dissolve 3 -gravity Center "${BACKGR_FILE}" tmp.png -alpha Set tmp.png
convert tmp.png -linear-stretch 2%x6% -blur 0x0.5 -attenuate 0.25 +noise Gaussian -rotate $(seq -0.3 .01 0.3 | shuf | head -n1) aux_output.pdf
gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite -sColorConversionStrategy=LeaveColorUnchanged -dAutoFilterColorImages=true -dAutoFilterGrayImages=true -dDownsampleMonoImages=true -dDownsampleGrayImages=true -dDownsampleColorImages=true -sOutputFile="${xDIR}/${xNAME}_scanned.pdf" aux_output.pdf

rm tmp.png aux_output.pdf
