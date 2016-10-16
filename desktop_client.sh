#!/bin/bash

#
#


function ocr {
	echo "Tesseract OCR"
	
	#cd `basedir $1`
	
	tesseract "$1" -c load_system_dawg=false -c load_freq_dawg=false   -psm 1 -l eng  "$1.text1"
	tesseract "$1"  -c load_system_dawg=false -c load_freq_dawg=false  -psm 2 -l eng  "$1.text2"
	tesseract "$1"  -c load_system_dawg=false -c load_freq_dawg=false   -psm 3 -l eng  "$1.text3"
	tesseract "$1"  -c load_system_dawg=false -c load_freq_dawg=false   -psm 4 -l eng  "$1.text4"
	# crap tesseract scan-$f.tiff -psm 5 -l eng  scan-text5-$f.txt 
	tesseract "$1"  -c load_system_dawg=false -c load_freq_dawg=false   -psm 6 -l eng  "$1.text6"

	# put all in a single text file for ease

	cat "$1.text1.txt" "$1.text2.txt" "$1.text3.txt" "$1.text4.txt" "$1.text6.txt" >"$1.ocr.txt"

	rm  "$1.text1.txt" "$1.text2.txt" "$1.text3.txt" "$1.text4.txt" "$1.text6.txt"
			# crap tesseract scan-$f.tiff -psm 7 -l eng  scan-text7-$f.txt 
}

function packtopdf  {
	# pass either three vars with the split parts or
	# if one is given then split it up

	if [[ -z "$2" ]] ; then 
		# if not passed in bits split into array and assign correct parts
		IFS='/' read -ra DIRS <<< "$1"	
		C=${#DIRS[@]}
		if [[ "${1%%.tiff}" != "0" ]] ; then
			# file name also given so shift down one
			C=$((C-1))
		fi  
		title=${DIRS[C-1]}
		cate=${DIRS[C-2]}
		home=${DIRS[0]}
		m=$((C-3))
		i=1
		while [[ $i -le $m ]]; do
			home="$home/${DIRS[i]}"
			i=$((i+1))
		done

	else

		home=$1
		cate=$2
		title=$3
	fi
	cd "$home/$cate/$title"
	echo "Tiff to PDF"
	tiffcp scan-*.tiff scanfull.tiff

	PDFKEYWORDS=`cat *.txt`
	tiff2pdf scanfull.tiff -z -o "$title.pdf" -t "$title" -k "$PDFKEYWORDS"
}

function scanner {
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

		f=`date +%Y%m%d-%H%M%S`

		echo "Scanning"

		scanimage -p -x 215 -y 297 --format tiff --resolution $DEFD --mode Color >"/$SCANHOME/$DEFC/$DEFT/scan-$f.tiff" 


		cd "$SCANHOME/$DEFC/$DEFT"

		#PDFKEYWORDS=""

		if [[ $RES -eq 3 ]] ; then
			# conslidate all keywords for the PDF
			ocr "$SCANHOME/$DEFC/$DEFT/scan-$f.tiff"
			#PDFKEYWORDS=`cat scan-text*.txt`
		fi

		# create/update the pdf and include all of the ocr text (if any in the pdf for searching)

		packtopdf "$SCANHOME" "$DEFC" "$DEFT"

		#echo "Create Tar"
		#rm -fv "$SCANHOME/$DEFC-$DEFT.tar"
		#tar cvf "$SCANHOME/$DEFC-$DEFT.tar" "$SCANHOME/$DEFC/$DEFT"

	else
		return
	fi



done
}

#

function ocrall {
	# TODO pass if new or reocr all
	# 0=all 1=new
	SCANHOME=~/Documents/Scanner
	
	cd $SCANHOME
	for f in `find . -name scan-*.tiff | sed 's/ /~/g'` ; do

		f=`echo $f | sed 's/~/ /g'`

		echo "Checking image $f"

		if [[ -a "$f.ocr.txt" ]] ; then
			echo " ... ignoring already done OCR"
		else
			echo " ... need to OCR"
			ocr "$SCANHOME/$f"
			# repack to pdf	
			packtopdf "$SCANHOME/$f"
		fi
		

	done


}

function packageall {
	# TODO pass if new or reocr all
	# 0=all 1=new
	SCANHOME=~/Documents/Scanner
	
	cd $SCANHOME
	for f in `find . -name scan-*.tiff | sed 's/ /~/g'` ; do

		f=`echo $f | sed 's/~/ /g'`

		echo "Packing for image $f"

		packtopdf "$SCANHOME/$f"
		

	done


}
# main menu

while [[ 1 ]] ; do
	dialog --menu "Main Menu" 15 35 5 "S" "Scanner" "C" "Copier (TODO)" "O" "OCR All New Scans" "F" "Re-OCR All Scans (TODO)" "P" "Repackage all PDFs" 2>/tmp/scanmenu

	if [[ $? -ne 0 ]] ; then
		exit
	fi
	MENOPT=`cat /tmp/scanmenu`

	if [[ "$MENOPT" = "S" ]] ; then
		scanner
	fi
	if [[ "$MENOPT" = "O" ]] ; then
		ocrall
	fi
	if [[ "$MENOPT" = "P" ]] ; then
		packageall
	fi
done


