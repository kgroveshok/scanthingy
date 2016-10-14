#!/bin/sh

cat <<EOF >>/etc/sane.d/saned.conf
localhost
192.168.10.0/24
EOF
