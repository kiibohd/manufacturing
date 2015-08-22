#!/bin/bash
# Flashes bootloader to a Kinetis Device (SWD)
# Jacob Alexander - 2015
# Toolchain is selectable - Arg 1
# - buspirate (Default)
# - jlink

# Find actual directory of this script and enter it
DIR="$(dirname $(realpath "$0"))"/../$(basename "$0" | cut -d. -f1)
if [[ $DIR != *"bootloader"* ]]; then
	cd $DIR
fi

# Set mode if specified
if [ "$#" -gt "0" ]; then
	MODE=$1
else
	MODE=buspirate
fi


##############
# Bootloader #
##############

export FIRMWARE=$(ls ICED_bootloader.*.bin)
export ADDRESS="0x0"
export DEVICE="MK20DX256XXX7" # jlink
export FAMILY="K20_72" # buspirate

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

