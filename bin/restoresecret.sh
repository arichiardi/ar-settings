#!/bin/bash
# /usr/local/bin/restoresecret.sh
#
# Performs a restore of files, encrypted with the hardcoded algorithm.
#
# Usage:
# restoresecret.sh *source* *destination file/folder*

#
# Standard Options
#
ANSWER_TIMEOUT=60
OPENSSL_OPTS='-aes-256-cbc'
#
# Storage Options
# Only 1 set of options should be un-commented (the last one will be used).
#
# CP - Storage on a local machine. Could be Dropbox/Wuala folder.
CP=cp
#
# SSH - Storage on a remote machine.
#CP=scp
#
# S3 - Storage on Amazon's S3. Be sure s3cmd is installed and properly setup.
# You may need "s3cmd put --force" if you use a sub-directory.
#CP=s3cmd get

# Start
do_usage() {
    echo -n
    echo "Usage:"
    echo "restoresecret.sh *source* *destination file/folder*"
    exit 1
}
[ 2 -ne $# ] && do_usage

do_error_no_src() {
  echo "Source file not found."
  exit 1
}

[ ! -f $1 ] && do_error_no_src
SRC_FILE=$1

DEST_FILE=
if [ -d $2 ] ; then
    NORMALIZED_DIR=$(readlink -e $2)
    DEST_FILE=$NORMALIZED_DIR/$1
else
    DEST_FILE=$2
fi

ANS=n
if [ -f $DEST_FILE ] ; then
    echo -n "Destination exists. Overwriting will shred the old file and write the new one at location. Proceed (y/n)? "
    read -t $ANSWER_TIMEOUT ANS
    ANS=${ANS,,}
    if [ $ANS == 'y' ] ; then
        shred $SHRED_OPTS $DEST_FILE 2> /dev/null
    else
        exit 0
    fi
fi

do_fail() {
    shred $SHRED_OPTS $DEST_FILE 2> /dev/null
    echo Cannot decript, probably because of invalid passphrase!
    exit 1
}

echo -n Decrypting backup...
openssl enc -d $OPENSSL_OPTS -in $SRC_FILE -out $DEST_FILE #2> /dev/null
[ 0 -ne $? ] && do_fail
echo done.
exit 0
