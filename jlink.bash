#!/bin/bash
# Segger JLink setup script
# Used for flashing and erasing Kinetis (SWD) devices
# NOTE: Only tested with a Segger JLink on Linux
# Uses TMPSCRIPT to generate/run batch script

# Expected exported variables
# TOOLCHAIN - Path to McHCK ruby programmer toolchain (all)
# FIRMWARE  - Path to firmware image to flash (flash)
# ADDRESS   - Starting address to flash firmware from (flash)
# DEVICE    - Name of the chip series

# Modes
# flash - Flashes given firmware
# erase - Erases chip

TMPSCRIPT=/tmp/jlinkscript

# Find actual directory of this script and enter it
ORIG_PATH=$(pwd)
FIRMWARE=${ORIG_PATH}/${FIRMWARE}
cd "$(dirname $(realpath "$0"))"

# First check for toolchain
if [ ! -d "${TOOLCHAIN}" ]; then
	echo "ERROR: Could not find toolchain directory '${TOOLCHAIN}'"
	exit 1
fi

# Check mode
case "$1" in
# Flash Mode
"flash")
	# Generate commander script
	echo "
power on
Sleep 10
rx 10
loadbin ${FIRMWARE} ${ADDRESS}
rx 10
power off
q
" > "${TMPSCRIPT}"
	cat ${TMPSCRIPT}

	# Attempt to flash
	# Udev rules are required to run commands without root priviledges (see 99-jink.rules)
	"${TOOLCHAIN}"/JLinkExe -Device "${DEVICE}" -CommanderScript "${TMPSCRIPT}"
	RETVAL=$?
	sleep 0.5 # Wait for Device/USB to initialize before continuing
	;;

# Erase Mode
"erase")
	# Generate commander script
	echo "
power on
Sleep 10
rx 10
unlock kinetis
erase
unlock kinetis
power off
q
" > "${TMPSCRIPT}"
	cat ${TMPSCRIPT}

	# Attempt to erase
	# Udev rules are required to run commands without root priviledges (see 99-jink.rules)
	"${TOOLCHAIN}"/JLinkExe -Device "${DEVICE}" -CommanderScript "${TMPSCRIPT}"

	RETVAL=$?
	;;

# Reset to bootloader mode
"bootloader")
	# Generate commander script
	echo "
rx 10
r0
r1
q
" > "${TMPSCRIPT}"
	cat ${TMPSCRIPT}
	# Attempt to reset chip to bootloader
	# Udev rules are required to run commands without root priviledges (see 99-jink.rules)
	"${TOOLCHAIN}"/JLinkExe -CommanderScript "${TMPSCRIPT}"

	RETVAL=$?
	;;

# Reset Mode
"reset")
	# Generate commander script
	echo "
r
q
" > "${TMPSCRIPT}"
	cat ${TMPSCRIPT}
	# Attempt to reset chip to bootloader
	# Udev rules are required to run commands without root priviledges (see 99-jink.rules)
	"${TOOLCHAIN}"/JLinkExe -CommanderScript "${TMPSCRIPT}"

	RETVAL=$?
	;;

# Invalid Mode
*)
	echo "ERROR: '$1' is an invalid mode"
	RETVAL=1
esac

echo "NOTE: jlink does not indicate cabling failures, here are some indicators"
echo "USB Cable Problem      -> 'Can not connect to J-Link via USB.'"
echo "Flashing Cable Problem -> 'VTarget = 0.000V'"
echo "                          'WARNING: RESET (pin 15) high, but should be low. Please check target hardware.'"
echo "                          'Downloading file [kiibohd_bootloader.bin]...Writing target memory failed.'"
echo ""

# Error occurred, show debug
if [ "$RETVAL" -ne "0" ]; then
	echo ""
	# Debug info
	echo "TOOLCHAIN: '$TOOLCHAIN'"
	echo "FIRMWARE:  '$FIRMWARE'"
	echo "ADDRESS:   '$ADDRESS'"
	echo "DEVICE:    '$DEVICE'"
	echo "TMPSCRIPT: '$TMPSCRIPT'"
	echo "CWD:       '$(pwd)'"
fi

exit $RETVAL

