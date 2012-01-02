#!/bin/sh
#==========================================
# Setup minimum packages for the instance
# which does not support CloudInit execution
# on first boot. (CentOS, and others)
#==========================================

if test -z "$2"
then
  echo "prepare.sh target_host remote_user [ssh_private_key]"
  exit 1
fi
TARGET_HOST=$1
SSH_USER=$2
SSH_PRIVATE_KEY=""
if test "$3"
then
  SSH_PRIVATE_KEY="-i $3"
fi

SSH_PORT=22
SLEEP_TIME=10

## wait for chef-solo installing
STATUS="1"
BOOT_CHECK="ssh -q -t -l $SSH_USER -p $SSH_PORT $SSH_PRIVATE_KEY $SSH_USER@$TARGET_HOST \"sudo -i sh -c 'date > /dev/null'\""

while [ $STATUS -ne "0" ]
do
  eval $BOOT_CHECK
  STATUS=$?
  if [ $STATUS -ne "0" ]
  then
    echo "waiting $SLEEP_TIME sec..." 
    sleep $SLEEP_TIME
  fi
done

## execute user-data of CloudInit 
ssh -q -t -l $SSH_USER -p $SSH_PORT $SSH_PRIVATE_KEY $SSH_USER@$TARGET_HOST \
"sudo -i sh -c '\
cd /tmp && \
curl http://169.254.169.254/1.0/user-data 2>/dev/null | sh \
'"
