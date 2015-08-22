#!/bin/bash
# Erases the flash of a Kinetis Device (SWD)
# Jacob Alexander - 2015
# Toolchain is selectable
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

export DEVICE="MK20DX256XXX7" # jlink
export FAMILY="K20_72" # buspirate

# Arg 1 - mode (optional)
# - buspirate (default)
# - jlink
case "$MODE" in
"jlink")
	export TOOLCHAIN="jlink"
	../jlink.bash erase
	RETVAL=$?
	;;
"buspirate")
	export TOOLCHAIN="programmer"
	../buspirate.bash erase
	RETVAL=$?
	;;
*)
	echo "ERROR: '$MODE' is an invalid mode $#"
	exit 1
esac

exit $?

