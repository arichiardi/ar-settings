#!/bin/bash
# /usr/local/bin/gpgsign.sh
#
# Signs the input key ID, using the keyring found in the local .gnupg folder.
#
# Usage:
# gpgsign.sh *key_id*

do_usage() {
    echo -n
    echo "Usage:"
    echo "gpgsign.sh *key_id*"
    exit 1
}

do_fail() {
  echo -ne "\nFailed!\n"
  exit 1
}

do_cancel() {
  echo -ne "\nCanceled!\n"
  exit 0
}

[ 1 -ne $# ] && do_usage

GPG="/usr/bin/gpg2"
GPG_FOLDER=.gnupg
KEY_ID=$1
COMMON_OPTS="--no-default-keyring --homedir .gnupg"
SECRET_KEY_ID=$($GPG $COMMON_OPTS --list-secret-keys | grep sec | awk '{ print $2 }' | awk -F/ '{ print $2 }' | xargs)
KEY_ID_SIGNED_FILE="$KEY_ID.signed-by.$SECRET_KEY_ID.asc"

echo -n Showing the current keyring...
$GPG $COMMON_OPTS -K

# From
# http://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script/27875395#27875395
echo -n "It is necessary to retrieve key $KEY_ID, proceed (y/n)? "
stty raw -echo ; answer=$(head -c 1) ; stty sane
if echo "$answer" | grep -iq "^y" ;then
    echo "Downloading..."
else
    do_cancel
fi

$GPG $COMMON_OPTS --recv-keys $KEY_ID
[ 0 -ne $? ] && do_fail

echo -ne "\nSign $KEY_ID (y/n)? "
stty raw -echo ; answer=$(head -c 1) ; stty sane
if echo "$answer" | grep -iq "^y" ;then
    echo -ne "\n"
else
    do_cancel
fi

$GPG $COMMON_OPTS --sign-key $KEY_ID
[ 0 -ne $? ] && do_fail

$GPG $COMMON_OPTS --list-sigs $KEY_ID

WAS_SIGNED=$($GPG $COMMON_OPTS --list-sigs $KEY_ID | grep $SECRET_KEY_ID | awk '{ print $1 }' | uniq)

if echo "$WAS_SIGNED" | grep -iq "sig" ;then

    echo -n "Key $KEY_ID is currently signed, upload to keyserver (y/n)? "
    stty raw -echo ; answer=$(head -c 1) ; stty sane
    if echo "$answer" | grep -iq "^y" ;then
        echo -ne "\nUploading...\n"
        $GPG $COMMON_OPTS --send-keys $KEY_ID
    else
        echo -ne "\nNOTE: key $KEY_ID has been signed, during this o previous sessions by the local
.gnupg identity. A file has been created in the current folder containing the new signed key,
$KEY_ID_SIGNED_FILE, ready to be sent either to a key server or the key owner."
        $GPG $COMMON_OPTS --armor --export $KEY_ID > $KEY_ID_SIGNED_FILE
    fi
else
    do_cancel
fi

echo -ne "\nDone!\n"
