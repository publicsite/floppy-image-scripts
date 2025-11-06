#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

LD_LIBRARY_PATH="${PWD}/disk-utilities/libdisk" disk-analyse "${1}" "${1%????}.imd"
LD_LIBRARY_PATH="${PWD}/disk-utilities/libdisk" disk-analyse "${1%????}.imd" "${1%????}.img"
mkdir ${1%????}
photorec ${1%????}.img

rm ${1%????}.img
rm ${1%????}.imd

umask "${OLD_UMASK}"
