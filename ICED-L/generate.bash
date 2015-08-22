#!/bin/bash
# Generates bootloader and firmware images for manufacturing scripts
# Jacob Alexander - 2015

# Convenience debug/error checker
debug() {
	# Error occurred, stop
	if [ "$RETVAL" -ne "0" ]; then
		exit $RETVAL
	fi
}


# Find actual directory of this script and enter it
cd "$(realpath $(dirname "$0"))"

# Load configuration
source config_$(basename $(dirname "$0")).bash

# Remove old .bin files
rm $(basename $(dirname "$0"))_*.bin

# Make sure controller code is available and up to date
if [ ! -d ../controller ]; then
	cd ..
	git clone https://github.com/kiibohd/controller.git
	cd -
	cd ../controller
	git clone https://github.com/kiibohd/kll.git
	cd -
fi
cd ../controller

# Make sure repo is up to date
git checkout master
git pull


##############
# Bootloader #
##############

# Change to branch and revision
git checkout $BOOTLOADER_BRANCH
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
git checkout master
git pull
git checkout $KLL_BRANCH
git checkout $KLL_REV
cd -

# Change to branch and revision
cd ../controller
git checkout $FIRMWARE_BRANCH
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

