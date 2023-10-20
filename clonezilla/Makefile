.DEFAULT_GOAL := build

SECRET = ../home/.local/bin/secret

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
DEVICE_MOUNT_LIVE_DIR = ${DEVICE_MOUNT_DIR}/live

SQUASHFS_PATH = ${DEVICE_MOUNT_LIVE_DIR}/filesystem.squashfs

FILESYSTEM_ROOT_DIR = squashfs

# From https://unix.stackexchange.com/a/377269
FILESYSTEM_WORK_DIR = ${FILESYSTEM_ROOT_DIR}/tmp
# We mount into the lower/from dir
FILESYSTEM_LOWER_DIR = ${FILESYSTEM_ROOT_DIR}/current
FILESYSTEM_UPPER_DIR = ${FILESYSTEM_ROOT_DIR}/new
# The merge result will be in the target dir
FILESYSTEM_TARGET_DIR = ${FILESYSTEM_ROOT_DIR}/target

############
# DOWNLOAD #
############

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

.PHONY: extract
extract: ${DEVICE_MOUNT_DIR} verify
	unzip -x -d ${DEVICE_MOUNT_DIR} ${ZIP}

##########
# DEVICE #
##########

${DEVICE_MOUNT_DIR}:
	mkdir -p ${DEVICE_MOUNT_DIR}
	sudo mount ${DEVICE} ${DEVICE_MOUNT_DIR} -o uid=$(shell id -u),gid=$(shell id -g)

############
# SQUASHFS #
############

${FILESYSTEM_ROOT_DIR}:
	mkdir -p ${FILESYSTEM_ROOT_DIR}

${FILESYSTEM_WORK_DIR}: ${FILESYSTEM_ROOT_DIR}
	@mkdir -p ${FILESYSTEM_WORK_DIR}

${FILESYSTEM_TARGET_DIR}: ${FILESYSTEM_ROOT_DIR}
	@mkdir -p ${FILESYSTEM_TARGET_DIR}

${FILESYSTEM_UPPER_DIR}: ${FILESYSTEM_ROOT_DIR}
	@mkdir -p ${FILESYSTEM_UPPER_DIR}

${FILESYSTEM_LOWER_DIR}: ${FILESYSTEM_ROOT_DIR}
	@mkdir -p ${FILESYSTEM_LOWER_DIR}
	sudo mount -t squashfs ${SQUASHFS_PATH} ${FILESYSTEM_LOWER_DIR}

.PHONY: overlay
overlay: ${FILESYSTEM_WORK_DIR} ${FILESYSTEM_LOWER_DIR} ${FILESYSTEM_UPPER_DIR} ${FILESYSTEM_TARGET_DIR}
	fuse-overlayfs -o uidmapping=0:$(shell id -u):1:1:110000:65536,gidmapping=0:$(shell id -u):1:1:110000:65536,lowerdir=$(realpath ${FILESYSTEM_LOWER_DIR}),upperdir=$(realpath ${FILESYSTEM_UPPER_DIR}),workdir=$(realpath ${FILESYSTEM_WORK_DIR}) ${FILESYSTEM_TARGET_DIR}

${FILESYSTEM_UPPER_DIR}/etc: overlay
	mkdir -p ${FILESYSTEM_UPPER_DIR}/etc

${FILESYSTEM_UPPER_DIR}/etc/passwd-s3fs: ${FILESYSTEM_UPPER_DIR}/etc
	${SECRET} -r -s passwd-s3fs.enc -d ${FILESYSTEM_UPPER_DIR}/etc/passwd-s3fs

${FILESYSTEM_UPPER_DIR}/usr/local/bin: overlay
	mkdir -p ${FILESYSTEM_UPPER_DIR}/usr/local/bin

${FILESYSTEM_UPPER_DIR}/usr/local/bin/mount-clones: ${FILESYSTEM_UPPER_DIR}/usr/local/bin
	cp mount-clones ${FILESYSTEM_UPPER_DIR}/usr/local/bin/mount-clones

${SQUASHFS_PATH}:
	mksquashfs ${FILESYSTEM_TARGET_DIR} ${SQUASHFS_PATH}

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
	-sudo umount ${FILESYSTEM_TARGET_DIR}
	-sudo umount ${FILESYSTEM_LOWER_DIR}

.PHONY: build
build: overlay ${FILESYSTEM_UPPER_DIR}/etc/passwd-s3fs ${FILESYSTEM_UPPER_DIR}/usr/local/bin/mount-clones

.PHONY: clean
clean: unmount
	rm -vf ${SIG} ${CHECKSUM} ${ZIP}
	rmdir -v ${DEVICE_MOUNT_DIR} ${FILESYSTEM_WORK_DIR} ${FILESYSTEM_LOWER_DIR} ${FILESYSTEM_UPPER_DIR} ${FILESYSTEM_TARGET_DIR} ${FILESYSTEM_ROOT_DIR}
