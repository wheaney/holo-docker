#!/bin/bash
set -e

STEAMOS_CHANNEL="${1:-steamdeck}"

LOOP=$(losetup --find --partscan --show ./steamos_image/disk.img)
mkdir -p ./steamos
mount ${LOOP}p3 ./steamos
unmountimg() {
    umount ./steamos
    losetup -d $LOOP
}
trap unmountimg ERR

docker build --build-arg STEAMOS_CHANNEL="$STEAMOS_CHANNEL" -t holo-base:ci-build .

unmountimg
