# stable is Debian, alternative is Ubuntu
TAG = alternative
VERSION = 20230426-lunar
ARCH = amd64
ZIP = clonezilla-live-${VERSION}-${ARCH}.zip
SIG = clonezilla-live-${VERSION}-${ARCH}.zip.gpg
CHECKSUM = clonezilla-live-${VERSION}-${ARCH}.txt

DEVICE_NAME =
ifeq ($(DEVICE_NAME),)
  $(error DEVICE_NAME is not set)
endif

MOUNT_PATH=live-usb/

${ZIP}:
	curl --fail --fail-early -L -o ${ZIP} \
      "https://sourceforge.net/projects/clonezilla/files/clonezilla_live_${TAG}/${VERSION}/clonezilla-live-${VERSION}-${ARCH}.zip/download?use_mirror=versaweb"

${SIG}:
	curl --fail --fail-early -L -o ${SIG} \
      "https://clonezilla.org/downloads/${TAG}/data/CHECKSUMS.TXT.gpg"

${CHECKSUM}:
	curl --fail --fail-early -L -o ${CHECKSUM} \
      "https://clonezilla.org/downloads/${TAG}/data/CHECKSUMS.TXT"

${MOUNT_PATH}:
	mkdir -p ${MOUNT_PATH}

.PHONY: download
download: ${SIG} ${CHECKSUM} ${ZIP}

.PHONY: verify
verify: ${SIG} ${CHECKSUM} ${ZIP}
	gpg --verify ${SIG} ${CHECKSUM}
	sha256sum -c --ignore-missing ${CHECKSUM}

.PHONY: mount
mount: ${MOUNT_PATH}
	sudo mount ${DEVICE_NAME} ${MOUNT_PATH}

.PHONY: extract
extract: ${MOUNT_PATH} ${ZIP}
	unzip -x -d ${MOUNT_PATH} ${ZIP}

.PHONY: bootable
bootable: ${MOUNT_PATH}
	@pushd ${MOUNT_PATH}
	bash makeboot.sh ${DEVICE_NAME}
	@popd

.PHONY: unmount
unmount: ${MOUNT_PATH}
	sudo umount ${MOUNT_PATH}

.PHONY: clean
clean: unmount
	rm -vf ${SIG} ${CHECKSUM} ${ZIP}
