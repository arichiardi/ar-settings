#!/bin/bash

MOUNT_POINT=/tmp/vault
BKP_VAULT_BIN=$HOME/bin/backupvault

ANSWER_TIMEOUT=10
ANS="y"

# AR we check mount now, but the following is useful too
#
# sudo losetup -Jl /dev/loop0 | jq -rC '.loopdevices[] | select(.back-file | contains("$MOUNT_POINT"))'
if [[ "$(mount)" =~ /dev/mapper.*"$MOUNT_POINT" ]]; then
    if read -p "Skip vault backup (y/n)? " -t $ANSWER_TIMEOUT ANS;
    then
        ANS=${ANS,,}
        if [[ "$ANS" =~ y|Y ]] ; then
            echo "Ok, skipping vault backup..."
        else
           $BKP_VAULT_BIN
        fi
    else
        echo "No input received in $ANSWER_TIMEOUT seconds, backing up..."
        $BKP_VAULT_BIN
    fi
fi

echo -e "Umounting vault from $MOUNT_POINT..."
sudo umount $MOUNT_POINT

if [ "$?" = "0" ]; then
    echo -e "Encrypting back again..."
    sudo cryptsetup luksClose vault

    if [ "$?" = "0" ]; then
        LOSETUP=$(sudo losetup -a | grep vault)
        DEV_LOOP=$(echo $LOSETUP | awk -F ':' '{ print($1) }')

        echo -e "Umounting $DEV_LOOP..."
        sudo losetup -d $DEV_LOOP

        if [ "$?" = "0" ]; then
            VAULT_FILE=$(echo $LOSETUP | grep -o '(.*)' | cut -d \( -f 2 | cut -d \) -f 1)
            echo -e "Writing sha1..."
            PWD=$(pwd)
            cd $(dirname $VAULT_FILE)
            sha1sum $(basename $VAULT_FILE) > $VAULT_FILE.sha1
            sudo chown root:backup $VAULT_FILE.sha1
            sha1sum -c $VAULT_FILE.sha1
            cd $PWD
            echo -e "Completed!"
        else
            echo -e "Error: losetup -d exited with $?"
        fi
    else
        echo -e "Error: cryptsetup exited with $?"
    fi
else
    echo -e "Error: umount exited with $?"
fi

exit $?