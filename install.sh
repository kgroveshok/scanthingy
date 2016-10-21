#!/bin/sh
    
sudo apt-get install imagemagick  sane libtiff* libjpeg-dev vim mc mysql-server scanbuttond git php5 apache2 libapache2-mod-php5 libtool automake samba

cd 
git clone git@github.com:kgroveshok/scanthingy.git


cd ~/scanthingy

# wget http://www.leptonica.com/source/leptonica-1.73.tar.gz
#     tar zxvf leptonica-1.73.tar.gz 
#     cd leptonica-1.73/
#     ./configure
#    git clone https://github.com/tesseract-ocr/tesseract.git
#    wget https://github.com/tesseract-ocr/tessdata/archive/master.zip

cd ~/scanthingy


cd leptonica-1.73
./autobuild
./configure
make clean
make
sudo make install
sudo ldconfig

cd

wget https://github.com/tesseract-ocr/tessdata/archive/master.zip

unzip master.zip

cd ~/scanthingy

git clone https://github.com/tesseract-ocr/tesseract.git

cd tesseract
./autobuild
./configure
make
sudo make install
sudo ldconfig

cd




# if wanting owncloud
#sh getopenkm.sh 

#cd /home/pi
#unzip owncloud-9.1.1.zip 

