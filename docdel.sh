#!/bin/bash


# on run
#  select if single sheet or multi sheet
#  if single sheet
#    prompt for classification and title then scan
#
# if multi sheet
#   prompt for classificatino and title then create dir 
#   scan page
#   prompt for enter or space to do next or another any other key to exit

DEFT=""
DEFD="150"

if [[ -a /tmp/scandet.txt ]] ; then
	# fill in from previous run if there
	DEFT=`head -n 1 /tmp/scandet.txt`
	DEFD=`tail -n 1 /tmp/scandet.txt`
fi

dialog --form "Scan New Document or Continue Adding" 25 45 25 "Title" 2 2 "$DEFT" 2 10 25  25 "DPI" 5 2 "$DEFD" 5 10 25 25   2>/tmp/scandet.txt


DEFT=`head -n 1 /tmp/scandet.txt`
DEFD=`tail -n 1 /tmp/scandet.txt`

mkdir -p "/tmp/scanner/$DEFT"

f=`date +%Y%M%d-%H%m%S`

echo "Scanning"


scanimage -p -x 215 -y 297 --format tiff --resolution $DEFD --mode Color >"/tmp/scanner/$DEFT/scan-$f.tiff"


cd "/tmp/scanner/$DEFT"

echo "Tiff to PDF"
tiffcp scan-*.tiff scanfull.tiff
tiff2pdf scanfull.tiff -o scanfull.pdf -t "$DEFT"

