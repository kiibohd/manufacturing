#!/bin/bash
# Flashes firmware on a Kinetis Device (SWD)

# Find actual directory of this script and enter it
cd "$(realpath $(dirname "$0"))"

# Set mode if specified
if [ "$#" -gt "0" ]; then
	MODE=$1
else
	MODE=buspirate
fi


############
# Firmware #
############

export FIRMWARE=$(ls IC60_firmware.*.dfu.bin)
export DEVICE="mk20dx128vlf5"
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

