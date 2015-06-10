#!/bin/bash
# Flashes bootloader to a Kinetis Device (SWD)
# Jacob Alexander - 2015
# Toolchain is selectable - Arg 1
# - buspirate (Default)
# - jlink

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

export FIRMWARE=$(ls IC60_bootloader.*.bin)
export ADDRESS="0x0"
export DEVICE="MK20DX128XXX5" # jlink
export FAMILY="K20_50" # buspirate

# Arg 1 - mode (optional)
# - buspirate (default)
# - jlink
case "$MODE" in
"jlink")
	export TOOLCHAIN="jlink"
	../jlink.bash flash
	RETVAL=$?
	;;
"buspirate")
	export TOOLCHAIN="programmer"
	../buspirate.bash flash
	RETVAL=$?
	;;
*)
	echo "ERROR: '$MODE' is an invalid mode $#"
	exit 1
esac

# Make sure bootloader flashing succeeded
if [ "$RETVAL" -ne "0" ]; then
	echo "ERROR: Bootloader flashing failed. $RETVAL"
	exit $RETVAL
fi

exit $?

