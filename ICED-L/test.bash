#!/bin/bash
# Basic test after flashing firmware
# Jacob Alexander - 2015

DEVICE_GLOB="/dev/ttyACM*"

# Convenience debug/error checker
debug() {
	# Error occurred, stop
	if [ "$RETVAL" -ne "0" ]; then
		exit $RETVAL
	fi
}


# Find actual directory of this script and enter it
cd "$(dirname $(realpath "$0"))"


#############
# LED Blink #
#############

# First scan for any fully flashed devices
DEVICES=$(ls $DEVICE_GLOB)
for DEV in $DEVICES; do
	# TODO screen has elevated permissions, not handled here
	# Check if any other programs owns the file/device and kill them
	for PID in $(lsof -t $DEV); do
		echo "Killing -> $PID"
		kill $PID
	done

	# Send dummy commands to clean out buffer
	printf "\r" > $DEV

	# Blink, then stay on
	for ((c=0; c < 9; c++)); do
		printf "led\r" > $DEV
		sleep 0.1
	done
done

exit 0

