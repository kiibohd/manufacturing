#!/bin/bash
# Bus Pirate setup script
# Used for flashing and erasing Kinetis (SWD) devices
# NOTE: Only tested with a buspirate on Linux

# Expected exported variables
# TOOLCHAIN - Path to McHCK ruby programmer toolchain (all)
# CLASS     - Verifies detected class with expected (all)
# FIRMWARE  - Path to firmware image to flash (flash)
# ADDRESS   - Starting address to flash firmware from (flash)

# Modes
# flash - Flashes given firmware
# erase - Erases chip

# NOTE: This requires a udev rule
#       See: https://wiki.archlinux.org/index.php/Bus_pirate
BUSPIRATE=/dev/buspirate

# Convenience debug/error checker
debug() {
	# Error occurred, show debug
	if [ "$RETVAL" -ne "0" ]; then
		echo ""
		# Debug info
		echo "TOOLCHAIN: '$TOOLCHAIN'"
		echo "FIRMWARE:  '$FIRMWARE'"
		echo "ADDRESS:   '$ADDRESS'"
		echo "CWD:       '$(pwd)'"

		exit $RETVAL
	fi
}


# Find actual directory of this script and enter it
ORIG_PATH=$(pwd)
FIRMWARE=${ORIG_PATH}/${FIRMWARE}
cd "$(realpath $(dirname "$0"))"


# First check for toolchain
if [ ! -d "${TOOLCHAIN}" ]; then
	echo "ERROR: Could not find toolchain directory '${TOOLCHAIN}'"
	exit 1
fi


# Check for a bus pirate
if [ ! -e "$BUSPIRATE" ]; then
	echo "ERROR: Could not find a bus pirate '${BUSPIRATE}'"
	exit 1
fi


# Detect which class of chip has been connected to the bus pirate
# Udev rules have been applied to name the buspirate as /dev/buspirate (instead of something like /dev/ttyUSB0)
# By default only root can access serial devices on Linux
DETECTED_CLASS=$(ruby "${TOOLCHAIN}"/flash.rb name=buspirate:dev=/dev/buspirate --detect)
RETVAL=$?

# Check if bus flashing cable is attached correctly
if [ "$RETVAL" -ne "0" ]; then
	echo "ERROR: Cannot detect device. Check flashing cable. Possibly a soldering issue."
fi
debug

# Make sure the detected class matches the expected class
if [ "${DETECTED_CLASS}" != "${FAMILY}" ]; then
	echo "ERROR: Invalid microcontroller detected: '${DETECTED_CLASS}'. Expected: '${FAMILY}'"
	exit 5
fi

# Check mode
case "$1" in
"flash")
	# Attempt to flash
	ruby "${TOOLCHAIN}"/flash.rb name=buspirate:dev=/dev/buspirate "$FIRMWARE" "$ADDRESS"
	RETVAL=$?
	sleep 0.5 # Wait for Device/USB to initialize before continuing
	;;
"erase")
	# Attempt to erase
	ruby "${TOOLCHAIN}"/flash.rb name=buspirate:dev=/dev/buspirate --mass-erase

	RETVAL=$?
	;;
*)
	echo "ERROR: '$1' is an invalid mode"
	RETVAL=1
esac
debug

exit $RETVAL

