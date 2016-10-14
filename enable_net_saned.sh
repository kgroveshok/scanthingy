#!/bin/sh

cat <<EOF >>/etc/sane.d/saned.conf
localhost
192.168.10.0/24
data_portrange = 10000 - 10100
EOF


# /etc/default/saned.conf
#RUN=yes

adduser saned root
sudo update-rc.d saned defaults
