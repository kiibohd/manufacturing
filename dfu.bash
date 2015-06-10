#!/bin/bash
# dfu-util setup script
# Used for flashing firmware on dfu-enabled devices

# Expected exported variables
# FIRMWARE    - Path to firmware image to flash (flash)
# DEVICE      - Device attempting to flash
# DFU_NAME    - Name of the DFU Bootloader
# USB_BOOT_ID - <vendor id>:<product id> of DFU Bootloader
# USB_ID      - <vendor id>:<product id> of flashed device
# GITREV      - Git Commit revision of firmware to flash

DEVICE_GLOB="/dev/ttyACM*"

# Convenience debug/error checker
debug() {
	# Error occurred, show debug
	if [ "$RETVAL" -ne "0" ]; then
		echo ""
		# Debug info
		echo "FIRMWARE:    '$FIRMWARE'"
		echo "DEVICE:      '$DEVICE'"
		echo "DFU_NAME:    '$DFU_NAME'"
		echo "USB_BOOT_ID: '$USB_BOOT_ID'"
		echo "USB_ID:      '$USB_ID'"
		echo "GITREV:      '$GITREV'"
		echo "CWD:         '$(pwd)'"

		exit $RETVAL
	fi
}

# Find actual directory of this script and enter it
ORIG_PATH=$(pwd)
FIRMWARE=${ORIG_PATH}/${FIRMWARE}
cd "$(dirname $(realpath "$0"))"

# Check to make sure there are valid USB IDs to use dfu-util
lsusb -d $USB_BOOT_ID
RETVAL=$?
if [ "$RETVAL" -ne "0" ]; then
	echo "ERROR: Could not find '$USB_BOOT_ID'. Check device USB cable. Might be a soldering issue."
fi
debug

# Query dfu-util for flash-ready devices
# TODO Enhance dfu-util to handle matching devices by devnum
# TODO Enhance dfu-util to ignore status (don't wait if specified)
dfu-util -l | grep "Found DFU:" | while read -r LINE; do
	echo "AAA $LINE"
	# Extract USB ID, Bootloader Name and Serial
	USBID=$(echo $LINE | sed -e 's/^.*\[\(.*\)\].*$/\1/')
	NAME=$(echo $LINE | sed -e 's/^.*name="\([^"]\+\)".*$/\1/')
	SERIAL=$(echo $LINE | sed -e 's/^.*serial="\([^"]\+\)".*$/\1/')
	DEVNUM=$(echo $LINE | sed -e 's/^.*devnum=\([^,]\+\).*$/\1/')

	# Compare Expected Name, Serial, and USB Boot IDs
	if [ "$NAME" != "$DFU_NAME" ]; then continue; fi
	if [ "$DEVICE" != "$SERIAL" ]; then continue; fi
	if [ "$USBID" != "$USB_BOOT_ID" ]; then continue; fi

	echo "Flashing devnum $DEVNUM"
	dfu-util --device $USB_BOOT_ID --serial $DEVICE  --download $FIRMWARE
	break
done

# Wait for USB to initialize
sleep 2

# Check to see if USB device successfully initialized
lsusb -d $USB_ID
RETVAL=$?
if [ "$RETVAL" -ne "0" ]; then
	echo "ERROR: Could not find '$USB_ID'"
fi
debug

# First scan for any fully flashed devices
DEVICES=$(ls $DEVICE_GLOB)
TMPFILE=/tmp/acmtemp
RETVAL=1 # Assume failed, unless proven otherwise
for DEV in $DEVICES; do
	# TODO screen has elevated permissions, not handled here
	# Check if any other programs owns the file/device and kill them
	for PID in $(lsof -t $DEV); do
		echo "Killing -> $PID"
		kill $PID
	done

	# Prepare polling
	# Device has a very small buffer, must start polling before sending anything
	cat $DEV > $TMPFILE &
	READPID=$!
	sleep 0.01

	# Send dummy commands to clean out buffer
	printf "\r" > $DEV

	# Query version information
	sleep 0.01
	printf "version\r" > $DEV
	sleep 0.01

	# Finished polling serial port
	kill $READPID

	# Read chip ID and git revision
	CHIP=$(cat /tmp/acmtemp | sed -r "s:\x1B\[[0-9;]*[mK]::g" | grep Chip: | grep -o "[a-zA-Z0-9]*" | grep -v Chip)
	REVISION=$(cat /tmp/acmtemp | sed -r "s:\x1B\[[0-9;]*[mK]::g" | grep Revision: | grep -o "[a-zA-Z0-9]*" | grep -v Revision)

	# Ignore Invalid Chips
	if [ "$DEVICE" != "$CHIP" ]; then continue; fi

	# Check git revision
	if [ "$REVISION" != "$GITREV" ]; then
		echo "ERROR: Git Revision ($REVISION) does not match expected ($GITREV)"
	fi

	# Successful flash
	RETVAL=0
	break
done
if [ "$RETVAL" -ne "0" ]; then
	echo "ERROR: Could not find any DFU devices to flash'"
fi
debug

# Complete
echo "$FIRMWARE - $GITREV - $DEVICE was successfully flashed to $USB_ID"
exit $RETVAL

