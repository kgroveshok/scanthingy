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

SCANHOME=~/Documents/Scanner

mkdir -p $SCANHOME


DEFT=""
DEFC="Default"
DEFD="150"

while [[ 1 ]] ; do

	if [[ -a $SCANHOME/.scan ]] ; then
		# fill in from previous run if there
		DEFT=`head -n 1 $SCANHOME/.scan`
		DEFC=`head -n 2 $SCANHOME/.scan | tail -n 1`
		DEFD=`tail -n 1 $SCANHOME/.scan`
	fi



	dialog --extra-button --extra-label "With OCR" --form "Scan New Document or Continue Adding" 15 45 8 "Title" 2 2 "$DEFT" 2 10 25  25 "Category" 4 2 "$DEFC" 4 12 15 15 "DPI" 6 2 "$DEFD" 6 10 5 5   2>$SCANHOME/.scan

	RES=$?


	if [[ $RES -eq 0 || $RES -eq 3 ]] ; then


		DEFT=`head -n 1 $SCANHOME/.scan`
		DEFC=`head -n 2 $SCANHOME/.scan | tail -n 1`
		DEFD=`tail -n 1 $SCANHOME/.scan`

		if [[ -z $DEFD ]] ; then
			DEFD=150
		fi

		if [[ -z $DEFC ]] ; then
			DEFC="Default"
		fi
		cat <<-EOF >$SCANHOME/.scan
		$DEFT
		$DEFC
		$DEFD
		EOF

		mkdir -p "$SCANHOME/$DEFC/$DEFT"

		f=`date +%Y%M%d-%H%m%S`

		echo "Scanning"


		scanimage -p -x 215 -y 297 --format tiff --resolution $DEFD --mode Color >"/$SCANHOME/$DEFC/$DEFT/scan-$f.tiff"


		cd "$SCANHOME/$DEFC/$DEFT"

		echo "Tiff to PDF"
		tiffcp scan-*.tiff "$DEFT.tiff"
		tiff2pdf scanfull.tiff -o "$DEFT.pdf" -t "$DEFT"

		if [[ $RES -eq 3 ]] ; then
			echo "Tesseract OCR"

			tesseract scan-$f.tiff -c load_system_dawg=false -c load_freq_dawg=false   -psm 1 -l eng  scan-text1-$f.txt 
			tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false  -psm 2 -l eng  scan-text2-$f.txt 
			tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 3 -l eng  scan-text3-$f.txt 
			tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 4 -l eng  scan-text4-$f.txt 
			# crap tesseract scan-$f.tiff -psm 5 -l eng  scan-text5-$f.txt 
			tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 6 -l eng  scan-text6-$f.txt 
			# crap tesseract scan-$f.tiff -psm 7 -l eng  scan-text7-$f.txt 
		fi

		echo "Create Tar"
		rm -fv "$SCANHOME/$DEFC-$DEFT.tar"
		tar cvf "$SCANHOME/$DEFC-$DEFT.tar" "$SCANHOME/$DEFC/$DEFT"

	else
		exit
	fi



done
