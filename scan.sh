#!/bin/sh


# file name

#f=`date +%s`
f=`date +%Y%m%d-%H%M%S`

echo $f




echo "Scanning"


scanimage -p -x 215 -y 297 --format tiff --resolution 250 --mode Color >/tmp/scan-$f.tiff


cd /tmp

echo "Tiff to PDF"
tiff2pdf scan-$f.tiff -o scan-$f.pdf

echo "Tesseract"

tesseract scan-$f.tiff -c load_system_dawg=false -c load_freq_dawg=false   -psm 1 -l eng  scan-text1-$f.txt 
tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false  -psm 2 -l eng  scan-text2-$f.txt 
tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 3 -l eng  scan-text3-$f.txt 
tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 4 -l eng  scan-text4-$f.txt 
# crap tesseract scan-$f.tiff -psm 5 -l eng  scan-text5-$f.txt 
tesseract scan-$f.tiff  -c load_system_dawg=false -c load_freq_dawg=false   -psm 6 -l eng  scan-text6-$f.txt 
# crap tesseract scan-$f.tiff -psm 7 -l eng  scan-text7-$f.txt 



sudo chown www-data:www-data /tmp/scan*
sudo chmod a=rwx /tmp/scan*

# relocate files

sudo mv /tmp/scan-* /var/www/data/admin/files -v

# fix up perms


# refresh owncloud

cd /var/www/html
sudo -u root php occ files:scan --all



