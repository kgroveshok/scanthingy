#!/bin/bash

#
#


function ocr {
	echo "Tesseract OCR"
	
	#cd `basedir $1`

	dirname "$1"

	#threshold seems better than sharpen
  	#convert "$1" -sharpen 10x35 /dev/shm/toocr.tiff
	#convert "$1" -threshold 20% /dev/shm/toocr.tiff
	#level seems better
	convert "$1" -level 15x85% /dev/shm/toocr.tiff

	EXTRA=""

	if [[ -n "$2" ]] ; then
		#second item is a mask to apply if given
		echo "Applying mask"
		convert "$1" "$2" -composite /dev/shm/toocr2.tiff
		mv /dev/shm/toocr2.tiff /dev/shm/toocr.tiff
		EXTRA=".masked"
	fi

	echo "."	
	tesseract /dev/shm/toocr.tiff -c load_system_dawg=false -c load_freq_dawg=false   -psm 1 -l eng  "$1$EXTRA.text1" >/dev/null 2>&1 
	#tesseract "$1"  -c load_system_dawg=false -c load_freq_dawg=false  -psm 2 -l eng  "$1.text2"i
	echo "."	
	tesseract /dev/shm/toocr.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 3 -l eng  "$1$EXTRA.text3" >/dev/null 2>&1
	echo "."	
	tesseract /dev/shm/toocr.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 4 -l eng  "$1$EXTRA.text4" >/dev/null 2>&1
	echo "."	
	# crap tesseract scan-$f.tiff -psm 5 -l eng  scan-text5-$f.txt 
	tesseract /dev/shm/toocr.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 6 -l eng  "$1$EXTRA.text6" >/dev/null 2>&1
	echo "."	

	# put all in a single text file for ease

	cat "$1$EXTRA.text1.txt" "$1$EXTRA.text3.txt" "$1$EXTRA.text4.txt" "$1$EXTRA.text6.txt" >"$1$EXTRA.ocr.txt"

	rm  "$1$EXTRA.text1.txt" "$1$EXTRA.text3.txt" "$1$EXTRA.text4.txt" "$1$EXTRA.text6.txt"
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

function autoscanner {
SCANHOME=$SCANDOCS

mkdir -p $SCANHOME


$MENU --inputbox "DPI?" 8 5 "100" 2>/tmp/dpi.txt

$MENU --yesno "Pause after each page?" 8 30

if [[ $? -eq 0 ]] ; then
DOPAUSE=1
else
DOPAUSE=0
fi

DEFT="Auto"
DEFC="Default"

DEFD=`cat /tmp/dpi.txt`

if [[ -z "$DEFD" ]] ; then
	DEFD="100"
fi

PAGE=1

while [[ 1 ]] ; do


	mkdir -p "$SCANHOME/$DEFC/$DEFT"

	f=`date +%Y%m%d-%H%M%S`

	$MENU --infobox "Page $PAGE: Continuous $DEFD DPI scan until ctrl-c to Default/Auto $f" 15 45 

	scanimage -p -x 215 -y 297 --format tiff --resolution $DEFD --mode Color >"/$SCANHOME/$DEFC/$DEFT/scan-$f.tiff"  

		if [[ $DOPAUSE -eq 1 ]] ; then
			$MENU --yesno "Ready for next?" 8 30
		else
			sleep 5
		fi
	if [[ -s "/$SCANHOME/$DEFC/$DEFT/scan-$f.tiff" ]]; then
		PAGE=$((PAGE+1))
	else
		
		rm  "/$SCANHOME/$DEFC/$DEFT/scan-$f.tiff"
	fi

done
}
function scanner {
SCANHOME=$SCANDOCS

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



	$MENU --extra-button --extra-label "With OCR" --form "Scan new document or appending to..." 15 45 8 "Title" 2 2 "$DEFT" 2 10 25  25 "Category" 4 2 "$DEFC" 4 12 15 15 "DPI" 6 2 "$DEFD" 6 10 5 5   2>$SCANHOME/.scan

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
		if [[ -z $DEFT ]] ; then
			DEFT="Misc"
		fi
		cat <<-EOF >$SCANHOME/.scan
		$DEFT
		$DEFC
		$DEFD
		EOF

		mkdir -p "$SCANHOME/$DEFC/$DEFT"

		f=`date +%Y%m%d-%H%M%S`

		echo "Scanning into $DEFC/$DEFT"

		scanimage -p -x 215 -y 297 --format tiff --resolution $DEFD --mode Color >"/$SCANHOME/$DEFC/$DEFT/scan-$f.tiff" 


		cd "$SCANHOME/$DEFC/$DEFT"

		#PDFKEYWORDS=""

		if [[ $RES -eq 3 ]] ; then
			# conslidate all keywords for the PDF
			ocr "$SCANHOME/$DEFC/$DEFT/scan-$f.tiff"
			#PDFKEYWORDS=`cat scan-text*.txt`
		fi


		# pause incase want to do anything before packing up images

		$MENU --yesno "Scan done, pausing before packaging to PDF" 8 30

		if [[ $? -eq 0 ]] ; then
			# create/update the pdf and include all of the ocr text (if any in the pdf for searching)

			packtopdf "$SCANHOME" "$DEFC" "$DEFT"
		fi
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
	SCANHOME=$SCANDOCS
	
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

function classifyauto {
	# Classify all auto scanned documents via regex on ocr 
	
	SCANHOME=$SCANDOCS/Default/Auto
	MASKHOME=$SCANDOCS/Masks
	
	REGEX=$SCANDOCS/.scanregex 

	cd $SCANHOME
	for f in `ls scan-*.tiff` ; do

		f=`echo $f | sed 's/~/ /g'`

		# first ensure all files are OCR'd
	
		echo "Checking image $f"

		if [[ -a "$f.ocr.txt" ]] ; then
			echo " ... ignoring already done OCR"
		else
			echo " ... need to OCR"
			ocr "$SCANHOME/$f"
		fi
		
		# lookup any matching regexs

		cat $REGEX | ( while read l ; do
			#echo "Scan line $l"
			PATTERN=`echo $l | cut -f1 -d'~'`
			RELDIR=`echo $l | cut -f2 -d'~'`
			MASK=`echo $l | cut -f3 -d'~'`
			NEWTITLE=`echo "$PATTERN" | sed 's/ /_/g'`
			if [[ -a "$f.ocr.txt" ]] ; then
				grep -i "$PATTERN" "$f.ocr.txt" -c >/dev/null

				if [[ $? -eq 0 ]] ; then
					mkdir -p "$SCANHOME/$RELDIR/$NEWTITLE"
					echo "Found match moving file to $RELDIR /$NEWTITLE"

					if [[ -n "$MASK" ]] ; then
						echo "Repply ocr but with mask"
						ocr "$SCANHOME/$f" "$MASKHOME/$MASK"
					fi

					mv "$SCANHOME/$f" "$SCANHOME/$RELDIR/$NEWTITLE"
					mv "$SCANHOME/$f.ocr.txt" "$SCANHOME/$RELDIR/$NEWTITLE"
					if [[ -a "$SCANHOME/$f.masked.ocr.txt" ]] ; then
						mv "$SCANHOME/$f.masked.ocr.txt" "$SCANHOME/$RELDIR/$NEWTITLE"
					fi

				fi
			fi
		done 	)	

	done


}
function packageall {
	# TODO pass if new or reocr all
	# 0=all 1=new
	SCANHOME=$SCANDOCS
	
	cd $SCANHOME
	for f in `find . -name scan-*.tiff | sed 's/ /~/g'` ; do

		f=`echo $f | sed 's/~/ /g'`

		echo "Packing for image $f"

		packtopdf "$SCANHOME/$f"
		

	done


}

function copier {
	
		$MENU --inputbox "How many copies?" 8 5 "1" 2>/tmp/copies.txt
	
		echo "Scanning"
		scanimage -p -x 215 -y 297 --format tiff --resolution 150 --mode Gray >/tmp/copier.tiff
		tiff2pdf /tmp/copier.tiff -z -o /tmp/copier.pdf
	
		echo "Printing"
	
		T=`cat /tmp/copies.txt`
		C=1

		while [[ $C -le $T ]] ; do
			echo "Copy $C"
			lpr /tmp/copier.pdf
			C=$((C+1))
		done	
			
}

# start proper of script

MENU=dialog

if [[ -n "$DISPLAY" ]] ; then
	# notquite compat with dialog
	#MENU=zenity
	echo
fi

# define the scanner document root

if [[ -z "$SCANDOCS" ]] ; then
	SCANDOCS=~/Documents/Scanner

	echo "No environment var SCANDOCS, setting default to $SCANDOCS"
fi


# main menu

while [[ 1 ]] ; do
	$MENU --menu "Main Menu" 15 35 8 "S" "Scanner" "A" "Auto-scanner" "C" "Photocopy" "O" "OCR All new scans" "F" "Re-OCR all scans (TODO)" "P" "Repackage all PDFs" "L" "Classify Auto-scanner" "E" "Edit classifer patterns" 2>/tmp/scanmenu

	if [[ $? -ne 0 ]] ; then
		exit
	fi
	MENOPT=`cat /tmp/scanmenu`

	if [[ "$MENOPT" = "E" ]] ; then
		# use fav editor if known else use vi
		if [[ -z "$EDITOR" ]] ; then
			EDITOR="vi"
		fi
		# if no file then create stub
		if [[ -a "$SCANDOCS/.scanregex" ]] ; then
			echo "Editing existing file"
		else
			cat <<-EOF >$SCANDOCS/.scanregex
# regex for auto classification
# line format is:
#   <regrex>~<subdir to file to>~<optional mask>
#
# the optional mask can be used to reocr the matched file and extract specific information on the page
# Mask images should be in png format with transparency painted in where you want to apply the ocr
# the files are then stored in Masks under the scanner root folder 
EOF
		fi
		$EDITOR $SCANDOCS/.scanregex 
	fi
	if [[ "$MENOPT" = "L" ]] ; then
		classifyauto
	fi
	if [[ "$MENOPT" = "A" ]] ; then
		autoscanner
	fi
	if [[ "$MENOPT" = "S" ]] ; then
		scanner
	fi
	if [[ "$MENOPT" = "O" ]] ; then
		ocrall
	fi
	if [[ "$MENOPT" = "C" ]] ; then
		copier
	fi
	if [[ "$MENOPT" = "P" ]] ; then
		packageall
	fi
done


