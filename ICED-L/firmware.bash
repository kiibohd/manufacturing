#!/bin/bash
# Flashes firmware on a Kinetis Device (SWD)

# Find actual directory of this script and enter it
DIR="$(dirname $(realpath "$0"))"/../$(basename "$0" | cut -d. -f1)
if [[ $DIR != *"firmware"* ]]; then
	cd $DIR
fi

# Set mode if specified
if [ "$#" -gt "0" ]; then
	MODE=$1
else
	MODE=buspirate
fi


############
# Firmware #
############

export FIRMWARE=$(ls $(basename "$PWD")_firmware.*.dfu.bin)
export DEVICE="mk20dx256vlh7"
export DFU_NAME="Kiibohd DFU"
export USB_BOOT_ID="1c11:b007"
export USB_ID="1c11:b04d"
export GITREV=$(ls $FIRMWARE | sed -e "s/^[^.]\+\.\([^.]\+\)\.dfu.bin$/\1/")

../dfu.bash
RETVAL=$?

# Make sure firmware flashing succeeded
if [ "$RETVAL" -ne "0" ]; then
	echo "ERROR: Bootloader flashing failed. $RETVAL"
fi

exit $RETVAL

