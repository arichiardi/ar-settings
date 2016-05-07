#!/bin/bash

DEV_LOOP=$(sudo losetup -f)
MOUNT_POINT=~/tmp/vault

echo -e "Mounting vault on ${DEV_LOOP}..."
sudo losetup $DEV_LOOP $1

if [ "$?" = "0" ]; then
    echo -e "Decrypting vault..."
    sudo cryptsetup luksOpen /dev/loop0 vault

    if [ "$?" = "0" ]; then
        echo -e "Mounting vault..."
        mkdir -p /tmp/backup
        sudo mount /dev/mapper/vault ~/tmp/vault

        if [ "$?" = "0" ]; then
            echo -e "Completed, vault mounted on $MOUNT_POINT"
        else
            echo -e "Error: mount exited with $?"
        fi

    else
        echo -e "Error: cryptsetup exited with $?"
    fi
else
    echo -e "Error: losetup exited with $?"
fi

exit $?
