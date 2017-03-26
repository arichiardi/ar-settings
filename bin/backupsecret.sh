#!/bin/bash
# /usr/local/bin/backupsecret.sh
#
# Performs backup of files, encrypting the file at destination.
# If the destination is a folder, the final file name will have a
# timestamp suffix.
# WARNING! If the copy to destination is successful, the original file
# is wiped.
#
# Usage:
# backupsecret.sh *source* *destination file/folder*

#
# Standard Options
#
ANSWER_TIMEOUT=60
STAMP=$(date "+%Y%m%d%H%M")
SHRED_OPTS='--force --iterations=9 --zero --remove'
OPENSSL_OPTS='-aes-256-cbc -salt'
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
#CP=s3cmd put

# Start
do_usage() {
    echo -n
    echo "Usage:"
    echo "backupsecret.sh *source* *destination file/folder*"
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

do_clean() {
    shred $SHRED_OPTS $SRC_FILE 2> /dev/null
    shred $SHRED_OPTS $TMP_FILE 2> /dev/null
}

do_fail_clean_temp() {
    shred $SHRED_OPTS $TMP_FILE 2> /dev/null
    echo failed!
    exit 1
}

do_fail() {
    echo failed!
    exit 1
}

TMP_FILE=/tmp/bkp$STAMP

echo -n Encrypting backup...
openssl enc $OPENSSL_OPTS -in $SRC_FILE -out $TMP_FILE
[ 0 -ne $? ] && do_fail_clean_temp
echo done.
$CP $TMP_FILE $DEST_FILE
[ 0 -ne $? ] && do_fail_clean_temp
echo -n Shredding the source and temp file...
do_clean
echo done.
exit 0
