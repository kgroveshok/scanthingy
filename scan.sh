#!/bin/sh


# file name

f=`date +%s`

#echo $f



scanimage -x 215 -y 297 --format tiff --resolution 180 --mode Color >/home/pi/scan-$f.tiff

tiff2pdf /home/pi/scan-$f.tiff -o /home/pi/scan-$f.pdf

sudo mv /home/pi/scan-* /var/www/data/admin/files



# refresh owncloud

cd /var/www/html
sudo -u root php occ files:scan --all



