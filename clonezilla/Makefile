.DEFAULT_GOAL := build

# stable is Debian, alternative is Ubuntu
TAG = alternative
VERSION = 20230426-lunar
ARCH = amd64
ZIP = clonezilla-live-${VERSION}-${ARCH}.zip
SIG = clonezilla-live-${VERSION}-${ARCH}.zip.gpg
CHECKSUM = clonezilla-live-${VERSION}-${ARCH}.txt

DEVICE =
ifeq ($(DEVICE),)
  $(error DEVICE is not set)
endif

DEVICE_MOUNT_DIR = live-usb

FILESYSTEM_PATH = ${DEVICE_MOUNT_DIR}/live/filesystem.squashfs

FILESYSTEM_MOUNT_DIR = fin
FILESYSTEM_WORK_DIR = ${FILESYSTEM_MOUNT_DIR}/work
FILESYSTEM_LOWER_DIR = ${FILESYSTEM_MOUNT_DIR}/lower
FILESYSTEM_LOWER_DIR = ${FILESYSTEM_MOUNT_DIR}/upper
FILESYSTEM_TARGET_DIR = ${FILESYSTEM_TARGET_DIR}/upper

${ZIP}:
	curl --fail --fail-early -L -o ${ZIP} \
      "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_${TAG}/${VERSION}/clonezilla-live-${VERSION}-${ARCH}.zip/download?use_mirror=versaweb"

${SIG}:
	curl --fail --fail-early -L -o ${SIG} \
      "https://clonezilla.org/downloads/${TAG}/data/CHECKSUMS.TXT.gpg"

${CHECKSUM}:
	curl --fail --fail-early -L -o ${CHECKSUM} \
      "https://clonezilla.org/downloads/${TAG}/data/CHECKSUMS.TXT"

.PHONY: download
download: ${SIG} ${CHECKSUM} ${ZIP}

.PHONY: verify
verify: ${SIG} ${CHECKSUM} ${ZIP}
	gpg --verify ${SIG} ${CHECKSUM}
	sha256sum -c --ignore-missing ${CHECKSUM}

${DEVICE_MOUNT_DIR}:
	mkdir -p ${DEVICE_MOUNT_DIR}
	sudo mount ${DEVICE} ${DEVICE_MOUNT_DIR}

${FILESYSTEM_MOUNT_DIR}:
	mkdir -p ${FILESYSTEM_MOUNT_DIR}
	sudo mount ${FILESYSTEM_PATH} ${FILESYSTEM_MOUNT_PATH}

.PHONY: extract
extract: ${DEVICE_MOUNT_DIR} verify
	unzip -x -d ${DEVICE_MOUNT_DIR} ${ZIP}

# Not Required
#
# This program is for making a bootable disk with MBR partition table. For GPT disk, there is no
# need to run this program. Just make sure the partition is FAT32 with ID=ef00 and all the files are
# copied on that. That's all.
#
#.PHONY: bootable
#bootable: ${DEVICE_MOUNT_DIR}
#	cd ${DEVICE_MOUNT_DIR} && sudo utils/linux/makeboot.sh ${DEVICE} && cd..

.PHONY: unmount
unmount:
	-sudo umount ${DEVICE_MOUNT_DIR}
	-sudo umount ${FILESYSTEM_MOUNT_PATH}

.PHONY: build
build: extract

.PHONY: clean
clean: unmount
	rm -vf ${SIG} ${CHECKSUM} ${ZIP}
	rmdir -v ${DEVICE_MOUNT_DIR}
