#!/bin/bash
# Generates bootloader and firmware images for manufacturing scripts
# Jacob Alexander - 2015

NAME_BOOTLOADER="IC60_bootloader"
NAME_FIRMWARE="IC60_firmware"
BOOTLOADER_BRANCH="bringup"
BOOTLOADER_REV="2160a267a7714a0cf29cc0980b57a294d0bda068"
FIRMWARE_BRANCH="master"
FIRMWARE_REV="c21439cb48daec7514da4250c41962205fa96624"
KLL_BRANCH="master"
KLL_REV="f40c189980fc427db60e3dcca3bfacc7cae9f6ae"
CHIP="mk20dx128vlf5"
SCAN="MD1"
BASEMAP="defaultMap"
DEFAULTMAP="md1Overlay stdFuncMap"
PARTIALMAPS="hhkbpro2"


# Convenience debug/error checker
debug() {
	# Error occurred, stop
	if [ "$RETVAL" -ne "0" ]; then
		exit $RETVAL
	fi
}


# Find actual directory of this script and enter it
cd "$(realpath $(dirname "$0"))"

# Remove old .bin files
rm *.bin

# Make sure controller code is available and up to date
if [ ! -d ../controller ]; then
	cd ..
	git clone https://github.com/kiibohd/controller.git
	cd -
fi
cd ../controller


##############
# Bootloader #
##############

# Change to branch and revision
git checkout $BOOTLOADER_BRANCH
git pull origin $BOOTLOADER_BRANCH
git checkout $BOOTLOADER_REV
cd -

# Create tmp directory (and make sure it's clean)
mkdir -p bootloader
cd bootloader
rm -rf *

# Generate the firmware
cmake ../../controller/Bootloader -DCHIP=$CHIP
make

# Prepare file
cp -f kiibohd_bootloader.bin ../${NAME_BOOTLOADER}.${BOOTLOADER_REV}.bin

# Revert to master branch
cd -
cd ../controller
git checkout master
cd -


############
# Firmware #
############

# Select kll version
cd ../controller/kll
git checkout $KLL_BRANCH
git pull origin $KLL_BRANCH
git checkout $KLL_REV
cd -

# Change to branch and revision
cd ../controller
git checkout $FIRMWARE_BRANCH
git pull origin $FIRMWARE_BRANCH
git checkout $FIRMWARE_REV
cd -

# Create tmp directory (and make sure it's clean)
mkdir -p firmware
cd firmware
rm -rf *

# Generate the firmware
cmake ../../controller -DCHIP=$CHIP -DScanModule=$SCAN -DBaseMap="$BASEMAP" -DDefaultMap="$DEFAULTMAP" -DPartialMaps="$PARTIALMAPS"
make

# Prepare file
cp -f kiibohd.dfu.bin ../${NAME_FIRMWARE}.${FIRMWARE_REV}.dfu.bin

# Revert to master branch
cd ..
cd ../controller
git checkout master
cd -
cd ../controller/kll
git checkout master
cd -

