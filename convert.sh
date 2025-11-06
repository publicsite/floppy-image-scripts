#!/bin/sh

OLD_UMASK="$(umask)"
umask 0022

mkdir convertedImages
cd convertedImages
mkdir temp
mkdir tempmount
find "$1" -type f -name "*.scp" | while read line; do
cp -a "$line" temp/
filename="$(basename "$line")"
failed=0

#try amiga image
LD_LIBRARY_PATH="${PWD}/disk-utilities/libdisk" disk-analyse "temp/${filename}" "temp/${filename%????}.adf"
if [ "$?" = "0" ]; then
	mkdir "temp/${filename%????}"

	LD_LIBRARY_PATH="${PWD}/disk-utilities/libdisk" adfread "temp/${filename%????}.adf" "temp/${filename%????}"
	if [ "$?" != "0" ]; then
		rmdir "temp/${filename%????}"
		failed=1
	fi
else
	failed=1
fi

#try IBM image
if [ "${failed}" = "1" ]; then
failed=0
LD_LIBRARY_PATH="${PWD}/disk-utilities/libdisk" disk-analyse "temp/$filename" "temp/${filename%????}.imd"
	if [ -f "temp/${filename%????}.imd" ]; then
		LD_LIBRARY_PATH="${PWD}/disk-utilities/libdisk" disk-analyse "temp/${filename%????}.imd" "temp/${filename%????}.img"
		sudo mount -o loop "temp/${filename%????}.img" tempmount
		theresult="$?"
		if [ "$theresult" = 0 ]; then
			sudo cp -a tempmount "temp/${filename%????}"
			sudo umount tempmount
		else
			failed=1
		fi
	else
		failed=1
	fi
fi

if [ "${failed}" = "1" ]; then
echo "" > "temp/${filename%????}.unknown"
fi

	#clean up
	if [ -f "temp/${filename%????}.imd" ]; then
		rm -f "temp/${filename%????}.imd"
	fi
	if [ -f "temp/${filename%????}.img" ]; then
		rm -f "temp/${filename%????}.img"
	fi
	if [ -f "temp/${filename%????}.adf" ]; then
		rm -f "temp/${filename%????}.adf"
	fi
	if [ -f "temp/${filename}" ]; then
		rm -f "temp/${filename}"
	fi
done

rmdir tempmount

umask "${OLD_UMASK}"
