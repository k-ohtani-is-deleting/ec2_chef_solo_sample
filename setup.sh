#!/bin/sh

if test -z "$2"
then
  echo "setup.sh target_host remote_user [ssh_private_key]"
  exit 1
fi
TARGET_HOST=$1
SSH_USER=$2

SSH_PRIVATE_KEY=""
if test "$3"
then
  SSH_PRIVATE_KEY="-i $3"
fi

cd `dirname $0`
COOKBOOKS=cookbooks
COOKBOOKS_DIR=./$COOKBOOK
CONFIG_DIR=./conf
SSH_PORT=22
SLEEP_TIME=10

## wait for chef-solo installing
STATUS="1"
CHEF_SOLO_CHECK="ssh -q -t -l $SSH_USER -p $SSH_PORT $SSH_PRIVATE_KEY $SSH_USER@$TARGET_HOST \"sudo -i sh -c 'which chef-solo > /dev/null'\""

while [ $STATUS -ne "0" ]
do
  eval $CHEF_SOLO_CHECK
  STATUS=$?
  if [ $STATUS -ne "0" ]
  then
    echo "waiting $SLEEP_TIME sec..." 
    sleep $SLEEP_TIME
  fi
done

tar cvf - -C $COOKBOOKS_DIR $COOKBOOKS | gzip > /tmp/$COOKBOOKS.tar.gz

## transfer required files
scp $SSH_PRIVATE_KEY -r -P $SSH_PORT \
/tmp/$COOKBOOKS.tar.gz \
$CONFIG_DIR/solo.rb \
$CONFIG_DIR/node.json \
$SSH_USER@$TARGET_HOST:/tmp/

## execute chef-solo
ssh -q -t -l $SSH_USER -p $SSH_PORT $SSH_PRIVATE_KEY $SSH_USER@$TARGET_HOST \
"sudo -i sh -c '\
cd /var/chef && \
tar xvfz /tmp/$COOKBOOKS.tar.gz && \
cp /tmp/solo.rb /etc/chef && \
cp /tmp/node.json /etc/chef && \
chef-solo \
'"
