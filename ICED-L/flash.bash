#!/bin/bash
# Flashes firmware on a Kinetis Device (SWD)
# Jacob Alexander - 2015
# Toolchain is selectable - Arg 1
# - buspirate (Default)
# - jlink

# Convenience debug/error checker
debug() {
	# Error occurred, stop
	if [ "$RETVAL" -ne "0" ]; then
		exit $RETVAL
	fi
}


# Find actual directory of this script and enter it
cd "$(dirname $(realpath "$0"))"

# Set mode if specified
if [ "$#" -gt "0" ]; then
	MODE=$1
else
	MODE=buspirate
fi


##############
# Bootloader #
##############

# Erase First
./erase.bash $MODE
RETVAL=$?
debug

# Flash Bootloader
./bootloader.bash $MODE
RETVAL=$?
debug


############
# Firmware #
############

./firmware.bash
RETVAL=$?
debug


########
# Test #
########

./test.bash
RETVAL=$?


exit $RETVAL

