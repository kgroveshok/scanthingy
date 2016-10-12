#!/bin/sh
    
sudo apt-get install imagemagick  sane libtiff* libjpeg-dev vim mc mysql-server scanbuttond git php5 apache2 libapache2-mod-php5 libtool

cd /home/pi
git clone git@github.com:kgroveshok/scanthingy.git


cd /home/pi/scanthingy

# wget http://www.leptonica.com/source/leptonica-1.73.tar.gz
#     tar zxvf leptonica-1.73.tar.gz 
#     cd leptonica-1.73/
#     ./configure
#    git clone https://github.com/tesseract-ocr/tesseract.git
#    wget https://github.com/tesseract-ocr/tessdata/archive/master.zip

cd /home/pi/scanthingy

sh getopenkm.sh 

cd /home/pi
unzip owncloud-9.1.1.zip 

#  125  ls
#  126  mv owncloud-9.1.1.zip ..
#  127  cd ..
#  128  ls
#  146  ls
#  147  cd /var/
#  148  ls
#  149  cd www
#  150  ls
#  151  cd html/
#  152  ls
#  153  cd ..
#  154  mv /home/pi/owncloud .
#  155  sudo mv /home/pi/owncloud .
#  156  ls -la
#  157  sudo bash
#  158  cd
#  159  ls
