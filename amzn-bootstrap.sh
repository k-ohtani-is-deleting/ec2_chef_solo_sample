#!/bin/sh
set -e -x
LOGFILE=/tmp/log.txt
echo "==Start!==" > $LOGFILE
yum upgrade -y >> $LOGFILE 2>&1
yum install -y gcc make ruby-devel rubygems python-setuptools >> $LOGFILE 2>&1
gem install chef --no-ri --no-rdoc >> $LOGFILE 2>&1
mkdir /etc/chef /var/chef >> $LOGFILE 2>&1
chmod -R 666 /etc/chef /var/chef >> $LOGFILE 2>&1
echo "==Done!==" >> $LOGFILE
